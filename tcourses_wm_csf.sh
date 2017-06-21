##### Regress out WM & CSF signal #####

# NOTE: CSF mask was created with the following code:
# fast MNI152_T1_1mm_brain.nii.gz
# fslmaths MNI152_T1_1mm_brain_pve_0.nii.gz -thr 1 -bin -kernel sphere 2 -ero mask_csf

SUBJ_DIR=$1
COND=$2
PREPROC=$3
NUISANCE=$4

mkdir $SUBJ_DIR/nuisance

NIFTI_FILE=$SUBJ_DIR/task_data/preproc/motreg_snlmt_$COND

if [ $NUISANCE == wm ] || [ $NUISANCE == both ]; then
	fslmeants -i $NIFTI_FILE -o $SUBJ_DIR/nuisance/$COND'_'wm_tcourse.txt -m $PREPROC/mask_wm.nii.gz
fi

if [ $NUISANCE == csf ] || [ $NUISANCE == both ]; then
	fslmeants -i $NIFTI_FILE -o $SUBJ_DIR/nuisance/$COND'_'csf_tcourse.txt -m $PREPROC/mask_csf.nii.gz
fi