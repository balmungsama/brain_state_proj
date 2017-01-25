### Developer's Notes 
## 
## Creating the plots for each k-cluster is broken. It uses the r-scores directly, 
## instead of the fisher-transformed values.
## 
## Move the code computing the correlations to behavioural performance to new script.




# rm(list=ls())
library(stats)
library(ggplot2)
library(grDevices)
library(gplots)
library(R.matlab)
library(psych)


#### User-defined parameters ###
TOP_DIR     <- '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john' # master directory containing all subject data (each subject must have own directory)
ROI_LABELS  <- file.path(TOP_DIR, '..', 'priv_john_proj', paste0('roi_labels.txt')) # path to the text file containing the labels to be used in the ROIs
lateralized <- T
kk          <- 2:10      # number of k clusters
kk_reps     <- 20        # number of repeats used to determine optimal k value
conf_lvl    <- 0.95		 # level of confidence for the BIC & AIC estimates (b/w 0.00 & 1.00)

plot <- TRUE
#### import brain roi labels ####
labels  <- read.csv(ROI_LABELS, header = F)
labels2 <- NULL

if(lateralized == T) {
  for(label in 1:dim(labels)[1]){
    lab_tmp <- paste(c('L.', 'R.'), as.character(labels[label, 1]))
    labels2 <- c(labels2, lab_tmp)
  }
  
  labels <- labels2
  rm('labels2')
  
  labels <- c(labels[which(startsWith(labels, 'L. '))], labels[which(startsWith(labels, 'R. '))])
}

subj_dirs <- list.dirs(TOP_DIR, recursive = F, full.names = F) # get the list of all participants to be used in the following loop

for(subj in subj_dirs) {
  
  if(!dir.exists(file.path(TOP_DIR, subj, 'roi_twindows'))) {next}       # check if correlation matrices for each time window exist. If it doesn't exist, skip to next participant
  
  mat_files <- dir(path = file.path(TOP_DIR, subj, 'roi_twindows')) # list all of the files contained within the roi timewindows folder
  
  ### This loop is to read into R all time window matrices for all subjects
  for(mat in mat_files) {
    mat <- strsplit(mat, split = '.csv')[[1]][1]                                       # get the name of the time window for orgazational purposes
    assign(x = paste0(subj, '_', mat),                                                 # create a variable names after the subject and the corel matrix of the time window of interest
           read.csv(file.path(TOP_DIR, subj, 'roi_twindows', (paste0(mat, '.csv'))),   # populate the variable with the correlation matrix collected for the time window of interest
                    row.names = 1, 
                    header = T, 
                    check.names = F) )
    
    if(lateralized == T) {    # if rois are lateralized, the matrix is organized by Left & Right hemispheres
      tmp_mat_subj   <- get(paste0(subj, '_', mat))
      quad_top_left  <- tmp_mat_subj[which(startsWith(labels, prefix = 'L. ')), which(startsWith(labels, prefix = 'L. '))]  
      quad_bot_right <- tmp_mat_subj[which(startsWith(labels, prefix = 'R. ')), which(startsWith(labels, prefix = 'R. '))]
      quad_top_right <- tmp_mat_subj[which(startsWith(labels, prefix = 'L. ')), which(startsWith(labels, prefix = 'R. '))]
      quad_bot_left  <- tmp_mat_subj[which(startsWith(labels, prefix = 'R. ')), which(startsWith(labels, prefix = 'L. '))]
      
      tmp_mat_subj_top   <- cbind(quad_top_left, quad_top_right)
      tmp_mat_subj_bot   <- cbind(quad_bot_left, quad_bot_right)
      
      tmp_mat_subj       <- rbind(tmp_mat_subj_top, tmp_mat_subj_bot)
      rownames(tmp_mat_subj) <- NULL
      colnames(tmp_mat_subj) <- NULL
      
      assign(x = paste0(subj, '_', mat), value = tmp_mat_subj)
    }
    
  }
}

mat_list <- ls(pattern = '*_tWin_*') # this will get a list of all time window matrices for all subjects

### Loop through all of the time window matrices within the R environment
for(mat in mat_list){
  tmp_mat <- get(mat) # Read the current matrix
  
  ## Tranform correlation matrix to upper-triangular matrix to eliminate redundant info (values below the main-diagonal will all be NA)
  for(ent_row in 1:dim(tmp_mat)[1]){
    for(ent_col in 1:dim(tmp_mat)[1]){
      if(ent_row >= ent_col){
        tmp_mat[ent_row, ent_col] <- NA 
      }
    }
  }
  
  tmp_mat <- data.matrix(tmp_mat)              # transform the correlation matrix from a data.frame to a matrix
  # browser()
  tmp_mat <- c(tmp_mat)                        # turn the matrix into a vector                            
  tmp_mat <- tmp_mat[complete.cases(tmp_mat)]  # remove all of the NA values from the vector
  tmp_mat <- fisherz(tmp_mat)                  # fisher r-to-z transform the fector     ~~~~~~~~~~~~~~ NEW ~~~~~~~~~~~~~~
  tmp_mat <- c(tmp_mat)
  # assign(x = mat, value = tmp_mat)             # replace the matrix in the R working environment with the vector that was just created
  
  ### Stack the vector you just created into a matrix with all other vectors from all other time windows of all other subjects
  if(!exists('mat_stacked')){
    mat_stacked <- matrix(data = tmp_mat, nrow = 1)
  } else {
    mat_stacked <- rbind(mat_stacked, tmp_mat)
  }
}
mat_stacked <- data.frame(mat_stacked, row.names = mat_list)  # transform it into a data.frame for easier manipulation

##### create directories to save the clusters
dir.create(file.path(TOP_DIR, '..', 'k_clusters'))
dir.create(file.path(TOP_DIR, '..', 'k_clusters', 'nifti_imgs'))

k_optim_tab <- data.frame(k_val = NA, BIC = NA, AIC = NA)   # create a table to contain the BIC/AIC information for each cluster
for( k_val in kk ){
  print(paste0('K = ', k_val))
  for( k_rep in 1:kk_reps ){
    print(paste0('     - On rep #', k_rep))
    
    out_cluster <- kmeans(mat_stacked, centers = k_val) # run k-means clustering on the stacked matrix
    cluster_ls  <- data.matrix(out_cluster$cluster)               # a vector indicating to which cluster each datapoint has been sorted into
    colnames(cluster_ls) <- NULL
    rownames(cluster_ls) <- mat_list
    
    AIC.BIC       <- kmeans_AIC.BIC(out_cluster)
    optim_tmp_row <- data.frame(k_val = k_val, BIC = AIC.BIC$BIC, AIC = AIC.BIC$AIC)
    
    k_optim_tab   <- rbind(k_optim_tab, optim_tmp_row) # bind the new AIC/BIC values to the table to determine optimal k-value
    
    write.csv(x = cluster_ls, file = file.path(TOP_DIR, '..', 'k_clusters', paste0('ls_clusters_k', k_val, '_rep', k_rep, '.csv'))) # save the clusters in the appropriate directory
  }
}
print('DONE')

k_optim_tab            <- k_optim_tab[ -which( is.na(k_optim_tab[,1]) ), ]
row.names(k_optim_tab) <- NULL

### create summary tables for the information criterions, holding their mean & SD values
for(k_val in kk) {
  ksumm_BIC_tmp_col <- c( mean(k_optim_tab$BIC[which(k_optim_tab$k_val == k_val)]), 
                            sd(k_optim_tab$BIC[which(k_optim_tab$k_val == k_val)]) )
  ksumm_AIC_tmp_col <- c( mean(k_optim_tab$AIC[which(k_optim_tab$k_val == k_val)]), 
                            sd(k_optim_tab$AIC[which(k_optim_tab$k_val == k_val)]) )
  
  if( !exists('ksumm_BIC') ) {
    ksumm_BIC <- data.frame( summ = ksumm_BIC_tmp_col,  row.names = c('Mean', 'SD') )
    ksumm_AIC <- data.frame( summ = ksumm_AIC_tmp_col,  row.names = c('Mean', 'SD') )
    
    colnames(ksumm_BIC) <- paste0('k', k_val)
    colnames(ksumm_AIC) <- paste0('k', k_val)
    
  } else {
    ksumm_BIC[, paste0('k', k_val)] <- ksumm_BIC_tmp_col
    ksumm_AIC[, paste0('k', k_val)] <- ksumm_AIC_tmp_col
  }
}

