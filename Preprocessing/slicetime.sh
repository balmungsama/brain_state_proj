# SUBJ_DIR='/mnt/c/Users/john/Documents/sample_fmri/2357ZL'  # subject directory
# COND='Retrieval'

SUBJ_DIR=$1
COND=$2

echo '	slice-time correction...'

mkdir $SUBJ_DIR/task_data/preproc

# get TR length
TR=$(3dinfo -tr $SUBJ_DIR/task_data/$COND.nii*)

# get header info
header_info=$(fslhd $SUBJ_DIR/task_data/$COND)

# determine if the acquisition of functional data was interleaved 
slice_order=$(echo "$header_info" | grep -n "slice_name")
slice_order=$(echo ${slice_order##* })

#detec the dimension along which slices were aquired
slice_dim=$(echo "$header_info" | grep -n "slice_dim")
slice_dim=$(echo ${slice_dim##* })

# set options for slice-time correction
slice_options="-r $TR -d $slice_dim"
if [[ $slice_order = *"alternating"* ]]; then 
  slice_options="$slice_options --odd"
fi

if [[ $slice_order = *"decreasing"* ]]; then 
  slice_options="$slice_options --down"
fi

# run slcie-time correction
slicetimer -i $SUBJ_DIR/task_data/$COND \
  -o $SUBJ_DIR/task_data/preproc/t_$COND $slice_options