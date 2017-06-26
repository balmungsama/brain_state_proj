SUBJ_DIR=$1
COND=$2
PREPROC=$3

echo '	Interpolatng flagged volumes... '

matlab -nodesktop -nosplash -r "SUBJ_DIR='$SUBJ_DIR';COND='$COND';run('$PREPROC/interpolate_scrubbed.m')" | tail +11