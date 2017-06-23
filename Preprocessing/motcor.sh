# TODO: add slice-time correction																	
																												
SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
					         # NOTE: must use this name for behav & fmri data
PREPROC=$3


mkdir $SUBJ_DIR/MPEs

NIFTI_file=$SUBJ_DIR/task_data/preproc/t_$COND.nii*

echo '	motion correction...'

mcflirt -in $NIFTI_file -o $SUBJ_DIR/task_data/preproc/mt_$COND -refvol 1 -plots

mv $SUBJ_DIR/task_data/preproc/mt_$COND.par $SUBJ_DIR/MPEs/$COND.1D

# 3dvolreg -base 0 -prefix $SUBJ_DIR/task_data/preproc/mt_$COND -1Dfile $SUBJ_DIR/MPEs/$COND.1D $NIFTI_file
# 3dAFNItoNIFTI -prefix $SUBJ_DIR/task_data/preproc/mt_$COND $SUBJ_DIR/task_data/preproc/mt_$COND+orig.HEAD
# rm $SUBJ_DIR/task_data/preproc/mt_$COND+orig.*

Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND