### DEVELOPER'S NOTES 
## 
## Creating the plots for each k-cluster is broken. It uses the r-scores directly, 
## instead of the fisher-transformed values.
## 
## Move the code computing the correlations to behavioural performance to new script.

#TODO add win_sz and tskip to variable list
#TODO add hierchical clustering

# rm(list=ls())
require(stats)
require(grDevices)
require(gplots)
require(R.matlab)
require(psych)
require(ggplot2)

# TYPE        <- args[6]
# TOP_DIR     <- args[7]
# ROI_LABELS  <- args[8]
# lateralized <- args[9]
# kk          <- args[10]
# kk_reps     <- args[11]
# conf_lvl    <- args[12]
# kk_pool     <- args[13]
# win_sz      <- args[14]
# tskip       <- args[15]

##### test values #####

TYPE        <- 'group'
TOP_DIR     <- '/home/hpc3586/OSU_data/all_233'
ROI_LABELS  <- '/home/hpc3586/brain_state_proj/ROIs/labels/HarvardOxford.txt'
lateralized <- T
kk          <- 7
kk_reps     <- 1
conf_lvl    <- 0.95
kk_pool     <- 1
win_sz      <- 15
tskip       <- 1

##### main body #####

## stop the function if any of these variables are missing
required_variables  <- c('TOP_DIR', 'ROI_LABELS', 'lateralized', 'kk', 'kk_reps', 'conf_lvl', 'win_sz', 'tskip')
missing_requirements <- 0

for(req_var in required_variables) {
	missing_requirements <- as.numeric(!exists(req_var)) + missing_requirements
}

if(missing_requirements > 0) {
  stop
} else {

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

	if(TYPE == 'group') {
		subj_dirs <- list.dirs(TOP_DIR, recursive = F, full.names = F) # get the list of all participants to be used in the following loop
	} else if (TYPE == 'subj') {
		subj_dirs <- '/'
	} else {
		print("		Please select either 'group' or 'subj'")
		stop
	}

	for(subj in subj_dirs) {
		if ( length( list.files(file.path(TOP_DIR, subj, 'roi_tcourses'), recursive = F) ) == 0 ) {
			print(paste0('		Subject ', subj, ' does not have any time-window correlation matrices.'))
			next
		}       # check if correlation matrices for each time window exist. If it doesn't exist, skip to next participant
		
	  ##### create FC matrices #####
	  
	  roi_files <- list.files(file.path(TOP_DIR, subj, 'roi_tcourses'), recursive = F, pattern = '_tcourse.txt')
	  for ( roi in 1:length(roi_files) ) {
	    
	    if ( roi == 1 ) {
	      roi_tcourses <- read.table( file.path(TOP_DIR, subj, 'roi_tcourses', paste0('roi_', roi, '_tcourse.txt') ) )
	      print(roi_tcourses)
	      roi_tcourses <- matrix(data = roi_tcourses[,1], ncol = 1)
	      print(roi_tcourses)
	    } else {
	      roi_tcourses <- cbind(roi_tcourses, read.table( file.path(TOP_DIR, subj, 'roi_tcourses', paste0('roi_', roi, '_tcourse.txt') ) ))
	    }
	  }
	  
	  colnames(roi_tcourses) <- 1:length(roi_files)
	  
	  print(file.path(TOP_DIR, subj, 'roi_tcourses', 'cor_mats'))
	  dir.create(path = file.path(TOP_DIR, subj, 'roi_tcourses', 'cor_mats'), showWarnings = F ) 
	  
	  win_start <- 1
	  while ( win_start < length(roi_files) ) {
	    # browser()
	    
	    roi_cormat <- roi_tcourses[ win_start:(win_start + win_sz) , ]
	    roi_cormat <- cor(roi_cormat)
	    
	    print( file.path(TOP_DIR, subj, 'roi_tcourses', 'cor_mats', paste0('win_', win_start, '_', (win_start + win_sz), '.csv') ) )
	    write.csv(roi_cormat, file = file.path(TOP_DIR, subj, 'roi_tcourses', 'cor_mats', paste0('win_', win_start, '_', (win_start + win_sz), '.csv') ), row.names = T, col.names = T )
	    
	    win_start <- win_start + win_sz
	  }
	  
	  ##### read matrices #####
	  
		mat_files <- dir(path = file.path(TOP_DIR, subj, 'roi_tcourses')) # list all of the files contained within the roi timewindows folder
		
		### This loop is to read into R all time window matrices for all subjects
		for(mat in mat_files) {
			mat <- strsplit(mat, split = '.csv')[[1]][1]                                       # get the name of the time window for orgazational purposes
			assign(x = paste0(subj, '_', mat),                                                 # create a variable names after the subject and the corel matrix of the time window of interest
						 read.csv(file.path(TOP_DIR, subj, 'roi_tcourses', (paste0(mat, '.csv'))),   # populate the variable with the correlation matrix collected for the time window of interest
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

	print('		Running k-means clustering...')
	k_optim_tab <- data.frame(k_val = NA, BIC = NA, AIC = NA)   # create a table to contain the BIC/AIC information for each cluster
	for( k_val in kk ){
		print(paste0('		K = ', k_val))
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
	print('		DONE')

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
		
		geom_vline(mapping = aes(xintercept = kk[which(ksumm_BIC['Mean',] == min(ksumm_BIC['Mean',]))], colour = 'BIC'), size = 1, linetype = 'dashed', alpha = 0.4 ) +
		geom_vline(mapping = aes(xintercept = kk[which(ksumm_AIC['Mean',] == min(ksumm_AIC['Mean',]))], colour = 'AIC'), size = 1, linetype = 'dashed', alpha = 0.4 ) +
		
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

	master_k <- 4

	for(run in 1:kk_pool) {
		out_cluster <- kmeans(mat_stacked, centers = master_k)
		
		for(cur_clus in 1:master_k) {
			clus_avg <- matrix(data = 0L, nrow = dim(get(names(out_cluster$cluster[1])))[1], ncol = dim(get(names(out_cluster$cluster[1])))[1])
			clus_ls <- out_cluster$cluster[which(out_cluster$cluster == cur_clus)]
			clus_ls <- names(clus_ls)
			
			for(clus in clus_ls){
				tmp_mat <- data.matrix(get(clus)) - diag( dim(get(clus))[1] )
				clus_avg <- clus_avg + fisherz(tmp_mat)
			}
			
			clus_avg <- clus_avg / length(clus_ls)
			
			assign(x = paste0('k', cur_clus, '_v', run), value = clus_avg)
			
			##### Plotting the cluster
			colfunc <- colorRampPalette(c('#426DED', '#EDE742', '#ED4242')) # the colours defining the range to be used
			heat_cols <- colfunc(100)                                       # create a gradient of 100 colours between the 3 key colours defined above

			heatmap.2(clus_avg,
								main = paste0('Cluster ', cur_clus, ' - rep ', run),
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
								labCol = labels,
								col = heat_cols)
		}
	}
}

