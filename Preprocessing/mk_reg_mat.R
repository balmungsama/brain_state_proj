args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--PATH') {
    
    PATH <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else if (arg[1] == '--RM') {
    
    RM <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

if (length(unused_args) > 0) {
  print(paste('WARNING: unused arguments ', unused_args))
}

##### values for testing script #####

# PATH <- '/mnt/c/Users/john/OneDrive/2017-2018/brain_state_proj/Preprocessing/tmp_data'
# COND <- 'Resting'
# RM   <- 'UNION'

##### import regression matrices of DVARS & FD #####

DVARS <- read.table(file.path(PATH, 'mot_analysis', paste0(COND, '_DVARS.par')) )
FD    <- read.table(file.path(PATH, 'mot_analysis', paste0(COND, '_FD.par'   )) )

##### combine regression matrices according to RM mode #####

if (RM == 'UNION') {
  
  CONFOUND <- cbind(DVARS, FD)
  
  row.sums      <- rowSums(CONFOUND)
  row.redundant <- which(row.sums == 2)
  
  rm.col <- NULL
  for (red in row.redundant) {
    CONFOUND.row <- CONFOUND[red, ]
    rm.col <- c( rm.col, which(CONFOUND.row == 1)[2] )
  }
  
  CONFOUND <- CONFOUND[, -rm.col]
  
} else if (RM == 'INTERSECT') {
  CONFOUND <- cbind(DVARS, FD)
  
  row.sums      <- rowSums(CONFOUND)
  row.redundant <- which(row.sums == 2)
  
  keep.col <- NULL
  for (red in row.redundant) {
    CONFOUND.row <- CONFOUND[red, ]
    keep.col <- c( keep.col, which(CONFOUND.row == 1)[2] )
  }
  
  CONFOUND <- CONFOUND[, keep.col]
} else if (RM == 'FD') {
  CONFOUND <- FD
} else if (RM == 'DVARS') {
  CONFOUND <- DVARS
}

##### save the confound matrix #####

write.table(CONFOUND, file.path(PATH, 'mot_analysis', paste0(COND, '_CONFOUND.par') ), row.names = F, col.names = F )
