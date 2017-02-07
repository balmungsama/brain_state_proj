args <- commandArgs()

TOP_DIR  <- args[6]
TASK_NM  <- args[7]
COUNT    <- 0
mat_path <- 'ppi_results/construct_matrix/matrix'
out_path <- file.path(TOP_DIR, 'whole_brain_ppi', paste0(TASK_NM, '_avg.csv') )

dir.create( file.path(TOP_DIR, 'whole_brain_ppi') )
subj_ls <- dir(TOP_DIR, all.files = F, recursive = F)

for(subj in subj_ls) {
	COUNT <- COUNT + 1

	sub_path <- file.path(TOP_DIR, subj, mat_path)

	if(!exists('avg_mat')){
		avg_mat <- read.csv( file.path(sub_path, paste0(subj, '_', TASK_NM, '.csv')), row.names = 1, col.names = 1 )
	} else {
		tmp_mat <- read.csv( file.path(sub_path, paste0(subj, '_', TASK_NM, '.csv')), row.names = 1, col.names = 1 )
		avg_mat <- avg_mat + tmp_mat
	}
}

avg_mat <- avg_mat/COUNT

write.csv( x = avg_mat, file = out_path, row.names = dim(avg_mat)[1], col.names = dim(avg_mat)[2] )