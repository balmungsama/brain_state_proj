SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
PREPROC=$3		 # NOTE: must use this name for behav & fmri data

echo '	intensity normalization...'

fslmaths $SUBJ_DIR/task_data/preproc/mt_$COND -ing 1000 $SUBJ_DIR/task_data/preproc/norm_mt_$COND

##### removing intermediate files #####

rm $SUBJ_DIR/task_data/preproc/mt_$COND