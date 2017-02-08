#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -M hpc3586@localhost
#$ -m be
#$ -o STD.out
#$ -e STD.err

clear

TOP_DIR='/home/hpc3586/OSU_data/first20' # master directory containing group data
TEMPLATE='/home/hpc3586/MNI_templates/MNI152_T1_1mm_brain.nii.gz'              # file for the standardized template. If not specified, default to MNI152 2mm T1
TMP_DIR=$TOP_DIR/../qsub_preproc_$(basename $TOP_DIR)

mkdir $TMP_DIR

###########################
####### PREPROCESS ########
###########################

######## LOOP GROUP ########

for SUBJECT in $(ls $TOP_DIR); do
	SUBJ_NM=$(basename $SUBJECT)

	# Identify the skull-stripped T1 scan

	SUBJ_ANAT=$TOP_DIR/$SUBJECT/anatom/Mprage_brain.nii.gz

	###### MC & FUNC NORMALIZATION ######

	COUNT=0
	for RUN in $(ls $TOP_DIR/$SUBJECT/rest/*.nii.gz); do
		echo SUBJECT is $SUBJ_NM

		RUN=$(basename $RUN)
		COUNT=$(expr $COUNT + 1)

		IND_FILE=$TMP_DIR/s_$SUBJ_NM'_'"${RUN%%.*}".sh
		touch $IND_FILE

		echo "#!/bin/bash" >> $IND_FILE
		echo "#$ -S /bin/bash" >> $IND_FILE
		echo "#$ -cwd" >> $IND_FILE
		echo "#$ -M hpc3586@localhost" >> $IND_FILE
		echo "#$ -m be" >> $IND_FILE
		echo "#$ -o $TMP_DIR/STD.out" >> $IND_FILE
		echo "#$ -e $TMP_DIR/STD.err" >> $IND_FILE

		echo ' ' >> $IND_FILE

		echo "TOP_DIR=$TOP_DIR" >> $IND_FILE
		echo "SUBJ_ANAT=$SUBJ_ANAT" >> $IND_FILE

	# Running Motion-Correction
		echo "mcflirt -in $TOP_DIR/$SUBJECT/rest/$RUN -o $TOP_DIR/$SUBJECT/rest/m_$RUN" >> $IND_FILE # Motion Correction
	# Linear-warping functional to structural
		echo "flirt -ref $SUBJ_ANAT -in $TOP_DIR/$SUBJECT/rest/m_$RUN -omat $TOP_DIR/$SUBJECT/rest/func2str_$COUNT.mat -dof 6" >> $IND_FILE           # Functional to Structural
	# Linear-warping structural to standard template
		echo "flirt -ref $TEMPLATE -in $SUBJ_ANAT -omat $TOP_DIR/$SUBJECT/anatom/aff_str2std.mat -out $TOP_DIR/$SUBJECT/anatom/std_Mprage_brain.nii.gz" >> $IND_FILE  # Strcut to Std
	# Non-linear-warping structural to standard template
		echo "fnirt --ref=$TEMPLATE --in=$SUBJ_ANAT --aff=$TOP_DIR/$SUBJECT/anatom/aff_str2std.mat --cout=$TOP_DIR/$SUBJECT/anatom/warp_str2std.nii.gz" >> $IND_FILE # FNIRT strct to std
	# Applying standardized warp to functional data
		echo "applywarp --ref=$TEMPLATE --in=$TOP_DIR/$SUBJECT/rest/m_$RUN --out=$TOP_DIR/$SUBJECT/rest/norm_m_$RUN.nii --warp=$TOP_DIR/$SUBJECT/anatom/warp_str2std.nii.gz --premat=$TOP_DIR/$SUBJECT/rest/func2str_$COUNT.mat" >> $IND_FILE
	# Applying spatial smoothing kernel
		echo "fslmaths $TOP_DIR/$SUBJECT/rest/norm_m_$RUN.nii -kernel gauss 2.54798709 -fmean $TOP_DIR/$SUBJECT/rest/s_norm_m_$RUN.nii" >> $IND_FILE

		chmod +x $IND_FILE

		qsub -q abaqus.q $IND_FILE
	done


done