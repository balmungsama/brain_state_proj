SUBJ_DIR=$1
COND=$2
PREPROC=$3
RM=$RM

echo '	computing DVARS...'

mkdir $SUBJ_DIR/mot_analysis/plots

NIFTI_FILE=$SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND

fsl_motion_outliers -i $NIFTI_FILE -o $SUBJ_DIR/mot_analysis/$COND'_DVARS.par' -s $SUBJ_DIR/mot_analysis/$COND'_DVARS.txt' -p $SUBJ_DIR/mot_analysis/plots/$COND'_DVARS.val' --dvars 

fsl_motion_outliers -i $NIFTI_FILE -o $SUBJ_DIR/mot_analysis/$COND'_FD.par' -s $SUBJ_DIR/mot_analysis/$COND'_FD.txt' -p $SUBJ_DIR/mot_analysis/plots/$COND'_FD.val' --fd

