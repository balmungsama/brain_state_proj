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

cat(thr_dvars)

# plot(x=1:length(dvars), y=dvars, type = 'l');
# abline(h = thr_dvars);