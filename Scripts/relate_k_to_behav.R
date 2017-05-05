require(data.table)
require(R.matlab)
require(ggplot2)

kmeans_dir <- "/mnt/c/Users/john/Desktop/tmp_kmeans"
behav_dir  <- "/mnt/c/Users/john/Desktop/tmp_kmeans/behav"

task       <- "GoNogo"

subj_wins  <- fread(file = file.path(kmeans_dir, '20correl_rows.csv'), sep=",", select = 1)
kmeans.out <- readMat(file.path(kmeans_dir, '20kmeans_out.mat'))

kmeans.out <- kmeans.out$kmeans.output
kmeans.out <- kmeans.out[,,1]

kmeans.cluster <- kmeans.out$cluster

##### bootstrap correlation confidence intervals #####

f <- function(d, i){
	d2 <- d[i,]
	d2.x1 <- d2$x1
	d2.x2 <- d2$x2
	
	value <- fun(d2.x1, d2.x2)
	value <- as.numeric(value)
	
	return(value)
}

boot.CI <- function(X.in, fun, R, Use, ...){
	require(boot)
	boot.stat <- boot(X.in, statistic = f, R = R)
	return(boot.stat)
}

##### permutation tests for correlations #####

permuCor <- function(x1, x2, 
										 fun = cor, 
										 nsims = 1000, p = 0.05, var.names = NULL, plot = TRUE, boot.CI = TRUE, CI.thresh = 0.95, plot.title = NULL, ...) {
	require(ggplot2)
	
	if(is.null(var.names)){
		var.names <- c('x1', 'x2')
	}
	
	# browser()
	na_ind <- NULL
	if(sum(is.na(x1)) > 0) {
		na_ind <- c(na_ind, which(is.na(x1)))
	}
	if(sum(is.na(x2)) > 0) {
		na_ind <- c(na_ind, which(is.na(x2)))
	}
	
	if( length(na_ind) > 0 ) {
		x1 <- x1[-na_ind]
		x2 <- x2[-na_ind]
	}
	
	
	fun <<- fun
	# Use <<- Use
	obs.val <- fun(x1, x2)
	
	pool.vals <- c(x1, x2)
	pool.labs <- c(rep('x1', length(x1)), rep('x2', length(x2)))
	
	out.sim  <- NULL
	for(sim in 1:nsims){
		
		# labs.sim <- sample(pool.labs, replace = FALSE)
		# tab.sim  <- data.frame(names = labs.sim, values = pool.vals)
		pool.vals[which(pool.labs == 'x2')] <- sample(pool.vals[which(pool.labs == 'x2')], replace = FALSE)
		tab.sim  <- data.frame(names = pool.labs, values = pool.vals)
		
		x1.sim   <- tab.sim$values[which(tab.sim$names=='x1')]
		x2.sim   <- tab.sim$values[which(tab.sim$names=='x2')]
		
		out.sim[sim] <- fun(x1.sim, x2.sim)
		
		# cat(x2.sim, '\n')
	}
	
	# compute the bootstrap confidence intervals for the function of interest
	if(boot.CI == T){
		# pool.tab  <- data.frame(names = pool.labs, values = pool.vals)
		boot.tab  <- data.frame(x1 = x1, x2 = x2)
		
		boot.stat <- boot.CI(X.in = boot.tab, fun = fun, R = nsims)
		boot.CI   <- boot.ci(boot.stat, type='perc', conf = CI.thresh)
	}
	rm(fun, envir = .GlobalEnv)
	
	if(plot==TRUE){
		boot.xmin <- boot.CI$percent
		boot.xmax <- boot.CI$percent
		boot.xmin <- as.numeric(boot.xmin[length(boot.xmin)-1])
		boot.xmax <- as.numeric(boot.xmax[length(boot.xmax)  ])
		
		xmax <- boot.xmax
		xmin <- boot.xmin
		fig1 <- ggplot() +
			geom_histogram(mapping = aes(x = out.sim), bins=30, alpha = 1) +
			geom_rect(aes(xmin = boot.xmin,
										xmax = boot.xmax,
										ymin = 0,
										ymax = Inf), fill='pink', alpha = 0.3) +
			geom_vline(xintercept = c(boot.xmin, 
																boot.xmax), 
								 size = 1, colour='pink', alpha=0.5) +
			xlab('test statistic') +
			geom_vline(xintercept = obs.val, colour = 'red', alpha = 1, size = 1) +
			
			geom_vline(xintercept = obs.val, colour = 'red', alpha = 1) + 
			annotate('text', x = obs.val, y = nsims/100, label = signif(obs.val, digits = 3), fontface=2, size=5, colour='gray90') +
			theme_minimal() +
			theme(axis.line.x = element_line(size = 0.5, colour = "black"),
						axis.line.y = element_line(size = 0.5, colour = "black"),
						panel.grid.major = element_line(size = 0, colour = 'white'),
						panel.grid.minor = element_line(size = 0, colour = 'white')) +
			theme(plot.title = element_text(hjust = 0.5)) + 
			scale_y_continuous(expand = c(0,0)) +
			ggtitle(plot.title)
		
		print(fig1)
	}
	
	# out.sim <<- out.sim
	p.val <- mean(abs(out.sim) > abs(obs.val))
	
	if(p.val < p){
		sig.lab <- '  *  '
	} else {
		sig.lab <- '     '
	}
	
	theList <- list(title = plot.title,
									var.names = var.names, 
									test.stat = obs.val,
									boot.conf.int = data.frame(Level = paste0(CI.thresh*100, '%   '), 
																						 Percentile = paste0('(', signif(boot.xmin, 4), ', ', signif(boot.xmax, 4), ')' ) ),
									significance = data.frame(p.val = p.val, sig = sig.lab))
	
	return(theList)
}

