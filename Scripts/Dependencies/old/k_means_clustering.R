rm(list=ls())
library(stats)
library(grDevices)
library(gplots)
library(R.matlab)

TOP_DIR   <- '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
BEHAV_DIR <- '/media/member/Data1/OSU_allrawdata_backup/behav'
kk <- 7      # number of k clusters
lateralized = T

#### import brain roi labels ####
labels <- read.csv(file.path(TOP_DIR, '..', 'priv_john_proj', paste0('roi_labels.txt')), header = F)
labels2 <- NULL

if(lateralized == T){
  for(label in 1:dim(labels)[1]){
    lab_tmp <- paste(c('L.', 'R.'), as.character(labels[label, 1]))
    labels2 <- c(labels2, lab_tmp)
  }
}
labels <- labels2
rm('labels2')

subj_dirs <- list.dirs(TOP_DIR, recursive = F, full.names = T)
for(subj in subj_dirs) {
  
  ##### check if correlation matrices for each time window exist. If FALSE, skip to next
  if(!dir.exists(file.path(subj, 'corel_mats'))) {next}
  
  subj <- strsplit(subj, paste0(TOP_DIR, '/'))[[1]][2]
  mat_files <- list.files(path = file.path(TOP_DIR, subj, 'corel_mats'))
  for(mat in mat_files) {
    mat <- strsplit(mat, split = '.csv')[[1]][1]
    assign(x = paste0(subj, '_', mat), 
           read.csv(file.path(TOP_DIR, subj, 'corel_mats', (paste0(mat, '.csv'))), 
                    row.names = 1,
                    header = T, 
                    check.names = F) )
  }
}

mat_list <- ls(pattern = '*_win_*')

for(mat in mat_list){
  tmp_mat <- get(mat)
  for(ent_row in 1:dim(tmp_mat)[1]){
    for(ent_col in 1:dim(tmp_mat)[1]){
      if(ent_row >= ent_col){
        tmp_mat[ent_row, ent_col] <- NA
      }
    }
  }
  tmp_mat <- data.matrix(tmp_mat)
  tmp_mat <- c(tmp_mat)
  tmp_mat  <- tmp_mat[complete.cases(tmp_mat)]
  assign(x = mat, value = tmp_mat)
  
  if(!exists('mat_stacked')){
    mat_stacked <- matrix(data = get(mat), nrow = 1)
  } else {
    mat_stacked <- rbind(mat_stacked, get(mat))
  }
}
mat_stacked <- data.frame(mat_stacked, row.names = mat_list)

out_cluster <- kmeans(data.matrix(mat_stacked), centers = kk)
cluster_ls  <- data.matrix(out_cluster$cluster)
colnames(cluster_ls) <- NULL


##### save the clusters
dir.create(file.path(TOP_DIR, '..', 'k_clusters'))
dir.create(file.path(TOP_DIR, '..', 'k_clusters', 'nifti_imgs'))
write.csv(x = cluster_ls, file = file.path(TOP_DIR, '..', 'k_clusters', paste0('ls_clusters.csv')))


for(clus in as.numeric(unique(cluster_ls))) {
  subj_dirs <- NULL
  
  row_nms   <- row.names(cluster_ls)[which(cluster_ls == clus)]
  
  for(row in 1:length(row_nms)){
    row_nms[row] <- file.path(TOP_DIR, strsplit(row_nms[row], '_win_')[[1]][1], 
                              'win_vols',
                              paste0('vol_', strsplit(row_nms[row], '_win_')[[1]][2], '.nii.gz') )
  }
  
  assign(x = paste0('kclus_', clus), value =  row_nms)
  write.table(x = get(paste0('kclus_', clus)), file = file.path(TOP_DIR, '..', 'k_clusters', paste0('kclus_', clus, '.txt')), 
              row.names = F, 
              col.names = F)
  
  subj_dirs <- NULL
}


###### create the average cluster matrices #####

colfunc <- colorRampPalette(c('#426DED', '#4AA9ED', '#EDE742', '#ED8642', '#ED4242'))
heat_cols <- colfunc(100)

