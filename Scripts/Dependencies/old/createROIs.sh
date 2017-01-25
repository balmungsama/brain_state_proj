ATLAS_PATH='/usr/share/fsl/data/atlases/HarvardOxford/HarvardOxford-cortl-maxprob-thr50-2mm.nii.gz'
ROI_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/roidir_john'

min_max=$(fslstats $ATLAS_PATH -R)

max=$(echo $min_max | awk '{print $2}')
max=${max%'.'*}

for ((ii=1;ii<=$max;ii++)){
  max_p1=$(expr $ii + 1)
  fslmaths $ATLAS_PATH -thr $ii $ROI_DIR/roi$ii'_temp'
  fslmaths $ROI_DIR/roi$ii'_temp' -thr $max_p1 $ROI_DIR/roi$ii'_plus1_temp'
  fslmaths $ROI_DIR/roi$ii'_temp' -sub $ROI_DIR/roi$ii'_plus1_temp' $ROI_DIR/roi$ii
  fslmaths $ROI_DIR/roi$ii -bin $ROI_DIR/roi$ii
}

rm $ROI_DIR/*_*.nii.gz
