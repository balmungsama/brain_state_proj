##### trouble-shooting print statement #####

##### main script #####

args        <- commandArgs(trailingOnly = TRUE)
unused_args <- NULL

for (arg in args) {
  arg <- strsplit(arg, split = "=")[[1]]
  if (arg[1] == "--PATH") {

    PATH <- arg[2]

  } else if (arg[1] == "--COND") {

    COND <- arg[2]

  } else if (arg[1] == "--RM") {

    RM <- arg[2]

  } else {

    unused_args <- c(unused_args, paste0(arg[1], "=", arg[2]))

  }
}

if (length(unused_args) > 0) {
    print(paste("WARNING: unused arguments ", unused_args))
}

cat("        Creating confound matrix...\n")

##### import regression matrices of DVARS & FD #####

vals.DVARS <-
    read.table(file.path(PATH, "mot_analysis", paste0(COND, "_DVARS.val")))

if ( file.exists(file.path(PATH, "mot_analysis", paste0(COND, "_DVARS.par")))) {
    DVARS <-
      read.table(file.path(PATH, "mot_analysis", paste0(COND, "_DVARS.par")))
} else {
    DVARS <- matrix(data = 0, ncol = 1, nrow = dim(vals.DVARS)[1] )
}

if ( file.exists(file.path(PATH, "mot_analysis", paste0(COND, "_FD.par")))) {
    FD    <-
      read.table(file.path(PATH, "mot_analysis", paste0(COND, "_FD.par")))
} else {
    FD    <- matrix( data = 0, ncol = 1, nrow = dim(vals.DVARS)[1] )
}


##### combine regression matrices according to RM mode #####

if (RM == "UNION") {

  CONFOUND <- cbind(DVARS, FD)

  row.sums      <- rowSums(CONFOUND)
  row.redundant <- which(row.sums == 2)

  rm.col <- NULL
  for (red in row.redundant) {
    CONFOUND.row <- CONFOUND[red, ]
    rm.col <- c( rm.col, which(CONFOUND.row == 1)[2] )
  }

  if (length(rm.col) > 0) {
    CONFOUND <- CONFOUND[, -rm.col]
  }

} else if (RM == "INTERSECT") {
    CONFOUND <- cbind(DVARS, FD)

  row.sums      <- rowSums(CONFOUND)
  row.redundant <- which(row.sums == 2)

  keep.col <- NULL
  for (red in row.redundant) {
      CONFOUND.row <- CONFOUND[red, ]
      keep.col <- c( keep.col, which(CONFOUND.row == 1)[2] )
  }

  if (length(keep.col) > 0) {
    CONFOUND <- CONFOUND[, keep.col]
  } else {

    CONFOUND <- matrix(data = 0, ncol = 1, nrow = dim(CONFOUND)[1] )

  }

} else if (RM == "FD") {

  CONFOUND <- FD

} else if (RM == "DVARS") {

  CONFOUND <- DVARS

}

if( sum(CONFOUND) == 0 ) {

  # CONFOUND <- matrix(data = 0, ncol = 1, nrow = dim(CONFOUND)[1] )
  write.table(x = "no outliers",
    file = file.path(PATH, "mot_analysis", paste0(COND, "_CONFOUND.par") )
    , row.names = F, col.names = F)

  cat("\n This participant has no outlying volumes. \n")

} else {

  ##### remove zero columns #####
  if ( sum( colSums(CONFOUND) == 0) > 0 ) { 
    CONFOUND <- CONFOUND[, -which( as.numeric(c(colSums(CONFOUND))) == 0) ]
  }


  ##### check how many vols were flagged as outliers #####

  CONFOUND.dim <- dim(CONFOUND)

  # if ( CONFOUND.dim[2] / CONFOUND.dim[1] >= 0.5 ) {
  #   system( paste0("touch ", file.path(PATH, "PASS") ) )
  # }

  ##### save the confound matrix #####

  write.table(CONFOUND,
    file.path(PATH, "mot_analysis", paste0(COND, "_CONFOUND.par") ),
    row.names = F,
    col.names = F )

}