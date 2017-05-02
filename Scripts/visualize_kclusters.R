require(data.table)
require(R.matlab)
require(corrplot)

kmeans_dir <- "/home/hpc3586/OSU_data/kmeans"
group_dir  <- "/home/hpc3586/OSU_data/all_233"

subj_wins  <- fread(file = file.path(kmeans_dir, '20correl_rows.csv'), sep=",", select = 1)
kmeans.out <- readMat(file.path(kmeans_dir, '20kmeans_out.mat'))

kmeans.out <- kmeans.out$kmeans.output
kmeans.out <- kmeans.out[,,1]

kmeans.cluster <- kmeans.out$cluster

for (row in 1:dim(subj_wins)[1]) {
	
	
	win_IDs.tmp <- strsplit(as.character(subj_wins[row]), split = '_')[[1]]
	
	
	if ( exists('win_IDs') ) {
		win_IDs.tmp <- data.frame(subjID = win_IDs.tmp[1], winStart = win_IDs.tmp[2], winEnd = win_IDs.tmp[3])
		win_IDs     <- rbind(win_IDs, win_IDs.tmp)
	} else {
		win_IDs <- data.frame(subjID = win_IDs.tmp[1], winStart = win_IDs.tmp[2], winEnd = win_IDs.tmp[3])
	}
	
}

print('number one')

win_IDs$cluster <- kmeans.cluster

print('number two')

for (kk in sort(unique(kmeans.cluster)) ) {
	
	print('number three')
	
	win_IDs.kk.tmp <- win_IDs[which(win_IDs$cluster == kk),]
	
	kk_count <- 0
	
	for (window in 1:dim(win_IDs.kk.tmp)[1] ) {
		
		print('number four')
		
		FCmat.tmp.nm <- paste0('win_', win_IDs.kk.tmp$winStart[window], '_', win_IDs.kk.tmp$winEnd[window], '.csv')
		
		print('number four.one')
		
		FCmat.tmp    <- read.csv(file = file.path(group_dir, win_IDs.kk.tmp$subjID[window], 'roi_tcourses', 'cor_mats', FCmat.tmp.nm), row.names = NULL, header = T )
		FCmat.tmp    <- FCmat.tmp[, -1]
		
		print('number four.two')
		
		if ( exists( paste0('clustermat_', kk) ) == F ) {
			assign(x = paste0('clustermat_', kk), value = FCmat.tmp)
		} else {
			assign(x = paste0('clustermat_', kk), value = get(paste0('clustermat_', kk)) + FCmat.tmp )
		}
		
		kk_count <- kk_count + 1
		
	}
	
	print('number five')
	assign(x = paste0('clustermat_', kk), value = get(paste0('clustermat_', kk)) / kk_count )
	
	print('number six')
	
	png(filename = file.path(kmeans_dir, paste0('cluster_', kk, '.png') ) )
	corrplot(corr = get(paste0('clustermat_', kk)) , diag = F, title = paste0('Cluster ', kk) )
	dev.off()
	
	write.csv(x = get( paste0('clustermat_', kk) ), file = file.path(kmeans_dir, paste0('clustermat_', kk, '.csv') ) )
	
}



