SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo '	Regressing nuisance variables...'

mkdir $SUBJ_DIR/nuisance

fslmeants -i $SUBJ_DIR/task_data/preproc/mot_filt_interop_mt_$COND -m $PREPROC/mask_vent.nii.gz -o $SUBJ_DIR/nuisance/$COND'_t_vent.txt'
fslmeants -i $SUBJ_DIR/task_data/preproc/mot_filt_interop_mt_$COND -m $PREPROC/mask_wm.nii.gz -o $SUBJ_DIR/nuisance/$COND'_t_wm.txt'

paste $SUBJ_DIR/nuisance/t_vent.txt $SUBJ_DIR/nuisance/t_wm.txt > $SUBJ_DIR/nuisance/$COND'_NUISANCE'.txt

fsl_glm -i $SUBJ_DIR/task_data/preproc/mot_filt_interop_mt_$COND -d $SUBJ_DIR/nuisance/$COND'_NUISANCE'.txt --out_res=$SUBJ_DIR/task_data/preproc/nuis_mot_filt_interop_mt_$COND