SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
PREPROC=$3		 # NOTE: must use this name for behav & fmri data
					     
mkdir $SUBJ_DIR/MPEs

nvols=$(fslnvols $SUBJ_DIR/task_data/$COND.nii*)

echo '	motion correction...'

mcflirt -in $SUBJ_DIR/task_data/preproc/t_$COND.nii -o $SUBJ_DIR/task_data/preproc/mt_$COND -refvol $(($nvols/2)) -plots

mv $SUBJ_DIR/task_data/preproc/mt_$COND.par $SUBJ_DIR/MPEs/$COND.1D