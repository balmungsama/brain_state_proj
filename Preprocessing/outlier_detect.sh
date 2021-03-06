# TODO: add in option for automatic threshold detection if no value specified
# TODO: add ability to ommit subject from analysis if the Rscript says so

SUBJ_DIR=$1
COND=$2
PREPROC=$3

n_vols=$(fslnvols $SUBJ_DIR/task_data/preproc/t_$COND.nii)

echo '	computing DVARS...'

mkdir $SUBJ_DIR/mot_analysis
mkdir $SUBJ_DIR/mot_analysis/plots

# DVARS
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND.nii.gz \
	-o $SUBJ_DIR/mot_analysis/$COND'_DVARS.par' \
	-s $SUBJ_DIR/mot_analysis/$COND'_DVARS.val' \
	-p $SUBJ_DIR/mot_analysis/plots/$COND'_DVARS' \
	--dvars --nomoco -m $SUBJ_DIR/anatom/dbin_nl_brain_Mprage
dvars_thr=$(Rscript $PREPROC/find_dvars_thresh.R --PATH=$SUBJ_DIR --COND=$COND)
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/dsnl_norm_mt_$COND.nii.gz \
	-o $SUBJ_DIR/mot_analysis/$COND'_DVARS.par' \
	-s $SUBJ_DIR/mot_analysis/$COND'_DVARS.val' \
	-p $SUBJ_DIR/mot_analysis/plots/$COND'_DVARS' \
	--dvars --nomoco -m $SUBJ_DIR/anatom/dbin_nl_brain_Mprage \
	--thresh=$dvars_thr

echo DVARS threshold = $dvars_thr

# not sure what this does
if [[ ! -e $SUBJ_DIR/mot_analysis/$COND'_DVARS.par' ]]; then

	for ii in $(seq 1 $nvols); do 
		echo 0 > $SUBJ_DIR/mot_analysis/$COND'_DVARS.par'
	done

fi

echo '	computing FD...'

# FD
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/t_$COND.nii* \
	-o $SUBJ_DIR/mot_analysis/$COND'_FD.par' \
	-s $SUBJ_DIR/mot_analysis/$COND'_FD.val' \
	-p $SUBJ_DIR/mot_analysis/plots/$COND'_FD' --fd 
fd_thr=$(Rscript $PREPROC/find_fd_thresh.R --PATH=$SUBJ_DIR --COND=$COND)
fsl_motion_outliers -i $SUBJ_DIR/task_data/preproc/t_$COND.nii* \
	-o $SUBJ_DIR/mot_analysis/$COND'_FD.par' \
	-s $SUBJ_DIR/mot_analysis/$COND'_FD.val' \
	-p $SUBJ_DIR/mot_analysis/plots/$COND'_FD' \
	--fd --thresh=$fd_thr

echo FD threshold    = $fd_thr

if [[ ! -e $SUBJ_DIR/mot_analysis/$COND'_FD.par' ]]; then

	for ii in $(seq 1 $nvols); do 
		echo 0 > $SUBJ_DIR/mot_analysis/$COND'_FD.par'
	done
	
fi

##### removing intermediate files #####

# rm $SUBJ_DIR/task_data/preproc/t_$COND.nii