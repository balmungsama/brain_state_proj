OUT_DIR='/mnt/c/Users/john/OneDrive/2017-2018/brain_state_proj/ROIs/HarvardOxford/HarvardOxford-cortl-maxprob-thr25-2mm/'

ATLAS='HarvardOxford-cortl-maxprob-thr25-2mm.nii.gz'
ATLAS_DIR='/usr/share/data/harvard-oxford-atlases/HarvardOxford'

#######################

ATLAS=$ATLAS_DIR/$ATLAS

fslstats $ATLAS -r