rm(list=ls())
library(gplots)
library(grDevices)

TOP_DIR <- '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
setwd(TOP_DIR)

for(subj in list.dirs(TOP_DIR, recursive = F, full.names = F)){
  
  path_tcourse <- file.path(TOP_DIR, subj, 'roi_tcourses')
  
  ##### check to see if roi timecourse directory/files exist. If FALSE, skip to next
  if( !dir.exists(path_tcourse) ) {next}
  #####
  
  tcourses_all <- list.files(path_tcourse)
  
  unique_wins <- gsub(pattern = '\\S+_vol_', replacement = '', x = tcourses_all)
  unique_wins <- unique(unique_wins)
  
  unique_rois <- regexpr(pattern = '_vol_', text = tcourses_all)
  unique_rois <- substr(x = tcourses_all, start = 1, stop = unique_rois-1)
  unique_rois <- as.numeric(gsub(pattern = 'roi', replacement = '', x = unique_rois))
  unique_rois <- sort(unique(unique_rois))

  for(win in unique_wins){
    for(roi in unique_rois){
      
      tfile <- file.path(path_tcourse, paste0('roi', roi, '_vol_', win))
      col_roi <- data.frame(read.table(tfile))
      colnames(col_roi) <- roi
      
      if(!exists('tcourses_1win')) {
        tcourses_1win <- col_roi
      } else {
        tcourses_1win <- cbind(tcourses_1win, col_roi)
      }
      
    }
    
    cormat_twin <- cor(tcourses_1win, tcourses_1win)
    ind_na <- !is.na(cormat_twin)
    cormat_twin <- cormat_twin[-which(rowMeans(ind_na) == 0), -which(colMeans(ind_na) == 0)]
    
    label_win <- strsplit(x = win, split = '_tcourse')[[1]][1]
    
    dir.create(path = file.path(TOP_DIR, subj, 'corel_mats'), showWarnings = T)
    write.csv(x = cormat_twin, file = file.path(TOP_DIR, subj, 'corel_mats', paste0('win_', label_win, '.csv')), 
              row.names = T, 
              col.names = T )
    
    dir.create(path = file.path(TOP_DIR, subj, 'corel_figs'), showWarnings = T)
    colfunc <- colorRampPalette(c('#426DED', '#4AA9ED', '#EDE742', '#ED8642', '#ED4242'))
    heat_cols <- colfunc(100)
    heatmap.2(cormat_twin, 
              main = paste(subj, win, sep = ' - '),
              trace = 'none',
              Rowv = F, 
              Colv = F, 
              scale = 'none', 
              key = F, 
              density.info = 'none', 
              dendrogram = 'none',
              key.xlab = NA, 
              key.title = NA, 
              col = heat_cols)
    
    dev.off()
    png(filename = file.path(TOP_DIR, subj, 'corel_figs', paste0('win_', label_win, '.png')), width = 600, height = 600)
    
    rm('tcourses_1win')
    
  }
  
}