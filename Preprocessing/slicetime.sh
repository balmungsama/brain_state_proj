# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'    # subject directory
# COND='Retrieval'

SUBJ_DIR=$1
COND=$2

echo '	slice-time correction...'

TR=$(3dinfo -tr $SUBJ_DIR/task_data/$COND.nii*)

slicetimer -i $SUBJ_DIR/task_data/$COND -o $SUBJ_DIR/task_data/preproc/t_$COND -r $TR

# 3dTshift -TR $TR's' -prefix $SUBJ_DIR/task_data/preproc/t_$COND $SUBJ_DIR/task_data/$COND.nii*

# 3dAFNItoNIFTI -prefix $SUBJ_DIR/task_data/preproc/t_$COND $SUBJ_DIR/task_data/preproc/t_$COND+orig.HEAD
# rm $SUBJ_DIR/task_data/preproc/t_$COND+orig.*