#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

TOP_DIR=$1
cond=$2
output=$3
script_path=$4

##### prep arguments for passage into Matlab #####
subj=$(basename $TOP_DIR)

mTOP_DIR=$(echo "TOP_DIR='$TOP_DIR'")
mCOND=$(echo "cond='$cond'")
mOUT=$(echo "output='$output'")
mSCRIPT=$(echo "addpath( genpath('$script_path') )")
mRM_VOLS=$(echo "run('rm_vols.m')")

mCOMMANDS=$(echo "$mTOP_DIR;$mCOND;$mOUT;$mSCRIPT;$mRM_VOLS"	)

matlab -r "$mCOMMANDS" -nosplash -nodesktop -nosoftwareopengl #-wait

qstat  | grep "roi_" > $subj'_job_list.txt'
line_count=($(wc -l $subj'_job_list.txt'))

if [[ line_count == 1 ]]; then
 files=$(ls $TOP_DIR/../*/task_data/preproc/rm_$cond.nii)

	for file in $files; do 
		list=$(echo $list $file)
	done

	mkdir -o $output/$cond
	
	melodic -i $list -o $output/$cond/
fi