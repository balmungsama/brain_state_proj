SUBJ_DIR=$1
COND=$2
PREPROC=$3

ROI_DIR=$PREPROC/QualityControl/roi_spheres
roi_list=($(ls $ROI_DIR))

echo ' + extracting roi time courses....'

mkdir -p $SUBJ_DIR/QualityControl/roi_tcourses

COUNT=0

for roi in ${roi_list[@]}; do

	echo $roi

	COUNT=$(( $COUNT + 1))
	
	label=$(printf "%02d\n" $COUNT)

	fslmeants -i $SUBJ_DIR/task_data/preproc/censor_filt_interp_nuis_snl_norm_mt_$COND -m $PREPROC/QualityControl/roi_spheres/$roi -o $SUBJ_DIR/QualityControl/roi_tcourses/$COND'_roi_'$label.txt

done

echo ' + computing FC matrix...'

Rscript $PREPROC/QualityControl/FC_DMN.R --SUBJ_DIR=$SUBJ_DIR --COND=$COND