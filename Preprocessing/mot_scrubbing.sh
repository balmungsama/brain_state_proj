SUBJ_DIR=$1
COND=$2
PREPROC=$3
stage=$4

out_check=$(echo -n $(head -n 1 Resting_CONFOUND.par) | wc -w)
n_vols=$(fslnvols $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii)

out_ratio=$( echo "$out_check / $n_vols" | bc -l)
out_ratio=$(echo $out_ratio'>'0.5 | bc -l)

if [[ $out_ratio -eq 1 ]]; then
	echo $SUBJ_DIR >> logs/$DATE/outlier_report.log 
fi

if [[ "$stage" == 'init' ]]; then

	if [[ $out_check == 'no outliers' ]]; then
	
		echo '	Motion scrubbing (init) ... **no outliers**'
		cp $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii $SUBJ_DIR/task_data/preproc/scrub_snl_norm_mt_$COND.nii
		
		echo '	Motion censoring ... **no outliers**'
		cp $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND.nii
	
	else

		echo '	Motion scrubbing (init) ...'
		fsl_glm -i $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/scrub_snl_norm_mt_$COND.nii
	
		echo '	Motion censoring ...'
		matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';FIN=false;run('$PREPROC/mot_censor.m')" 

	fi

	##### removing intermediate files #####

	# rm $SUBJ_DIR/task_data/preproc/scrub_snl_norm_mt_$COND.nii

elif [[ "$stage" == 'fin' ]]; then

	if [[ $out_check == 'no outliers' ]]; then
	
		echo '	Motion scrubbing (fin) ... **no outliers**'
		cp $SUBJ_DIR/task_data/preproc/filt_interp_nuis_snl_norm_mt_$COND $SUBJ_DIR/task_data/preproc/scrub_filt_interp_nuis_snl_norm_mt_$COND.nii
	
	else
	
		echo '	Motion scrubbing (fin) ...'
		fsl_glm -i $SUBJ_DIR/task_data/preproc/filt_interp_nuis_snl_norm_mt_$COND -d $SUBJ_DIR/mot_analysis/$COND'_CONFOUND.par' --out_res=$SUBJ_DIR/task_data/preproc/scrub_filt_interp_nuis_snl_norm_mt_$COND.nii

	fi

	##### archive final output

	matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';FIN=true;run('$PREPROC/mot_censor.m')"

	gzip $SUBJ_DIR/task_data/preproc/scrub_filt_interp_nuis_snl_norm_mt_$COND.nii
	gzip $SUBJ_DIR/task_data/preproc/censor_filt_interp_nuis_snl_norm_mt_$COND.nii
	gzip $SUBJ_DIR/task_data/preproc/nuis_snl_norm_mt_$COND.nii
	
	##### removing intermediate files #####

	# rm $SUBJ_DIR/task_data/preproc/filt_interp_nuis_snl_norm_mt_$COND.nii

fi