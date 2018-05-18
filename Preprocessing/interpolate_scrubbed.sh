SUBJ_DIR=$1
COND=$2
PREPROC=$3

# TODO: There is no way I need this script. All it does is call matlab. I can do that from the wrapper.

echo '	Interpolatng flagged volumes... '

matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/interpolate_scrubbed.m')" 

##### removing intermediate files #####

# rm $SUBJ_DIR/task_data/preproc/nuis_snl_norm_mt_$COND