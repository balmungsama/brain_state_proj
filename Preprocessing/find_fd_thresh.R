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

# cat(thr_fd)

# plot(x=1:length(fd), y=fd, type = 'l');
# abline(h = thr_fd);

##### comparing variances #####

fd2            <- fd
fd2[fd>thr_fd] <- NA
fd3            <- fd2
fd3[1]         <- NA

f_test <- var.test(fd2, fd3, na.rm=T)
p_val  <- format.pval(f_test$p.value)

if (grepl(pattern = ' ', x = p_val)) {
  p_val <- strsplit(p_val, split = ' ')[[1]][2]
}

p_val <- as.numeric(p_val)

if (p_val < 0.01) {
  cat('PASS', thr_fd)
} else {
  cat(thr_fd)
}
