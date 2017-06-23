SUBJ_DIR=$1
COND=$2

echo '	regressing MPEs ...'

fsl_glm -i $SUBJ_DIR/task_data/preproc/filt_interop_snlmt_$COND.nii* -d $SUBJ_DIR/MPEs/$COND'.1D' --out_res=$SUBJ_DIR/task_data/preproc/mot_filt_interop_snlmt_$COND