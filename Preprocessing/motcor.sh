# TODO: add slice-time correction																	
																												
SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
PREPROC=$3		 # NOTE: must use this name for behav & fmri data
					     
mkdir $SUBJ_DIR/MPEs

NIFTI_file=$SUBJ_DIR/task_data/preproc/t_$COND.nii*

echo '	motion correction...'

mcflirt -in $NIFTI_file -o $SUBJ_DIR/task_data/preproc/mt_$COND -refvol 1 -plots

mv $SUBJ_DIR/task_data/preproc/mt_$COND.par $SUBJ_DIR/MPEs/$COND.1D

# Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND