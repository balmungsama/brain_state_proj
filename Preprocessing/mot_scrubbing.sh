SUBJ_DIR=$1
COND=$2

echo '	Motion scrubbing ...'

fsl_glm -i $SUBJ_DIR/task_data/preproc/nuis_snl_mot_filt_interop_mt_$COND -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/scrub_nuis_snl_mot_filt_interop_mt_$COND
