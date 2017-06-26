SUBJ_DIR=$1
COND=$2

echo '	Removing unecessary files...'

rm $SUBJ_DIR/anatom/cout_nl_brain_Mprage.nii
rm $SUBJ_DIR/anatom/l_brain_Mprage.nii
rm $SUBJ_DIR/anatom/brain_Mprage_to_*.log