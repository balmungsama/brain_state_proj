##### temporal bandpass filtering #####

SUBJ_DIR=$1
COND=$2
HIGH=$3
LOW=$4

TR=$(3dinfo -tr $SUBJ_DIR/task_data/$COND.nii*)

HIGH=$(bc -l <<< "(1 / $HIGH) / $TR" )
LOW=$(bs -l <<< "(1 / $LOW) / $TR")

fslmath $SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND -bptf $HIGH $LOW $SUBJ_DIR/task_data/preproc/filt_motreg_snlmt_$COND