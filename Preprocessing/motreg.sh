SUBJ_DIR=$1
COND=$2
PREPROC=$3

NUM_CORES=$(grep -c ^processor /proc/cpuinfo)

# if (($NUM_CORES > 1)); then
# 	NUM_CORES=2
# else
# 	NUM_CORES=1
# fi 

echo '	motion regression...'

fsl_glm -i $SUBJ_DIR/task_data/preproc/snlmt_$COND.nii* -d $SUBJ_DIR/MPEs/$COND.1D --out_res=$SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND.nii*