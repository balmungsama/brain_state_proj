args <- commandArgs()
require(gplots)

TASK_NM <- args[6]
PPI_DIR <- args[7]
OUT_DIR <- file.path(PPI_DIR, 'matrix')

ppi_ls  <- dir(PPI_DIR, pattern = paste0('*_', TASK_NM, '.txt'))
roi_ls  <- c()
subj_nm <- strsplit(PPI_DIR, '/')[[1]][ length(strsplit(PPI_DIR, '/')[[1]]) - 2 ]

dir.create(OUT_DIR)

for (ppi in ppi_ls) {
  roi_nm <- strsplit(ppi, split = '_')[[1]][1]
  roi_nm <- strsplit(roi_nm, split = 'roi')[[1]][2]
  roi_nm <- as.numeric(roi_nm)
  roi_ls <- c(roi_ls, roi_nm)
}

roi_ls  <- sort(unique(roi_ls))
ppi_mat <- matrix(data = NA, ncol = length(roi_ls), nrow = length(roi_ls))
dimnames(ppi_mat) <- list(roi_ls, roi_ls)

COUNT <- 0
for(roi_1 in roi_ls) {
    COUNT <- COUNT + 1

    tmp_row_vec <- c()

    for(roi_2 in roi_ls) {
        filename    <- paste0('roi', roi_1, '_roi', roi_2, '_', TASK_NM, '.txt')
        roi_1x2_val <- as.numeric(read.table(file = file.path(PPI_DIR, filename)))
        tmp_row_vec <- c(tmp_row_vec, roi_1x2_val)
    }

    ppi_mat[COUNT,] <- tmp_row_vec
}

write.csv(x = ppi_mat, file = file.path(OUT_DIR, paste0(TASK_NM, '_', length(roi_ls), 'x', length(roi_ls), '.csv')) )

par(mar=c(7,4,4,2)+0.1)

png(filename = file.path(OUT_DIR, paste0(TASK_NM, '_', length(roi_ls), 'x', length(roi_ls), '.png')), width = 1500, height = 1500)

colfunc <- colorRampPalette(c('#426DED', '#EDE742', '#ED4242')) # the colours defining the range to be used
heat_cols <- colfunc(100)  #  gradient of 100 colours b/w the 3 key colours defined above

heatmap.2(ppi_mat,
          main = paste0(TASK_NM, ' - subj ', subj_nm,   ' : whole-brain FC'),
          trace = 'none',
          Rowv = F,
          Colv = F,
          scale = 'none',
          key = T,
          density.info = 'none',
          dendrogram = 'none',
          key.xlab = NA,
          key.title = NA,
          # labRow = labels,
          # labCol = labels,
          col = heat_cols)

dev.off()

system(paste0('rm ', PPI_DIR, '/*', TASK_NM, '.txt'))
