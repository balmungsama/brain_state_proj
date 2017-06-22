SUBJ_DIR=$1
COND=$2
PREPROC=$3

matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/interplate_scrubbed.m')"

echo 'BOLD values have been interpolated'