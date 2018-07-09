# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'
# COND='Retrieval'

SUBJ_DIR=$1
COND=$2
FWHM=$3
PREPROC=$4

TEMPLATE=$FSLDIR'/data/standard/MNI152_T1_2mm_brain.nii.gz'

# convert kernel from FWHM to sigma
kernel_conv=2.35482004503
kernel_size=$(echo "$FWHM/$kernel_conv" | bc -l)


mkdir $SUBJ_DIR/anatom/mats
mkdir $SUBJ_DIR/task_data/preproc/mats

# get voxel dimensions
header_info=$(fslinfo $SUBJ_DIR/task_data/$COND.nii*)

# identify voxel dimensions
vox_dimX=$(echo "$header_info" | grep -n "pixdim1")
vox_dimY=$(echo "$header_info" | grep -n "pixdim2")
vox_dimZ=$(echo "$header_info" | grep -n "pixdim3")

vox_dimX=$(echo ${vox_dimX##* })
vox_dimY=$(echo ${vox_dimY##* })
vox_dimZ=$(echo ${vox_dimZ##* })

vox_dim=$(echo $vox_dimX $vox_dimY $vox_dimZ)

echo '	Spatial normalization...'

echo '       		+ Linear-warping functional to structural...'
flirt -ref $SUBJ_DIR/anatom/brain_Mprage.nii.gz \
    -in $SUBJ_DIR/task_data/preproc/norm_mt_$COND \
    -omat $SUBJ_DIR/task_data/preproc/mats/func2str.mat -dof 6

echo '       		+ Linear-warping structural to standard template...'
flirt -ref $TEMPLATE -in $SUBJ_DIR/anatom/brain_Mprage.nii.gz \
    -omat $SUBJ_DIR/anatom/mats/aff_str2std.mat \
    -out $SUBJ_DIR/anatom/l_brain_Mprage
echo '       		+ Non-linear-warping structural to standard template...'
fnirt --ref=$TEMPLATE --in=$SUBJ_DIR/anatom/Mprage.nii.gz \
    --aff=$SUBJ_DIR/anatom/mats/aff_str2std.mat \
    --iout=$SUBJ_DIR/anatom/nl_Mprage \
    --cout=$SUBJ_DIR/anatom/cout_nl_brain_Mprage # FNIRT strct to std
bet $SUBJ_DIR/anatom/nl_Mprage $SUBJ_DIR/anatom/nl_brain_Mprage -R
echo '       		+ Creating binary mask from non-linearly warped image...'
fslmaths $SUBJ_DIR/anatom/nl_brain_Mprage -thr 1 \
    -bin $SUBJ_DIR/anatom/bin_nl_brain_Mprage
echo '       		+ Applying standardized warp to functional data...'
applywarp --ref=$TEMPLATE --in=$SUBJ_DIR/task_data/preproc/norm_mt_$COND \
    --out=$SUBJ_DIR/task_data/preproc/nl_norm_mt_$COND \
    --warp=$SUBJ_DIR/anatom/cout_nl_brain_Mprage \
    --premat=$SUBJ_DIR/task_data/preproc/mats/func2str.mat
echo '       		+ Applying spatial smoothing kernel...'
fslmaths $SUBJ_DIR/task_data/preproc/nl_norm_mt_$COND -kernel gauss \
    $kernel_size -fmean $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND

echo '          + Down-sampling functional data to match original functional resolution...'
3dresample -dxyz $vox_dim \
    -input $SUBJ_DIR/task_data/preproc/snl_norm_mt_$COND.nii* \
    -rmode 'Linear' -prefix $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND
3dAFNItoNIFTI -prefix $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND \
    $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND+tlrc
gzip $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND.nii
echo '          + Down-sampling mask to match original functional resolution...'
3dresample -dxyz $vox_dim -input $SUBJ_DIR/anatom/bin_nl_brain_Mprage.nii* \
    -rmode 'Linear' -prefix $SUBJ_DIR/anatom/dbin_nl_brain_Mprage
3dAFNItoNIFTI -prefix $SUBJ_DIR/anatom/dbin_nl_brain_Mprage \
    $SUBJ_DIR/anatom/dbin_nl_brain_Mprage+tlrc
gzip $SUBJ_DIR/anatom/dbin_nl_brain_Mprage.nii
###################################################

# cleanup
rm $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND.nii
rm $SUBJ_DIR/anatom/dbin_nl_brain_Mprage.nii