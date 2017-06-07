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
mode=$6

subj=$(basename $TOP_DIR)

mkdir $output/$cond

##### get the ica analysis ready

if [[ $nROI == 'default' ]]; then
	nROI=''
else 
	nROI=$(echo -d $nROI)
fi

TR=$(3dinfo -tr $TOP_DIR/$cond.nii*)

if [[ $mode == 'group' ]]; then

	files=$(ls $TOP_DIR/*/task_data/preproc/ica_$cond.nii)
	echo $files

	for file in $files; do 
		echo $file >> $output/$cond/$cond'_files_for_ica.txt'
	done

	mkdir $output/$cond

	melodic -i $output/$cond/$cond'_files_for_ica.txt' -o $output/$cond/ --tr=$TR --report --Ostats -a concat --Opca -v $nROI

elif [[ $mode == 'subj' ]]; then

	melodic -i $TOP_DIR/task_data/preproc/ica_$cond.nii -o $output/$cond/ --tr=$TR --report --Ostats -a concat --Opca -v $nROI

fi

