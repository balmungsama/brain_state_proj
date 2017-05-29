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
mCOND=$(echo "cond='$cond'")
mOUT=$(echo "output='$output'")
mRM_VOLS=$(echo "run('rm_vols.m')")

mCOMMANDS=$(echo "$mTOP_DIR;$mCOND;$mOUT;$mRM_VOLS"	)

matlab -r "$mCOMMANDS" -nosplash -nodesktop -nosoftwareopengl -wait

