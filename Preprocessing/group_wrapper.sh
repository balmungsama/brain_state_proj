#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

# TODO: integrate the TEMPLATE for normalization into the rest of the pipeline

TOP_DIR=$1            # here you enter in the group directory
COND=$2               # enter the condition name
FWHM=$3               # FWHM size in mm
RM=$4                 # use "UNION" or "INTERSECT" of FD & DVARS
LOW=$5                # low  threshold bandpass filter
HIGH=$6               # high threshold bandpass filter

INSPECT=$7
#TEMPLATE=$8           # template to be used in normalization

DATE=$(date +%y-%m-%d)
mkdir -p logs/$DATE
rm -f logs/$DATE/*

subj_ls=($(ls $TOP_DIR))

##### for testing #####
subj_ls=(${subj_ls[@]:0:1})
#######################

echo outliers > logs/$DATE/outlier_report.log 

##### primary loop to go through all subject ##### 
for subj in ${subj_ls[@]}; do
	SUBJ_DIR=$TOP_DIR/$subj
	qsub -q abaqus.q -N pp_$subj -o logs/$DATE/pp_$subj.out -e logs/$DATE/pp_$subj.err preproc_wrapper.sh $SUBJ_DIR $COND $FWHM $RM $LOW $HIGH $INSPECT
done