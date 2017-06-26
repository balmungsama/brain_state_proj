SUBJ_DIR=$1
COND=$2

echo '	Removing unecessary files...'

rm -f $SUBJ_DIR/task_data/preproc/t_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/interop_mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/filt_interop_mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/mot_filt_interop_mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/nl_mot_filt_interop_mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/nuis_snl_mot_filt_interop_mt_$COND.nii
rm -f $SUBJ_DIR/task_data/preproc/scrub_nuis_snl_mot_filt_interop_mt_$COND.nii