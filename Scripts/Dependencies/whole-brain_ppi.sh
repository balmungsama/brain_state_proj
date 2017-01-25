

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
	
done


###########################################################

for roi in $(ls $ROI_DIR); do
	roi=${roi%'.nii.gz'*}

	fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

done