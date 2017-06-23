SUBJ_DIR=$1
COND=$2

echo '	Removing unecessary files...'

rm $SUBJ_DIR/task_data/t_$COND.*
rm $SUBJ_DIR/task_data/motreg_snlmt_$COND*