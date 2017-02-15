#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -o STD.out
#$ -e STD.err


TYPE='group'
TOP_DIR='/home/hpc3586/OSU_data/first100'
TASK_NM='GoNogo'
ROI_DIR='/home/hpc3586/OSU_data/roi_dir'
DEL_VOLs=0
HIGH_PASS=0

FSF_TEMPLATE='/media/member/Data1/Thalia/brain_variability_osu_data/priv_john_proj/brain_state_proj/Scripts/Dependencies/req_files/ppi_feat_template.fsf'
NUM_ROIS=$(expr $(ls $ROI_DIR -l | wc -l) - 1)

TMP_DIR=$TOP_DIR/../qsub_preproc_$(basename $TOP_DIR)

mkdir -p $TOP_DIR/task_ppi_matrices
mkdir -p $TMP_DIR

if [ "$TYPE" == 'group' ]; then
	subj_dirs=$(ls -d $TOP_DIR/*)
else
	if [ "$TYPE" == 'subj' ]; then
		subj_dirs='/'
	else
		echo "Please selct either 'group' or 'subj'"
	fi
fi

for subj in $subj_dirs; do

	echo subj is $subj

	if [ "$subj" == "task_ppi_matrices" ]; then 
		continue
	fi

	subj_nm=$(basename $subj)
	tot_runs=$subj/task_data/s_norm_m_$TASK_NM.nii.gz
	mkdir $subj/ppi_results

	echo "Running subject $subj_nm ..."

	COUNT=0
	for run in $tot_runs; do

		run_nm=$(basename '.nii.gz' $run)

		IND_FILE=$TMP_DIR/s_$subj_nm'_'$run_nm.sh ### FILL THIS OUT ###
		touch $IND_FILE

		echo "#!/bin/bash" >> $IND_FILE
		echo "#$ -S /bin/bash" >> $IND_FILE
		echo "#$ -cwd" >> $IND_FILE
		echo "#$ -M hpc3586@localhost" >> $IND_FILE
		echo "#$ -m be" >> $IND_FILE
		echo "#$ -o $TMP_DIR/STD.out" >> $IND_FILE
		echo "#$ -e $TMP_DIR/STD.err" >> $IND_FILE

		echo ' ' >> $IND_FILE

		echo TYPE=$TYPE >> $IND_FILE
		echo TOP_DIR=$TOP_DIR >> $IND_FILE
		echo TASK_NM=$TASK_NM >> $IND_FILE
		echo ROI_DIR=$ROI_DIR >> $IND_FILE
		echo DEL_VOLs=$DEL_VOLs >> $IND_FILE
		echo HIGH_PASS=$HIGH_PASS >> $IND_FILE

		echo ' ' >> $IND_FILE

		echo "FS_info=($(fslinfo $run))" >> $IND_FILE
		echo TR_in_sec=${FS_info[19]} >> $IND_FILE
		echo NUM_VOLs=${FS_info[9]} >> $IND_FILE

		echo ' ' >> $IND_FILE

		echo "for roi in $(ls $ROI_DIR); do" >> $IND_FILE
 
		echo 	roi_nm=$(basename '.nii.gz' $roi ) >> $IND_FILE
		echo 	echo "	+ Extracting ROI time course - $roi_nm ... " >> $IND_FILE
 
		echo 	ROI_TSERIES=$subj/tmp_roi_tcourse.txt >> $IND_FILE
 
		echo 	cp $FSF_TEMPLATE $subj/task_data/ >> $IND_FILE
		echo 	mv $subj/task_data/ppi_feat_template.fsf $subj/task_data/ppi_task.fsf >> $IND_FILE
  
		echo 	sed -ie 's#\*\*\*OUTPUT_DIR#"'$subj/task_data'"#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*TR_in_sec#'$TR_in_sec'#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*NUM_VOLs#'$NUM_VOLs'#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*DEL_VOLs#'$DEL_VOLs'#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*FUN_DATA#"'$run'"#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*TASK_TSERIES#"'$subj/behav_ons/$subj_nm'_'$TASK_NM'.txt"#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*ROI_TSERIES#"'$TOP_DIR/$ROI_TSERIES'"#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	sed -ie 's#\*\*\*HIGH_PASS#'$HIGH_PASS'#g' $subj/task_data/ppi_task.fsf >> $IND_FILE
 
		echo 	echo "	+ Running PPI ... " >> $IND_FILE
		echo 	feat $subj/task_data/ppi_task.fsf >> $IND_FILE
		echo 	mv $subj/task_data.feat/stats/zstat3.nii.gz $TOP_DIR/$subj/ppi_results/$roi_nm'_'$subj_nm'_'$TASK_NM.nii.gz >> $IND_FILE
 
		echo 	rm -r $subj/task_data.feat >> $IND_FILE
		echo 	rm $subj/task_data/ppi_task.fsf >> $IND_FILE
		echo 	rm $TOP_DIR/$ROI_TSERIES >> $IND_FILE
 
		echo 	COUNT=$(( $COUNT + 1 )) >> $IND_FILE
 
		echo done >> $IND_FILE
 
		echo ' ' >> $IND_FILE

		echo mkdir $subj/ppi_results/contrsuct_matrix >> $IND_FILE
		echo "for ppi_out in $(ls $subj/ppi_results/*$TASK_NM.nii.gz); do" >> $IND_FILE
		echo 	ppi_nm=$(basename $ppi_out) >> $IND_FILE
		echo "	ppi_nm=($(echo $ppi_nm | tr "_" "\n"))" >> $IND_FILE
		echo 	ppi_nm=${ppi_nm[0]} >> $IND_FILE

		echo '~~~~~~~~~~~~~~~~~~~ line 130 ~~~~~~~~~~~~~~~~~~~'
 
		echo "	for roi in $(ls $ROI_DIR); do" >> $IND_FILE
		echo 		roi_nm=$(basename -s '.nii.gz' $roi ) >> $IND_FILE
		echo 		fslmeants -i $ppi_out -m $ROI_DIR/$roi -o $subj/ppi_results/contrsuct_matrix/$ppi_nm'_'$roi_nm'_'$TASK_NM.txt >> $IND_FILE
		echo 	done >> $IND_FILE
		echo done >> $IND_FILE

		echo Rscript.bak /media/member/Data1/Thalia/brain_variability_osu_data/priv_john_proj/brain_state_proj/Scripts/Dependencies/construct_task_mat.R "$TASK_NM" "$subj/ppi_results/contrsuct_matrix" >> $IND_FILE

		echo ' ' >> $IND_FILE

		echo subj_nm=$(basename $subj) >> $IND_FILE
		echo cp $subj/ppi_results/construct_matrix/matrix/$TASK_NM*.csv $TOP_DIR/task_ppi_matrices/$subj_nm'_'$TASK_NM.csv >> $IND_FILE
	done
done

# Rscript.bak /media/member/Data1/Thalia/brain_variability_osu_data/priv_john_proj/brain_state_proj/Scripts/Dependencies/avg_ppi_mat.R $TOP_DIR $TASK_NM