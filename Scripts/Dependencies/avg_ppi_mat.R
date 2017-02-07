args <- commandArgs()

TOP_DIR  <- args[6]
TASK_NM  <- args[7]

COUNT    <- 0
mat_path <- 'ppi_results/construct_matrix/matrix'
out_path_csv <- file.path(TOP_DIR, 'whole_brain_ppi', paste0(TASK_NM, '_avg.csv') )
out_path_png <- file.path(TOP_DIR, 'whole_brain_ppi', paste0(TASK_NM, '_avg.png') )

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

##### Save the average matrix to a *.csv file #####
write.csv( x = avg_mat, file = out_path_csv, row.names = dim(avg_mat)[1], col.names = dim(avg_mat)[2] )

##### Create a plot of the average matrix and save it as a .png file #####

par(mar=c(7,4,4,2)+0.1)

png(filename = out_path_png, width = 1500, height = 1500)

colfunc <- colorRampPalette(c('#426DED', '#EDE742', '#ED4242')) # the colours defining the range to be used
heat_cols <- colfunc(100)  #  gradient of 100 colours b/w the 3 key colours defined above

heatmap.2(ppi_mat,
		  main = paste0(TASK_NM, ' - ** AVERAGED ** : whole-brain FC'),
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