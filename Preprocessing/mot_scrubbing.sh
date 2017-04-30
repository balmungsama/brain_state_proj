SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo '	motion scrubbing...'

fsl_glm -i $SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND.nii* -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND
