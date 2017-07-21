##### load libraries #####

library(corrplot)

##### accepting arguments #####

args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--SUBJ_DIR') {
    
    SUBJ_DIR <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

##### main script #####

roi_files <- list.files( file.path(SUBJ_DIR, 'QualityControl', 'roi_tcourses'), full.names = T)

for (roi in roi_files) {
  
  roi_label <- strsplit( basename(roi) , '.txt')[[1]]
  
  roi <- read.table(file = roi, header = F, col.names = roi_label)
  
  if ( exists('roi_tcourses') == F) {
    roi_tcourses <- roi
  } else {
    roi_tcourses <- cbind(roi_tcourses, roi)
  }
  
}

##### create FC matrix #####

FC_mat <- cor(roi_tcourses) - diag( length(roi_files) )

##### save FC matrix into text file #####

write.csv(FC_mat, file = file.path(SUBJ_DIR, 'QualityControl', paste0(COND, '_DMN_FC.csv')), row.names = T, col.names = T)

##### save FC matrix to .png #####

png( file =  file.path(SUBJ_DIR, 'QualityControl', paste0(COND, '_DMN_FC.png')), width = 800, height = 800)

plot_label <- basename(SUBJ_DIR)
plot_label <- paste('QC1 FC', COND, plot_label, sep = ' - ')
  
corrplot(FC_mat, method = 'color', add = F, col = colorRampPalette(c("blue","white","red"))(200), mar = c(0,0,1,0), title = plot_label)


dev.off()



