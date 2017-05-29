#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

TOP_DIR=$1
cond=$2
output=$3

##### prep arguments for passage into Matlab #####


mTOP_DIR=$(echo "TOP_DIR='$TOP_DIR'")
mCOMD=$(echo "cond='$cond'")
mOUT=$(echo "output='$output'")

mCOMMANDS=$(echo "$mTOP_DIR;$mCOND;$mOUT"	)

matlab -r "$mCOMMANDS" -nosplash -nodesktop -nosoftwareopengl -wait

