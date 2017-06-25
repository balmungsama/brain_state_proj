# TODO: add in option for automatic threshold detection if no value specified

SUBJ_DIR=$1
COND=$2
PREPROC=$3
FD=$4
DVARS=$5

echo '	computing DVARS...'

mkdir $SUBJ_DIR/mot_analysis
mkdir $SUBJ_DIR/mot_analysis/plots

# DVARS
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/mt_$COND.nii* -o $SUBJ_DIR/mot_analysis/$COND'_DVARS.par' -s $SUBJ_DIR/mot_analysis/$COND'_DVARS.val' -p $SUBJ_DIR/mot_analysis/plots/$COND'_DVARS' --dvars --nomoco --thresh=$DVARS

echo '	computing FD...'

# FD
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/t_$COND.nii* -o $SUBJ_DIR/mot_analysis/$COND'_FD.par' -s $SUBJ_DIR/mot_analysis/$COND'_FD.val' -p $SUBJ_DIR/mot_analysis/plots/$COND'_FD' --fd --thresh=$FD

