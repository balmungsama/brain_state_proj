##### openning statements #####

cat(' + Summarizing QC measures...')

##### load libraries #####

library(R.matlab)

##### accepting arguments #####

args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = '=')[[1]]
  if (arg[1] == '--SUBJ_DIR') {
    
    SUBJ_DIR <- arg[2]
    
  } else if (arg[1] == '--COND') {
    
    COND <- arg[2]
    
  } else if (arg[1] == '--PREPROC') {
    
    PREPROC <- arg[2]
    
  } else {
    
    unused_args <- c(unused_args, paste0(arg[1], '=', arg[2]))
    
  }
}

##### import sample data #####
sample.data <- list()

sample.data[['DMN']] <- read.csv( file.path(PREPROC, 'QualityControl', 'DMN_reference.csv'), header = T, row.names = 1 )
sample.data[['DMN']] <- as.matrix( sample.data[['DMN']] )

##### import subject data #####

subj.data <- list()

subj.data[['subj_id']]    <- basename(SUBJ_DIR)
subj.data[['FC_matrix']]  <- read.csv( file.path(SUBJ_DIR, 'QualityControl', paste0(COND, '_DMN_FC.csv')), header = T, row.names = 1 )
subj.data[['FC_matrix']]  <- as.matrix(subj.data[['FC_matrix']])

##### check overlap with DMN #####

QC.summary <- list()

QC.summary[['correl_with_DMN']] <- cor.test(sample.data[['DMN']], subj.data[['FC_matrix']])$estimate

##### save output #####

writeMat(QC_summary = QC.summary, 
         con        = file.path(SUBJ_DIR, 'QualityControl', paste0('QC_summary_', subj.data[['subj_id']], '.mat') ), 
         fixNames   = TRUE, 
         matVersion = "5", 
         onWrite    = NULL, 
         verbose    = FALSE)

