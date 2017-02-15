require(ggplot2)
require(reshape2)
require(GGally)
require(base)
require(R.matlab)

rm(list = ls())

source("C:/Users/john/OneDrive/2015/McIntosh_Lab/Project\ Development/Proposal/Given\ data/RAW\ SART/scripts/bootstrap/bootFunc_Corr.R")
source("C:/Users/john/OneDrive/2015/McIntosh_Lab/Project\ Development/Proposal/Given\ data/RAW\ SART/scripts/permutation/permutCor.R")

TOP_DIR   <- "C:/Users/john/Desktop/k_clusters/r"
BEHAV_DIR <- "C:/Users/john/Desktop/k_clusters/behav"
setwd(TOP_DIR)

roi_labels <- as.character(read.csv('C:/Users/john/Desktop/k_clusters/lat_roi_labels.csv'))
mat_list   <- dir(TOP_DIR, pattern = "cluster_summ_*")

for(mat in mat_list){
  table <- read.csv(file.path(TOP_DIR, mat), row.names = 1)
  
  p <- ggcorr(table, 
              geom = 'tile', 
              label_alpha = F, 
              label_round = 3, 
              high = '#ED4242', mid = '#EDE742', low = '#426DED', 
              size = 2.5,
              hjust = 2, 
              layout.exp = 2, 
              name = '   r')
  
  print(p)
}

##### Create k cluster frequency table #####

cluster_ls <- read.csv('ls_clusters_k7_rep1.csv', row.names = 1)
subj_nms   <- unlist(strsplit(row.names(cluster_ls), split = '_'))
subj_nms   <- subj_nms[ rep(c(T, F, F, F), length(subj_nms)/4) ]
subj_nms   <- unique(subj_nms)

for(subj in subj_nms){
  row_ind <- grepl(pattern = paste0(subj, "*"), row.names(cluster_ls))
  row_ind <- which(row_ind == T)
  
  tmp_row <- matrix(NA, nrow = 1, ncol = length(mat_list))
  row.names(tmp_row) <- subj
  
  for(kk in 1:length(mat_list)){
    kk_freq <- length(which(cluster_ls[row_ind,1] == kk)) / length(cluster_ls[row_ind,1])
    # if(kk==3 | kk ==5) {print(kk_freq)}
    tmp_row[1, kk] <- kk_freq
  }
  
  if(!exists('freq_matrix')) {
    freq_matrix <- tmp_row
  } else {
    freq_matrix <- rbind(freq_matrix, tmp_row)
  }
  
}

##### import behavioural data #####

task_ls <- c('GoNogo', 'WorkingMem')

## GoNogo ##
for(subj in subj_nms){
  tmp_row   <- matrix(NA, ncol = 2, nrow = 1)
  row.names(tmp_row) <- subj
  colnames(tmp_row)  <- c('GoSpeed', 'ErrorRate')
  
  behav_mat <- readMat(file.path(BEHAV_DIR, paste0(subj, "_", task_ls[1], '.mat')))
  behav_mat <- behav_mat$rec
  
  tmp_speed <- 1 / mean(behav_mat[ which(behav_mat[, 2] == 1) , 4], na.rm = T)
  tmp_acc   <- behav_mat[which(behav_mat[,2] == 2), 4]
  tmp_acc   <- mean( is.na(tmp_acc) )
  
  tmp_row[1, 1] <- tmp_speed
  tmp_row[1, 2] <- tmp_acc
  
  if(!exists('behav_summ_mat')){
    behav_summ_mat <- tmp_row
  } else {
    behav_summ_mat <- rbind(behav_summ_mat, tmp_row)
  }
  
}
## results for GoNogo ##
for( kk in 1:length(mat_list) ){
  for( behav in 1:dim(behav_summ_mat)[2] ) {
    
    print(paste0( 'GoNogo:  K = ', kk, ' ~ ', colnames(behav_summ_mat)[behav] ))
    
    # result <- cor.test(freq_matrix[, kk], behav_summ_mat[, behav])
    
    result <- permuCor(x1 = freq_matrix[, kk], x2 = behav_summ_mat[, behav],
                       plot.title = paste0('permCorr: K=', kk, ' ~ ', colnames(behav_summ_mat)[behav]), nsims = 5000 )
    print(result)
    
    print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
  }
}

## Working Memory ##
for(subj in subj_nms){
  tmp_row   <- matrix(NA, ncol = 1, nrow = 1)
  row.names(tmp_row) <- subj
  colnames(tmp_row)  <- c('Accuracy')
  
  behav_mat <- readMat(file.path(BEHAV_DIR, paste0(subj, "_", task_ls[2], '.mat')))
  behav_mat <- behav_mat$rec
  
  tmp_row[1,1]   <- mean(behav_mat[ which(behav_mat[,2] == 2) ,5], na.rm = T)
  
  if(!exists('nbk_summ_mat')) {
    nbk_summ_mat <- tmp_acc
  } else {
    nbk_summ_mat <- rbind(nbk_summ_mat, tmp_row)
  }
}

## results for Working Memory ##
for( kk in 1:length(mat_list) ) {
  for(behav in 1:dim(nbk_summ_mat)[2]) {
    print(paste0( 'WorkingMem:  K = ', kk, ' ~ ', colnames(nbk_summ_mat)[behav] ))
    
    
    # result <- cor.test(freq_matrix[, kk], nbk_summ_mat[, behav])
    result <- permuCor(x1 = freq_matrix[, kk], x2 = nbk_summ_mat[, behav],
                       plot.title = paste0('permCorr: K=', kk, ' ~ ', colnames(nbk_summ_mat)[behav]), nsims = 5000 )
    print(result)
    
    
    print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
  }
}

