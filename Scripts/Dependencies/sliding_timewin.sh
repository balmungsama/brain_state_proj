while getopts mode:win:skip:path:roi: option
do
				case "${option}"
				in
								mode) mode=${OPTARG};;
								win) t_win=${OPTARG};;
								skip) t_skip=${OPTARG};;
								path) path=${OPTARG};;
								roi) ROI_DIR=${OPTARG};;
				esac
done

if [ $mode == 'subj' ]; then 

	subj=$path
	cd   $subj
	echo $subj

	N_pts     =$(fslnvols rest/s_norm*.nii.gz)
	num_wins  =$(expr $N_pts / $t_skip) # number of time points in the 4D scan
	start_pt  =$(expr $N_pts - $(expr $num_wins \* $t_skip) )
	start_pt  =$(expr $start_pt + 1) #starting point for the sliding time window
	
	cur_point =$start_pt
	
	num_wins  =$(expr $num_wins - $(expr $(expr $t_win - $t_skip) / $t_skip) ) # how many sliding windows are generated?

	mkdir roi_tcourses
	cd roi_tcourses

	for roi in $(ls $ROI_DIR); do
		roi=${roi%'.nii.gz'*}

		fslstats -t ../rest/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

	done

else

	if [ $mode == 'group' ]

		cd $path
		for subj in $(ls); do

			cd $subj
			echo  $subj

			N_pts     =$(fslnvols rest/s_norm*.nii.gz)
			num_wins  =$(expr $N_pts / $t_skip) # number of time points in the 4D scan
			start_pt  =$(expr $N_pts - $(expr $num_wins \* $t_skip) )
			start_pt  =$(expr $start_pt + 1) #starting point for the sliding time window
			cur_point =$start_pt
			num_wins  =$(expr $num_wins - $(expr $(expr $t_win - $t_skip) / $t_skip) ) # how many sliding windows are generated?

			mkdir roi_tcourses
			cd roi_tcourses

			for roi in $(ls $ROI_DIR); do
				roi=${roi%'.nii.gz'*}
				fslstats -t ../rest/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'
			done

		done

	else
		echo "Please enter either 'subj' or 'group'"
	fi

fi