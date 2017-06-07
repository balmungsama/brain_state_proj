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

mkdir $output/$cond

##### get the ica analysis ready

if [[ $nROI == 'default' ]]; then
	nROI=''
else 
	nROI=$(echo -d $nROI)
fi

if [[ $mode == 'group' ]]; then

	files=$(ls $TOP_DIR/*/task_data/preproc/ica_$cond.nii)
	echo $files

	subj=($(ls $TOP_DIR))
	subj=${subj[1]}
	subj=$(basename $subj)

	TR=$(3dinfo -tr $TOP_DIR/$subj/task_data/$cond.nii*)

	for file in $files; do 
		echo $file >> $output/$cond/$cond'_files_for_ica.txt'
	done

	mkdir $output/$cond

	melodic -i $output/$cond/$cond'_files_for_ica.txt' -o $output/$cond/ --tr=$TR --report --Ostats -a concat -v $nROI #--Opca 

	rm $output/$cond/$cond'_files_for_ica.txt'

elif [[ $mode == 'subj' ]]; then

	echo HELLO WORLD

	TR=$(3dinfo -tr $TOP_DIR/task_data/$cond.nii*)

	name=$(basename $TOP_DIR)
	melodic -i $TOP_DIR/task_data/preproc/ica_$cond.nii -o $output/$cond/ --tr=$TR --report --Ostats -a concat -v $nROI #--Opca

fi

