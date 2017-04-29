# PREPROC='/mnt/c/Users/john/OneDrive/2017-2018/preprocessing' # directory of preproc scripts
# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
# COND='Retrieval'																				
																												
SUBJ_DIR=$1    # subject directory
COND=$2   		 # name of condition
					         # NOTE: must use this name for behav & fmri data
PREPROC=$3


mkdir $SUBJ_DIR/task_data/preproc
mkdir $SUBJ_DIR/MPEs

NIFTI_file=$SUBJ_DIR/task_data/preproc/t_$COND.nii*

echo '	motion correction...'

mcflirt -in $NIFTI_file -o $SUBJ_DIR/task_data/preproc/mt_$COND -refvol 1 -plots

# 3dvolreg -base 0 -prefix $SUBJ_DIR/task_data/preproc/mt_$COND -1Dfile $SUBJ_DIR/MPEs/$COND.1D $NIFTI_file
# 3dAFNItoNIFTI -prefix $SUBJ_DIR/task_data/preproc/mt_$COND $SUBJ_DIR/task_data/preproc/mt_$COND+orig.HEAD
# rm $SUBJ_DIR/task_data/preproc/mt_$COND+orig.*

Rscript $PREPROC/deg2mm.R --PATH=$SUBJ_DIR --COND=$COND