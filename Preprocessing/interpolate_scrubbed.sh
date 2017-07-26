SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo '	Interpolatng flagged volumes... '

matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/interpolate_scrubbed.m')" 

##### removing intermediate files #####

rm $SUBJ_DIR/task_data/preproc/nuis_snl_norm_mt_$COND