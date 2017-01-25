TOP_DIR=<input>
TASK_DIR=<input> # must be relative path
ROI_DIR=<input>
DEL_VOLs=<input>
TASK_TSERIES=<input>

# while getopts mode:win:skip:path:roi: option
# do
# 	case "${option}"
# 	in
# 		mode) mode=${OPTARG};;
# 		win) t_win=${OPTARG};;
# 		skip) t_skip=${OPTARG};;
# 		path) path=${OPTARG};;
# 		roi) ROI_DIR=${OPTARG};;
# 	esac
# done

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
	
	cp $template_fsf $subj/$TASK_DIR/
	mv $subj/$TASK_DIR/ppi_feat_template.fsf $subj/$TASK_DIR/ppi_task.fsf
	
	mkdir $subj/$TASK_DIR'_feat'
	tot_runs=$(ls $subj/$TASK_DIR/s_norm*.nii.gz)
	for run in $tot_runs; do

		FS_info=$(fslinfo $run)
		FS_info=($FS_info)

		TR_in_sec=${FS_info[19]}
		NUM_VOLs=${FS_info[9]}

		for roi in $(ls $ROI_DIR); do

			### NEED TO CREATE THE ROI TIME SERIES
			
			roi_nm=$(basename $roi)

			### PROBLEM: Some of these substitutions have dashes in them. FIX THIS.
			##
			# sed -ie 's/'few'/'asd'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***OUTPUT_DIR/'$subj/$TASK_DIR'_feat''/g' $subj/$TASK_DIR/ppi_task.fsf 
			sed -ie 's/***TR_in_sec/'$TR_in_sec'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***NUM_VOLs/'$NUM_VOLs'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***DEL_VOLs/'$DEL_VOLs'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***FUN_DATA/'$run'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***TASK_TSERIES/'$TASK_TSERIES'/g' $subj/$TASK_DIR/ppi_task.fsf
			sed -ie 's/***ROI_TSERIES/'$ROI_TSERIES'/g' $subj/$TASK_DIR/ppi_task.fsf

		done
	done
done


###########################################################

for roi in $(ls $ROI_DIR); do
	roi=${roi%'.nii.gz'*}

	fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

done