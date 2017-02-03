# while getopts mode:path:task:roi:del:high: option
# do
# 	case "${option}"
# 		in
# 		mode) TYPE=${OPTARG};;
# 		path) TOP_DIR=${OPTARG};;
# 		task) TASK_NM=${OPTARG};;
# 		roi) ROI_DIR=${OPTARG};;
# 		del) DEL_VOLs=${OPTARG};;
# 		high) HIGH_PASS=${OPTARG};;
# 	esac
# done

TYPE=$1
TOP_DIR=$2
TASK_NM=$3
ROI_DIR=$4
DEL_VOLs=$5
HIGH_PASS=$6

echo ' '

# template_fsf=$FSF_TEMPLATE  # make this relative to wherever this package is located
FSF_TEMPLATE='/media/member/Data1/Thalia/brain_variability_osu_data/priv_john_proj/brain_state_proj/Scripts/Dependencies/req_files/ppi_feat_template.fsf'
NUM_ROIS=$(expr $(ls $ROI_DIR -l | wc -l) - 1)

cd $TOP_DIR

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
	tot_runs=$subj/task_data/s_norm_m_$TASK_NM.nii.gz
	mkdir $subj/ppi_results

	echo "Running subject $subj_nm ..."

	COUNT=0
	for run in $tot_runs; do

		run_nm=$(basename $run)

		FS_info=($(fslinfo $run))

		TR_in_sec=${FS_info[19]}
		NUM_VOLs=${FS_info[9]}

		TASK_ls=$subj/behav_ons/$TASK_NM.txt # adapt this so it works with multiple runs

		for roi in $(ls $ROI_DIR); do

			roi_nm=$(basename -s '.nii.gz' $roi )
			echo "	+ Extracting ROI time course - $roi_nm ... "

			fslmeants -i $TOP_DIR/$run -m $ROI_DIR/$roi -o $TOP_DIR/$subj/tmp_roi_tcourse.txt
			ROI_TSERIES=$subj/tmp_roi_tcourse.txt

			cp $FSF_TEMPLATE $subj/task_data/
			mv $subj/task_data/ppi_feat_template.fsf $subj/task_data/ppi_task.fsf

			### NEED TO CREATE THE ROI TIME SERIES

			sed -ie 's#\*\*\*OUTPUT_DIR#"'$TOP_DIR/$subj/task_data'"#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*TR_in_sec#'$TR_in_sec'#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*NUM_VOLs#'$NUM_VOLs'#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*DEL_VOLs#'$DEL_VOLs'#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*FUN_DATA#"'$TOP_DIR/$run'"#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*TASK_TSERIES#"'$TOP_DIR/$subj/behav_ons/$subj_nm'_'$TASK_NM'.txt"#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*ROI_TSERIES#"'$TOP_DIR/$ROI_TSERIES'"#g' $subj/task_data/ppi_task.fsf

			sed -ie 's#\*\*\*HIGH_PASS#'$HIGH_PASS'#g' $subj/task_data/ppi_task.fsf

			echo "	+ Running PPI ... "
			feat $TOP_DIR/$subj/task_data/ppi_task.fsf
			mv $TOP_DIR/$subj/task_data.feat/stats/zstat3.nii.gz $TOP_DIR/$subj/ppi_results/$roi_nm'_'$subj_nm'_'$TASK_NM.nii.gz

			rm -r $TOP_DIR/$subj/task_data.feat
			rm $TOP_DIR/$subj/task_data/ppi_task.fsf
			rm $TOP_DIR/$ROI_TSERIES

			COUNT=$(( $COUNT + 1 ))

			echo "	  Done ROI # $COUNT/$NUM_ROIS"
			echo " "

		done

		mkdir $TOP_DIR/$subj/ppi_results/contrsuct_matrix
		for ppi_out in $(ls $TOP_DIR/$subj/ppi_results/*$TASK_NM.nii.gz); do 
			ppi_nm=$(basename $ppi_out)
			ppi_nm=($(echo $ppi_nm | tr "_" "\n"))
			ppi_nm=${ppi_nm[0]}

			for roi in $(ls $ROI_DIR); do
				roi_nm=$(basename -s '.nii.gz' $roi )
				fslstats $ppi_out -k $ROI_DIR/$roi -M > $TOP_DIR/$subj/ppi_results/contrsuct_matrix/$ppi_nm'_'$roi_nm'_'$TASK_NM.txt
			done
		done

		Rscript construct_task_mat.R $TASK_NM $TOP_DIR/$subj/ppi_results/contrsuct_matrix

	done
done
