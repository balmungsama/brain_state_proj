# while getopts mode:win:skip:path:roi: arg
# do
# 	case "${arg}" in
# 		mode) echo mode is ${OPTARG}
# 					;;
# 		win) t_win=${OPTARG}
# 					;;
# 		skip) t_skip=${OPTARG}
# 					;;
# 		path) path=${OPTARG}
# 					;;
# 		roi) ROI_DIR=${OPTARG}
# 					;;
# 	esac
# done

mode=$1
t_win=$2
t_skip=$3
path=$4
ROI_DIR=$5
cond=$6


for roi in $(ls $ROI_DIR); do
	
	roi=${roi%'.nii.gz'*}	
	
	fslmeants -i $path/task_data/preproc/scrubbed_motreg_snlmt_$cond.nii -m $ROI_DIR/$roi'.nii'* -o $path/roi_tcourses/$roi'_tcourse.txt'	

done