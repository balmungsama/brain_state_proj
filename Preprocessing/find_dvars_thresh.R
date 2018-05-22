args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--PATH') {
    
    PATH <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

dvars_file <- paste0(COND, '_DVARS.val')
dvars_file <- file.path(PATH, 'mot_analysis' , dvars_file)

dvars = read.table(file = dvars_file, header = F)
dvars = dvars$V1

AD_dvars  = mad(dvars,constant = 1);
med_dvars = median(dvars);

thr_dvars = med_dvars + (AD_dvars * 1.5);
sum(dvars<thr_dvars)

# cat(thr_dvars)
# 
# plot(x=1:length(dvars), y=dvars, type = 'l');
# abline(h = thr_dvars);

##### comparing variances #####

dvars2                  <- dvars
dvars2[dvars>thr_dvars] <- NA
dvars3                  <- dvars2
dvars3[1]               <- NA

f_test <- var.test(dvars2, dvars3, na.rm=T)
p_val  <- format.pval(f_test$p.value)

if (grepl(pattern = ' ', x = p_val)) {
  p_val <- strsplit(p_val, split = ' ')[[1]][2]
}

p_val <- as.numeric(p_val)

print(paste('DVARS p-value: ', p_val))

if (p_val < 0.01) {
  DATE = system('date +%y-%m-%d', intern=T)
  command = paste('echo', PATH, '>>', paste0('logs/', DATE, '/outlier_report.log') )
  system(command = command)
}

cat(thr_dvars)

# plot(x=1:length(dvars), y=dvars, type = 'l');
# abline(h = thr_dvars);