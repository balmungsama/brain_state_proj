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

if [[ $mode == "subj" ]]; then

	subj=$path
	cd $subj
	echo '	$subj'

	mkdir roi_tcourses
	cd roi_tcourses

	for roi in $(ls $ROI_DIR); do
		roi=${roi%'.nii.gz'*}

		fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

	done

elif [[ $mode == "group" ]]; then
		cd $path
		for subj in $(ls); do

			cd $subj
			echo '	$subj'

			mkdir roi_tcourses
			cd roi_tcourses

			for roi in $(ls $ROI_DIR); do
				# echo $roi
				roi=${roi%'.nii.gz'*}
				fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'
			done

			cd $path

		done

else
		echo "Please enter either 'subj' or 'group'"
fi
