#TODO: add in the 12-24 time parameter estimates 

SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo '	Regressing nuisance variables...'

mkdir $SUBJ_DIR/nuisance

fslmeants -i $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND \
    -m $PREPROC/mask_vent_2mm.nii.gz \
    -o $SUBJ_DIR/nuisance/$COND'_t_vent.txt'
fslmeants -i $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND \
    -m $PREPROC/mask_wm_2mm.nii.gz  \
    -o $SUBJ_DIR/nuisance/$COND'_t_wm.txt'
fslmeants -i $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND \
    -m $SUBJ_DIR/anatom/bin_nl_brain_Mprage \
    -o $SUBJ_DIR/nuisance/$COND'_t_gs.txt'

paste $SUBJ_DIR/nuisance/$COND'_t_vent.txt' \
    $SUBJ_DIR/nuisance/$COND'_t_wm.txt' \
    $SUBJ_DIR/nuisance/$COND'_t_gs.txt'  > $SUBJ_DIR/nuisance/$COND'_NUISANCE'.txt

# Rscript $PREPROC/center_nuisance.R --PATH=$SUBJ_DIR --COND=$COND

fsl_glm -i $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND \
    -d $SUBJ_DIR/nuisance/$COND'_NUISANCE'.txt \
    -o $SUBJ_DIR/nuisance/BETAS_$COND \
    -m $SUBJ_DIR/anatom/bin_nl_brain_Mprage \
    --demean --dat_norm --des_norm

matlab -nodesktop -nosplash \
    -r "FSLDIR='$FSLDIR';SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/model_BOLD.m')" 

##### removing intermediate files #####

# rm $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii
# rm $SUBJ_DIR/task_data/preproc/censor_snl_norm_mt_$COND.nii
# rm $SUBJ_DIR/nuisance/BETAS_$COND.nii
