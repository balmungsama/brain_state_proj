TOP_DIR='/home/hpc3586/OSU_data/OSU_allrawdata_backup'
OUT_DIR='/home/hpc3586/OSU_data/all_233'

cd $TOP_DIR

subj_ls=($(ls))

for subj in ${subj_ls[@]}; do
	cp $subj/data/Resting.nii $OUT_DIR/$subj/task_data/Resting.nii
done