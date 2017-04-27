rm(list=ls())
library(gplots)
library(grDevices)

TOP_DIR <- '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
t_win   <- 15
t_skip  <- 5


setwd(TOP_DIR)

for(subj in list.dirs(TOP_DIR, recursive = F, full.names = F)){
  
  path_tcourse <- file.path(TOP_DIR, subj, 'roi_tcourses')                    
  
  ##### check to see if roi timecourse directory/files exist. If FALSE, skip to next
  if( !dir.exists(path_tcourse) ) {next}
  #####
  
  print(subj)
  
  roi_twindow_dir <- file.path(TOP_DIR, subj, 'roi_twindows')
  dir.create(roi_twindow_dir)
  dir.create(file.path(TOP_DIR, subj, 'plots'))
  
  tcourses_all <- list.files(path_tcourse, full.names = F)
  
  n_pts    <- dim(read.table(file = file.path(path_tcourse, tcourses_all[1])))[1]
  start_pt <- n_pts - (t_skip * as.integer(n_pts / t_skip) )
  
  unique_rois <- gsub(pattern = '_tcourse.txt', x = tcourses_all, replacement = '')
  unique_rois <- gsub(pattern = 'roi', x = unique_rois, replacement = '')
  unique_rois <- sort(as.numeric(unique(unique_rois)))
  
  roi_tab <- matrix(data = NA, ncol = length(unique_rois), nrow = t_win)
  colnames(roi_tab) <- unique_rois
  
  cur_pt <- start_pt
  
  while (cur_pt <= (n_pts - t_win) ) {
    
    for(roi in unique_rois){
      roi_tmp           <- read.table(file.path(path_tcourse, paste0('roi', roi, '_tcourse.txt') ), colClasses = 'numeric' )
      colnames(roi_tmp) <- roi
      
      roi_win <- roi_tmp[cur_pt:(cur_pt + t_win - 1), 1]
      
      roi_tab[, as.character(roi)] <- roi_win
      
      roi_fc_win <- cor(roi_tab, roi_tab)
      row_rm <- rowSums(abs(roi_fc_win), na.rm = T)
      row_rm <- as.numeric(which(row_rm == 0))
      col_rm <- colSums(abs(roi_fc_win), na.rm = T)
      col_rm <- as.numeric(which(col_rm == 0))
      roi_fc_win <- roi_fc_win[-row_rm, -col_rm]
      roi_fc_win <- data.matrix(roi_fc_win)
    }
    
    write.csv(x = roi_fc_win, file = file.path(roi_twindow_dir, paste0('tWin_', cur_pt, '_', (cur_pt + t_win), '.csv' ) ), row.names = T, col.names = T)
    
    # dir.create(path = file.path(TOP_DIR, subj, 'corel_figs'), showWarnings = T)
    colfunc <- colorRampPalette(c('#426DED', '#4AA9ED', '#EDE742', '#ED8642', '#ED4242')) 
    heat_cols <- colfunc(100)
      
    png(filename = file.path(TOP_DIR, subj, 'plots', paste0('tWin_', cur_pt, '_', (cur_pt + t_win), '.png' ) ), width = 1000, height = 1000)
      
    heatmap.2(roi_fc_win,
              main = paste(subj, paste0('timepoints ', cur_pt, ' to ', (cur_pt + t_win)) , sep = ' - '),
              trace = 'none',
              Rowv = F,
              Colv = F,
              scale = 'none',
              key = T,
              density.info = 'none',
              dendrogram = 'none',
              key.xlab = NA,
              key.title = NA,
              col = heat_cols)
    dev.off()
    
    cur_pt <- cur_pt + t_skip
    
  }
  
}