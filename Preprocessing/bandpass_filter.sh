##### temporal bandpass filtering #####

SUBJ_DIR=$1
COND=$2
LOW=$3
HIGH=$4

echo '	Temporal bandpass filtering... '
echo "       + $LOW Hz < f < $HIGH Hz"

TR=$(3dinfo -tr $SUBJ_DIR/task_data/$COND.nii*)

HIGH=$(bc -l <<< "(1 / $HIGH) / $TR" )
LOW=$(bc -l <<< "(1 / $LOW) / $TR")

fslmaths $SUBJ_DIR/task_data/preproc/interp_nuis_snl_norm_mt_$COND -bptf $HIGH $LOW $SUBJ_DIR/task_data/preproc/filt_interp_nuis_snl_norm_mt_$COND

##### removing intermediate files #####

rm $SUBJ_DIR/task_data/preproc/interp_nuis_snl_norm_mt_$COND.nii