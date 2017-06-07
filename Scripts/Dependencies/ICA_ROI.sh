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
nROI=$5
subj_count=$6

##### prep arguments for passage into Matlab #####
subj=$(basename $TOP_DIR)

mTOP_DIR=$(echo "TOP_DIR='$TOP_DIR'")
mCOND=$(echo "cond='$cond'")
mOUT=$(echo "output='$output'")
mSCRIPT=$(echo "addpath( genpath('$script_path') )")
mRM_VOLS=$(echo "run('rm_vols.m')")

mCOMMANDS=$(echo "$mTOP_DIR;$mCOND;$mOUT;$mSCRIPT;$mRM_VOLS"	)

matlab -r "$mCOMMANDS" -nosplash -nodesktop -nosoftwareopengl #-wait

##### get the ica analysis ready

if [[ $nROI == 'default' ]]; then
	nROI=''
else 
	nROI=$(echo -d $nROI)
fi

echo $subj >> $output/$cond'_tally.txt'
line_count=($(wc -l $output/$cond'_tally.txt'))

if [[ line_count == $subj_count ]] && [[ ${#subj_count} > 0 ]]; then

	TR=$(3dinfo -tr $TOP_DIR/$cond.nii*)

	files=$(ls $TOP_DIR/../*/task_data/preproc/ica_$cond.nii)

	for file in $files; do 
		echo $file >> $output/$cond'_files_for_ica.txt'
	done

	mkdir $output/$cond

	melodic -i $output/$cond'_files_for_ica.txt' -o $output/$cond/ --tr=$TR --report --Ostats -a concat --Opca -v $nROI

	rm $output/$cond'_tally.txt'

elif [[ ${#subj_count} > 0 ]]; then

	melodic -i $TOP_DIR/task_data/preproc/ica_$cond.nii -o $output/$cond/ --tr=$TR --report --Ostats -a concat --Opca -v $nROI

fi

