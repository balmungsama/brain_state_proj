#TODO: still need to incorporate detrending into this script

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

setwd(PATH)

CONFOUND <- read.table( paste0('mot_analysis/', COND, '_CONFOUND.par') ) 

MPEs <- read.table( paste0('MPEs/', COND, '.1D'), col.names = c('dS', 'dL', 'dP', 'roll', 'pitch', 'yaw'))
NUIS <- read.table('nuisance/', COND, '_NUISANCE.txt')

reg.tab  <- cbind(MPEs, NUIS)
CONFOUND <- rowSums(CONFOUND)

reg.tab <- reg.tab[-which(CONFOUND == 1), ]
reg.tab <- scale(reg.tab)   # normalize the columns of the regressors

write.table(reg.tab, file = file.path(getwd(), 'nuisance', paste0(COND, '_regressors.txt')), 
            row.names = F, 
            col.names = F)