for( clus in sort(as.numeric(unique(cluster_ls))) ) {
  
  subj_dirs <- NULL
  
  row_nms   <- row.names(cluster_ls)[which(cluster_ls == clus)]
  
  rm('k_tmp_mat')
  for(win in row_nms){
    
    subj_cur <- strsplit(win, split = '_win_')[[1]][1]
    wind_cur <- strsplit(win, split = '_win_')[[1]][2]
    wind_cur <- paste0('win_', wind_cur)
    
    k_mat_indv <- read.csv(file = file.path(TOP_DIR, subj_cur, 'corel_mats', paste0(wind_cur, '.csv')), row.names = 1)
    
    if(!exists('k_tmp_mat')) {
      k_tmp_mat <- k_mat_indv
    } else {
      k_tmp_mat <- k_tmp_mat + k_mat_indv
    }
    
  }
  
  k_tmp_mat <- k_tmp_mat/length(row_nms)
  k_tmp_mat <- data.matrix(k_tmp_mat)
  assign(x = paste0('k_mat_', clus), value = k_tmp_mat)
  write.csv(x = k_tmp_mat, file = file.path(TOP_DIR, '..', 'k_clusters', paste0('kmat_', clus, '.csv')), row.names = F, col.names = F)
  
  par(mar=c(7,4,4,2)+0.1) 
  
  png(filename = file.path(TOP_DIR, '..', 'k_clusters', paste0('kmat_', clus, '.png')), width = 1000, height = 1000)
  
  heatmap.2(k_tmp_mat, 
            main = paste0('cluster: ', clus, ' - Total # windows = ', length(row_nms)),
            trace = 'none',
            Rowv = F, 
            Colv = F, 
            scale = 'none', 
            key = T, 
            density.info = 'none', 
            dendrogram = 'none',
            key.xlab = NA, 
            key.title = NA, 
            labRow = labels,
            labCol = label, 
            col = heat_cols)
  
  dev.off()
  
}

rm( list = ls(pattern = '*_win_*') )
rm( list = ls(pattern = 'k_met*') )
rm( list = ls(pattern = 'kclus*') )

#### perform correlations #####

# cluster_ls
subj_ls <- NULL
for(ii in 1:dim(cluster_ls)[1]){
  subj_cur <- rownames(cluster_ls)[ii]
  subj_cur <- strsplit(subj_cur, split = '_win_')[[1]][1]
  subj_ls <- c(subj_ls, subj_cur)
}

subj_ls <- unique(subj_ls)

tally_tab <- data.frame(matrix(data = NA, nrow = 1, ncol = length(unique(cluster_ls))))
colnames(tally_tab) <- sort(as.numeric(unique(cluster_ls)))
for(subj in subj_ls){
  subj_tab <- cluster_ls[which(grepl(rownames(cluster_ls), pattern = subj)), 1 ]
  subj_vec <- NULL
  
  for(clus in sort(as.numeric(unique(cluster_ls))) ) {
    subj_vec <- c(subj_vec, length(which(subj_tab == clus, arr.ind = F)) )
  }
  
  subj_vec <- t(data.frame(subj_vec))
  rownames(subj_vec) <- subj
  colnames(subj_vec) <- colnames(tally_tab)
  
  tally_tab <- rbind(tally_tab, subj_vec)
}
tally_tab <- tally_tab[-1, ]


###### import behavioural data #####

conditions <- c('go', 'nogo')

behav_tab <- data.frame(matrix(data = NA, nrow = 1, ncol = 2 ))
colnames(behav_tab) <- c('GORT', 'NogoErr')

for(subj in subj_ls) {
  behav_subj <- readMat(file.path(BEHAV_DIR, paste0(subj, 'ZL_GoNogo.mat')))
  
  subj_gort     <- mean(behav_subj$rec[ which(behav_subj$rec[,2] == 1) ,4], na.rm = T)
  
  subj_nogo_err <- behav_subj$rec[ which(behav_subj$rec[,2] == 2) ,4]
  subj_nogo_err <- mean(!is.na(subj_nogo_err))
  
  subj_behav_row <- data.frame(GORT = subj_gort, NogoErr = subj_nogo_err)
  rownames(subj_behav_row) <- subj
  
  behav_tab <- rbind(behav_tab, subj_behav_row)
}
behav_tab <- behav_tab[-1, ]

##### correlations #####

for(bb in 1:dim(behav_tab)[2] ) {
  
  print(paste('* * *', colnames(behav_tab)[bb], '* * *'))
  
  for(kk in 1:dim(tally_tab)[2] ) {
    assign(x = paste0('cor_', colnames(tally_tab)[kk], '_', colnames(behav_tab)[bb]), value = cor.test(tally_tab[, kk], behav_tab[, bb]))
    print(paste0('cor_k', colnames(tally_tab)[kk], '_', colnames(behav_tab)[bb]))
    print(get( paste0('cor_', colnames(tally_tab)[kk], '_', colnames(behav_tab)[bb]) ))
  }
}

