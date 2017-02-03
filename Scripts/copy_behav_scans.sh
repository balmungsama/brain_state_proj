TOP_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'

cd $TOP_DIR
subjs=$(ls)

for subj in $subjs; do
	mkdir $subj/task_data
	cp /media/member/Data1/OSU_allrawdata_backup/$subj'ZL'/data/GoNogo.nii.gz $subj/task_data/
done
