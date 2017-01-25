### Calculate AIC & BIC values
##  Taken from http://stackoverflow.com/a/25557162
##  

kmeans_AIC.BIC = function(fit){
	m = ncol(fit$centers)
	n = length(fit$cluster)
	k = nrow(fit$centers)
	D = fit$tot.withinss
	return(data.frame(AIC = D + 2 * m * k,
					  BIC = D + log(n) * m * k))
}

