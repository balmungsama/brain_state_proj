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

fslmaths $SUBJ_DIR/task_data/preproc/interop_mt_$COND -bptf $HIGH $LOW $SUBJ_DIR/task_data/preproc/filt_interop_mt_$COND