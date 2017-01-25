###########################
######## HELP TEXT ########
###########################

if [ "$1" == "--help" ]; then
	echo "Usage: `basename $0` [some stuff]"
	exit 0
fi

clear

TOP_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john' # master directory containing group data
TEMPLATE=              # file for the standardized template. If not specified, default to MNI152 2mm T1

TR_SKIP=2

###########################
######## SETTINGS #########
###########################

SKULL_STRIP=1 ### 1 = FSL (BET); 2 = AFNI (3dSkullStrip), 3 = AFNI (3dSkullStrip, -push-to-edge)

if [ -n "$TEMPLATE" ]; then
	echo ''
else
	TEMPLATE=/usr/share/fsl/5.0/data/standard/MNI152_T1_2mm_brain.nii.gz
fi

###########################
####### PREPROCESS ########
###########################

cd $TOP_DIR

######## LOOP GROUP ########

echo ' '
echo "Let's preprocess some data!"
echo ' '

for SUBJECT in $(ls -d ./*); do
	cd $SUBJECT

	##### SKULL STRIPPING #####

	echo Subject: $SUBJECT
	echo '    Skull-stripping'

	cd anatom
	SUBJ_ANAT=Mprage.nii

	if (($SKULL_STRIP == 1)); then
		echo 'it is already done'
		# bet $SUBJ_ANAT 'Mprage'
	elif (($SKULL_STRIP == 2)); then
		3dSkullStrip -input $SUBJ_ANAT -prefix brain_
		3dAFNItoNIFTI -prefix brain brain_*.HEAD
		rm *+orig.*
	elif (($SKULL_STRIP == 3)); then
		3dSkullStrip -input $SUBJ_ANAT -prefix brain_edge -push_to_edge
		3dAFNItoNIFTI -prefix brain brain_*.HEAD
		rm *+orig.*
	else
		echo ERROR: Enter a value between 1 and 3.
	fi

	###### MC & FUNC NORMALIZATION ######

	cd ../fun

	COUNT=0
	for RUN in $(ls *.nii); do

		COUNT=$(expr $COUNT + 1)

		echo '    Analyzing run' $RUN

		echo '       + Running Motion-Correction...'
		mcflirt -in $RUN -o m_$RUN # Motion Correction

		##### WARP FUNC TO T1 #####

		echo '       + Linear-warping functional to structural...'
		flirt -ref ../anatom/$SUBJ_ANAT -in $RUN -omat func2str_$COUNT.mat -dof 6           # Functional to Structural
		echo '       + Linear-warping structural to standard template...'
		flirt -ref $TEMPLATE -in ../anatom/Mprage_brain.nii.gz -omat ../anatom/aff_str2std.mat -out ../anatom/std_Mprage_brain.nii.gz  # Strcut to Std
		echo '       + Non-linear-warping structural to standard template...'
		fnirt --ref=$TEMPLATE --in=../anatom/$SUBJ_ANAT --aff=../anatom/aff_str2std.mat --cout=../anatom/warp_str2std.nii.gz # FNIRT strct to std
		echo '       + Applying standardized warp to functional data...'
		applywarp --ref=$TEMPLATE --in=$RUN --out=norm_$RUN.nii --warp=../anatom/warp_str2std.nii.gz --premat=func2str_$COUNT.mat
		echo '       + Applying spatial smoothing kernel...'
		fslmaths norm_$RUN.nii -kernel gauss 2.54798709 -fmean s_norm_$RUN.nii
		echo '  '
	done

cd $TOP_DIR

done


echo ' * Your data is complete! * '
echo ' '
