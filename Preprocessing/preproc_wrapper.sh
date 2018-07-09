#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -q abaqus.q

SUBJ_DIR=$1
COND=$2
FWHM=$3
RM=$4
LOW=$5
HIGH=$6
INSPECT=$7

echo SUBJ_DIR = $SUBJ_DIR
echo COND     = $COND
echo FD       = $FD
echo FWHM     = $FWHM
echo LOW      = $LOW
echo HIGH     = $HIGH
echo INSPECT  = $INSPECT

PREPROC='/global/home/hpc3586/JE_packages/brain_state_proj/Preprocessing'

echo 'INITIALIZING PREPROCESSING --------------------'

rm -f $SUBJ_DIR/PASS

bash $PREPROC/skullstrip.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/slicetime.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/motcor.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/intense_norm.sh $SUBJ_DIR $COND $PREPROC
bash $PREPROC/spatial_normalization.sh $SUBJ_DIR $COND $FWHM $PREPROC
bash $PREPROC/outlier_detect.sh $SUBJ_DIR $COND $PREPROC 
# Rscript $PREPROC/mk_scrub_mat.R --PATH=$SUBJ_DIR --COND=$COND --RM=$RM


# bash $PREPROC/mot_scrubbing.sh $SUBJ_DIR $COND $PREPROC 'init'
# bash $PREPROC/nuis_reg.sh $SUBJ_DIR $COND $PREPROC
# bash $PREPROC/interpolate_scrubbed.sh $SUBJ_DIR $COND $PREPROC
# bash $PREPROC/bandpass_filter.sh $SUBJ_DIR $COND $LOW $HIGH
# bash $PREPROC/mot_scrubbing.sh $SUBJ_DIR $COND $PREPROC 'fin'
#TODO add another scrubbing step

# bash $PREPROC/mot_reg.sh $SUBJ_DIR $COND

# Quality control

# if [ $PASS != TRUE ]; then
# 	python2.7 $PREPROC/ICA-AROMA/ICA_AROMA.py -i $SUBJ_DIR/task_data/preproc/censor_filt_interp_nuis_snl_norm_mt_$COND.nii.gz -o $SUBJ_DIR/task_data/preproc -a $SUBJ_DIR/anatom/mats/aff_str2std.mat -w $SUBJ_DIR/anatom/cout_nl_brain_Mprage.nii -mc $SUBJ_DIR/MPEs/$COND.1D
# fi

echo 'FINISHED'
