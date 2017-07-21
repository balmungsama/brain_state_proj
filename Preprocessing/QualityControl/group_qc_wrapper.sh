#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

PREPROC='/home/hpc3586/JE_packages/brain_state_proj/Preprocessing'

TOP_DIR=$1 						# here you enter in the group directory
COND=$2    						# enter the condition name

DATE=$(date +%y-%m-%d)
mkdir -p QualityControl/logs/$DATE
rm -f QualityControl/logs/$DATE/*

subj_ls=($(ls $TOP_DIR))

##### for testing #####
#subj_ls=(${subj_ls[@]:0:5})
#######################

##### primary loop to go through all subject ##### 
for subj in ${subj_ls[@]}; do
	SUBJ_DIR=$TOP_DIR/$subj
	qsub -q abaqus.q -N qc_$subj -o QualityControl/logs/$DATE/pp_$subj.out -e QualityControl/logs/$DATE/pp_$subj.err preproc_wrapper.sh $SUBJ_DIR $COND $PREPROC
done