z_conf_lvl <- qnorm( (1-conf_lvl)/2, lower.tail = F) 

### plot AIC & BIC estimates
kplot <- ggplot() + 
  geom_line(mapping = aes(x = kk, y = as.numeric(ksumm_AIC['Mean',]), colour = 'AIC'), size = 1) +
  geom_line(mapping = aes(x = kk, y = as.numeric(ksumm_BIC['Mean',]), colour = 'BIC'), size = 1) +
  
  geom_errorbar(mapping = aes(x = kk, ymax = as.numeric(ksumm_AIC['Mean',] + (ksumm_AIC['SD',]/sqrt(kk_reps))), ymin = as.numeric(ksumm_AIC['Mean',] - (ksumm_AIC['SD',]/sqrt(kk_reps) * z_conf_lvl)), colour = 'AIC', width = 0.3 ), size = 0.5, alpha = 0.7) +
  geom_errorbar(mapping = aes(x = kk, ymax = as.numeric(ksumm_BIC['Mean',] + (ksumm_BIC['SD',]/sqrt(kk_reps))), ymin = as.numeric(ksumm_BIC['Mean',] - (ksumm_BIC['SD',]/sqrt(kk_reps) * z_conf_lvl)), colour = 'BIC', width = 0.3 ), size = 0.5, alpha = 0.7) + 
  
  geom_vline(mapping = aes(xintercept = kk[which(ksumm_BIC['Mean',] == min(ksumm_BIC['Mean',]))], colour = 'BIC'), size = 1, linetype = 'dashed', alpha = 0.7 ) +
  geom_vline(mapping = aes(xintercept = kk[which(ksumm_AIC['Mean',] == min(ksumm_AIC['Mean',]))], colour = 'AIC'), size = 1, linetype = 'dashed', alpha = 0.7 ) +
  
  xlab('Value of K') +
  ylab('Information Criterion Value') + 
  ggtitle('AIC & BIC for each tested k-value') +
  
  scale_x_continuous(breaks = kk) +
  theme_minimal() +
  theme(axis.line.x      = element_line(size   = 0.5, colour = "black"),
        axis.line.y      = element_line(size   = 0.5, colour = "black"),
        axis.title.y     = element_text(vjust  = 0.1                  ),
        panel.grid.major = element_line(size   = 0,   colour = 'white'),
        panel.grid.minor = element_line(size   = 0,   colour = 'white'),
        axis.title.y     = element_text(margin = margin(0,10,0,0)     ),
        axis.title.x     = element_text(margin = margin(10,0,0,0)     ))

print(kplot)

print(paste0('Minimum AIC = ', min(ksumm_AIC['Mean',]), ' with ', kk[which(ksumm_AIC['Mean',] == min(ksumm_AIC['Mean',]))], ' clusters.'))
print(paste0('Minimum BIC = ', min(ksumm_BIC['Mean',]), ' with ', kk[which(ksumm_BIC['Mean',] == min(ksumm_BIC['Mean',]))], ' clusters.'))

