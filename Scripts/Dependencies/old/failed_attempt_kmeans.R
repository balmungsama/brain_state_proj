rm(list=ls())
library(stats)

TOP_DIR <- '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john_testdir'

subj_dirs <- list.dirs(TOP_DIR, recursive = F, full.names = T)
for(subj in subj_dirs) {
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

kmeans(data.matrix(mat_stacked), centers = 4)
