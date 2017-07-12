SUBJ_DIR=$1
COND=$2
PREPROC=$3
stage=$4

if [[ "$stage" == 'init' ]]; then
	
	echo '	Motion scrubbing (init) ...'
	fsl_glm -i $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/scrub_snl_norm_mt_$COND.nii

	echo '	Motion censoring ...'
	matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/mot_censor.m')" 

elif [[ "$stage" == 'fin' ]]; then
	
	echo '	Motion scrubbing (fin) ...'
	fsl_glm -i $SUBJ_DIR/task_data/preproc/filt_interp_nuis_snl_norm_mt_$COND -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/scrub_filt_interp_nuis_snl_norm_mt_$COND.nii

fi