# for(clus in as.numeric(unique(cluster_ls))) {
#   
#   row_nms   <- row.names(cluster_ls)[which(cluster_ls[,1] == clus)] # extract the participant and time window (stored in row name) IDs that were sorted into this cluster
#   
#   ### for each window sorted into this cluster, replace the entry with the file path leading to the csv file for that time window
#   for(row in 1:length(row_nms)){
#     row_nms[row] <- file.path(TOP_DIR, strsplit(row_nms[row], '_tWin_')[[1]][1], 
#                               'roi_twindows',
#                               paste0('tWin_', strsplit(row_nms[row], '_tWin_')[[1]][2], '.csv') )
#   }
#   
#   assign(x = paste0('kclus_', clus), value =  row_nms)                                                                         # create a table containing the file paths of all time windows sorted into the current cluster
#   write.table(x = get(paste0('kclus_', clus)), file = file.path(TOP_DIR, '..', 'k_clusters', paste0('kclus_', clus, '.txt')),  # save this table to a txt file
#               row.names = F, 
#               col.names = F)
# }
# 
# 
# ###### create the average cluster matrices #####
# 
# colfunc <- colorRampPalette(c('#426DED', '#EDE742', '#ED4242')) # the colours defining the range to be used
# heat_cols <- colfunc(100)                                       # create a gradient of 100 colours between the 3 key colours defined above
# 
# ###### create plot for each k cluster #####
# 
# for( clus in sort(as.numeric(unique(cluster_ls))) ) {
#   
#   subj_dirs <- NULL
#   
#   row_nms   <- row.names(cluster_ls)[which(cluster_ls == clus)] # get list of all time windows sorted into the current cluster
#   
#   ### for each time window within this cluster ...
#   for(win in row_nms){
#     
#     subj_cur <- strsplit(win, split = '_tWin_')[[1]][1] # identify the subject of the current window
#     wind_cur <- strsplit(win, split = '_tWin_')[[1]][2] # identify the time points of current window
#     wind_cur <- paste0('tWin_', wind_cur)
#     
#     k_mat_indv  <- read.csv(file = file.path(subj_cur, 'roi_twindows', paste0(wind_cur, '.csv')), row.names = 1) # read in the time window data
#     
#     for(cell in 1:dim(k_mat_indv)[1] ) {
#       k_mat_indv[cell, cell] <- 0        # set main diagonal to be equal to zero
#     }
#     
#     ### sum the values of all of the matrices for this cluster
#     if(!exists('k_tmp_mat')) {
#       k_tmp_mat <- k_mat_indv
#     } else {
#       k_tmp_mat <- k_tmp_mat + k_mat_indv
#     }
#     
#   }
#   
#   k_tmp_mat <- k_tmp_mat/length(row_nms)      # calculate the average matrix
#   k_tmp_mat <- data.matrix(k_tmp_mat)         # transform the average matrix from a data.frame into a matrix
#   
#   print(paste('**** ', clus, ' ****'))
#   print(paste0('The Max = ', max(k_tmp_mat))) # QC; shouldn't be greater than 1.00
#   print(paste0('The Min = ', min(k_tmp_mat))) # QC; shouldn't be less than   -1.00
#   
#   assign(x = paste0('k_mat_', clus), value = k_tmp_mat) # save the new average matrix of the current cluster (clus) to the R environment
#   write.csv(x = k_tmp_mat, file = file.path(TOP_DIR, '..', 'k_clusters', paste0('kmat_', clus, '.csv')), row.names = F, col.names = F) # save the average matrix to a *.csv file
#   
#   
#   #### create a heatmap figure of the current cluster (clus)
#   par(mar=c(7,4,4,2)+0.1) 
#   
#   png(filename = file.path(TOP_DIR, '..', 'k_clusters', paste0('kmat_', clus, '.png')), width = 1500, height = 1500)
#   
#   heatmap.2(k_tmp_mat, 
#             main = paste0('cluster: ', clus, ' - Total # windows = ', length(row_nms)),
#             trace = 'none',
#             Rowv = F, 
#             Colv = F, 
#             scale = 'none', 
#             key = T, 
#             density.info = 'none', 
#             dendrogram = 'none',
#             key.xlab = NA, 
#             key.title = NA, 
#             labRow = labels,
#             labCol = labels,
#             col = heat_cols)
#   
#   dev.off()
#   
#   rm('k_tmp_mat')
#   
# }
# 
# rm( list = ls(pattern = '*_win_*') )
# rm( list = ls(pattern = 'k_met*') )
# rm( list = ls(pattern = 'kclus*') )
