OUT_DIR='/mnt/c/Users/john/OneDrive/2017-2018/brain_state_proj/ROIs/HarvardOxford/HarvardOxford-cortl-maxprob-thr25-2mm/'

ATLAS='HarvardOxford-cortl-maxprob-thr25-2mm.nii.gz'
ATLAS_DIR='/usr/share/data/harvard-oxford-atlases/HarvardOxford'

#######################

mkdir $OUT_DIR/tmp

ATLAS=$ATLAS_DIR/$ATLAS

fslmaths $ATLAS -bin $OUT_DIR/tmp/bin_mask

range=($(fslstats $ATLAS -k $OUT_DIR/tmp/bin_mask -R))

# echo ${range[@]}

for roi in $(seq ${range[0]} ${range[1]}); do
	roi=${roi%.*}                # convert float to integer
	
	fslmaths $ATLAS -thr $roi -uthr $roi $OUT_DIR/roi_$roi

done

rm -r $OUT_DIR/tmp