##### split mat file #####

for (row in 1:dim(subj_wins)[1]) {
	
	
	win_IDs.tmp <- strsplit(as.character(subj_wins[row]), split = '_')[[1]]
	
	
	if ( exists('win_IDs') ) {
		win_IDs.tmp <- data.frame(subjID = win_IDs.tmp[1], winStart = win_IDs.tmp[2], winEnd = win_IDs.tmp[3])
		win_IDs     <- rbind(win_IDs, win_IDs.tmp)
	} else {
		win_IDs <- data.frame(subjID = win_IDs.tmp[1], winStart = win_IDs.tmp[2], winEnd = win_IDs.tmp[3])
	}
	
}

##### create participant data frame #####

anal.data <- data.frame(subjID = unique(win_IDs$subjID))

for (subj in anal.data$subjID) {
	print(subj)
	subj.mat <- win_IDs[ which(win_IDs$subjID == subj), ]
	
	for (state in sort(unique(win_IDs$cluster)) ) {
		
		state.freq <- mean(subj.mat$cluster == state)
		anal.data[ which(anal.data$subjID == subj) , paste('k', state)] <- state.freq
		
	}
	
	subj.behav               <- readMat(file.path(behav_dir, paste0(subj, '_', task, '.mat') ))
	colnames(subj.behav$rec) <- unlist(subj.behav$p[,,1]$recLabel)
	subj.behav               <- as.data.frame(subj.behav$rec)
	
	subj.behav.acc <- subj.behav[ which(subj.behav$iCondition == 2), ]
	subj.behav.acc <- is.na( subj.behav.acc$RT )
	subj.behav.acc <- mean( subj.behav.acc )

	subj.behav.spe <- subj.behav[ which(subj.behav$iCondition == 1), ]
	subj.behav.spe <- mean(subj.behav.spe$RT, na.rm = T)
	subj.behav.spe <- 1 / subj.behav.spe
	
	anal.data[ which(anal.data$subjID == subj) , 'Nogo Accuracy'  ] <- subj.behav.acc
	anal.data[ which(anal.data$subjID == subj) , 'Response Speed' ] <- subj.behav.spe
}

##### correlate brain state frequency with behaviour #####

k.col.ind     <- colnames(anal.data)
k.col.ind     <- which(startsWith(k.col.ind, 'k ') == T)
behav.col.ind <- c(1:dim(anal.data)[2])
behav.col.ind <- behav.col.ind[ -c(1, k.col.ind)]

for ( state in k.col.ind ) {
	for (behav in behav.col.ind) {
		k.cor <- permuCor(x1 = anal.data[, state], 
											x2 = anal.data[, behav], 
											nsims = 5000, 
											var.names = c(colnames(anal.data)[state], colnames(anal.data)[behav]), 
											plot.title = paste0('Correlation Between Brain state ', colnames(anal.data)[state], ' & ', colnames(anal.data)[behav]) )
		print(k.cor)
	}
}






