TASK_NM <- args[6]
PPI_DIR <- args[7]

ppi_ls <- dir(PPI_DIR, pattern = paste0('*_', TASK_NM, '.txt'))
roi_ls <- c()

for (ppi in ppi_ls) {
  roi_nm <- strsplit(ppi, split = '_')[[1]][1]
  roi_nm <- strsplit(roi_nm, split = 'roi')[[1]][2]
  roi_nm <- as.numeric(roi_nm)
  roi_ls <- c(roi_ls, roi_nm)
}

roi_ls  <- sort(roi_ls)
ppi_mat <- 

for(roi_1 in roi_ls) {

    tmp_row_vec <- c()

    for(roi_2 in roi_ls) {
        filename    <- paste0('roi', roi_1, '_roi', roi_2, '_', TASK_NM, '.txt')
        roi_1x2_val <- as.numeric(read.table(file = file.path(TOP_DIR, filename)))
        tmp_row_vec <- c(tmp_row_vec, roi_1x2_val)
    }
}