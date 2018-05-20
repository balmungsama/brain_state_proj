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

fd_file <- paste0(COND, '_FD.val')
fd_file <- file.path(PATH, 'mot_analysis' , fd_file)

fd = read.table(file = fd_file, header = F)
fd = fd$V1

AD_fd  = mad(fd,constant = 1);
med_fd = median(fd);

thr_fd = med_fd + (AD_fd * 1.5);

cat(thr_fd)

# plot(x=1:length(fd), y=fd, type = 'l');
# abline(h = thr_fd);