#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo "QUALITY CONTROL"
echo "---------------"

###### make QC directories #####

mkdir -p $SUBJ_DIR/QualityControl

##### quality control scripts ######

bash $PREPROC/QualityControl/FC_DMN.sh $SUBJ_DIR $COND $PREPROC

Rscript $PREPROC/QualityControl/QC_summary.R --SUBJ_DIR=$SUBJ_DIR --COND=$COND --PREPROC=$PREPROC

