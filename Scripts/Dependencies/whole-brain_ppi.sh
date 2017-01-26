while getopts mode:path:task:roi:del:high: option
do
	case "${option}"
		in
		mode) TYPE      =${OPTARG};;
		path) TOP_DIR   =${OPTARG};;
		task) TASK_DIR  =${OPTARG};;
		roi)  ROI_DIR   =${OPTARG};;
		del)  DEL_VOLs  =${OPTARG};;
		high) HIGH_PASS =${OPTARG};;
	esac
done

template_fsf='Dependencies/req_files/ppi_feat_template.fsf'  # make this relative to wherever this package is located

cd TOP_DIR

if [ "$TYPE" == 'group' ]; then
	subj_dirs=$(ls)
else
	if [ "$TYPE" == 'subj' ]; then
		subj_dirs='/'
	else
		echo "Please selct either 'group' or 'subj'"
	fi
fi

for subj in $subj_dirs; do
	
	subj_nm=$(basename $subj)
	tot_runs=$(ls $subj/$TASK_DIR/s_norm*.nii.gz)
	mkdir $subj/ppi_results
	
	COUNT=0
	for run in $tot_runs; do

		run_nm=$(basename run)

		FS_info=$(fslinfo $run)
		FS_info=($FS_info)

		TR_in_sec=${FS_info[19]}
		NUM_VOLs=${FS_info[9]}

		TASK_ls=($(ls $TASK_DIR/*.txt))

		for roi in $(ls $ROI_DIR); do

			fslstats -t $run -k $roi -M > $TASK_DIR/tmp_roi_tcourse.txt

			cp $template_fsf $subj/$TASK_DIR/
			mv $subj/$TASK_DIR/ppi_feat_template.fsf $subj/$TASK_DIR/ppi_task.fsf

			### NEED TO CREATE THE ROI TIME SERIES
			
			roi_nm=$(basename $roi)

			### PROBLEM: Some of these substitutions have dashes in them. FIX THIS.
			##
			# sed -ie 's/'few'/'asd'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's?***OUTPUT_DIR?'$subj/$TASK_DIR'?g' $subj/$TASK_DIR/ppi_task.fsf 
			
			sed -ie 's?***TR_in_sec?'$TR_in_sec'?g' $subj/$TASK_DIR/ppi_task.fsf
			
			sed -ie 's?***NUM_VOLs?'$NUM_VOLs'?g' $subj/$TASK_DIR/ppi_task.fsf
			
			sed -ie 's?***DEL_VOLs?'$DEL_VOLs'?g' $subj/$TASK_DIR/ppi_task.fsf
			
			sed -ie 's?***FUN_DATA?'$run'?g' $subj/$TASK_DIR/ppi_task.fsf
			
			sed -ie 's?***TASK_TSERIES?'${TASK_ls[$COUNT]}'?g' $subj/$TASK_DIR/ppi_task.fsf
			
			sed -ie 's?***ROI_TSERIES?'$ROI_TSERIES'?g' $subj/$TASK_DIR/ppi_task.fsf

			sed -ie 's?***HIGH_PASS?'$HIGH_PASS'?g' $subj/$TASK_DIR/ppi_task.fsf

			feat $subj/$TASK_DIR/ppi_task.fsf

			mv $subj/$TASK_DIR'.feat'/thresh_zstat3.nii.gz $subj/ppi_results/$roi_nm'_'$subj_nm'_'$run_nm.nii.gz

			rm -r $subj/$TASK_DIR'.feat'
			rm $subj/$TASK_DIR/ppi_task.fsf
			rm $TASK_DIR/tmp_roi_tcourse.txt

			COUNT=$(( $COUNT + 1 ))

		done
	done
done


###########################################################

# for roi in $(ls $ROI_DIR); do
# 	roi=${roi%'.nii.gz'*}

# 	fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

# done