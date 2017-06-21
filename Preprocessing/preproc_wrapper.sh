#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

SUBJ_DIR=$1
COND=$2
FD=$3
DVARS=$4
RM=$5
NUISSANCE=$6
PREPROC='/home/hpc3586/JE_packages/brain_state_proj/Preprocessing'

echo INITIALIZING PREPROCESSING --------------------

bash $PREPROC/skullstrip.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/slicetime.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/motcor.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/normalization.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/outlier_detect.sh $SUBJ_DIR $COND $PREPROC $FD $DVARS
Rscript $PREPROC/mk_reg_mat.R --PATH=$SUBJ_DIR --COND=$COND --RM=$RM --NUISSANCE=$NUISSANCE
bash $PREPROC/regress.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/rm_intermediate_files.sh $SUBJ_DIR $COND

#### TO FIX ####

#TODO bash $PREPROC/motreg.sh $SUBJ_DIR $COND $PREPROC

#### depreciated scrips ####

# Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND
# Rscript $PREPROC/framewise_disp.R --PATH=$SUBJ_DIR --COND=$COND
# bash $PREPROC/meantsBOLD.sh $SUBJ_DIR $COND $PREPROC
# Rscript $PREPROC/multiplot.R --PATH=$SUBJ_DIR --COND=$COND
# Rscript $PREPROC/mot_summ.R --PATH=$SUBJ_DIR --COND=$COND
# Rscript $PREPROC/scrubbing.R --PATH=$SUBJ_DIR --COND=$COND --FD=$FD --DVARS=$DVARS --RM=$RM
