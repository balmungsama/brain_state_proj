TOP='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'

for subj_nm in $(ls $TOP); do

	subj_nm=${subj_nm%'ZL_'*}

	mkdir $TOP/$subj_nm
	mkdir $TOP/$subj_nm/anatom
	mkdir $TOP/$subj_nm/fun

	mv $TOP/$subj_nm'ZL_Resting.nii.gz' $TOP/$subj_nm/fun/
	cp '/media/member/Data1/OSU_projects/Julie/subject_data/'$subj_nm'ZL/Raw'/Mp*.nii.gz $TOP/$subj_nm/anatom/

done

for subj_dir in $(ls $TOP); do
	gunzip $TOP/$subj_dir/anatom/*.nii.gz
	gunzip $TOP/$subj_dir/fun/*.nii.gz
done
