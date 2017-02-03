#!/bin/bash
##

# export FSF_TEMPLATE='Dependencies/req_files/ppi_feat_template.fsf'

clear
echo "WELCOME TO THE BRAIN STATE"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo ' '
echo "What would you like to do?"
echo ' '
echo '1. Compute sliding time windows for a set of ROIs (subj or group).'
echo '2. Compute brain states.'
echo '3. Find relations between frequency of brain states and behavioural performance.'
echo '4. Perform a whole-brain PPI to find FC patterns associated with behavioural performance.'
echo ' '
echo -n 'Pick a number:  '
read DATA

echo ' '
echo ' '

case $DATA in

	1)	echo "Sliding time windows"
		echo "--------------------"
		echo " "
		echo -n "Are you running a group or one subject? ('group' or 'subj'):  "
		read mode
		echo -n "Enter the $mode directory:  "
		read path
		echo -n "Enter the directory for ROI files:  "
		read roi
		echo -n "Size of the time windows (in TR):  "
		read t_win
		echo -n "Size of the time skip (in TR):  "
		read t_skip

		clear
		echo "Creating ROI time courses..."
		./Dependencies/sliding_timewin.sh $mode $t_win $t_skip $path $roi
		# echo $mode
		echo "Finished."
		;;
	2)
		echo "FC Matrices & K-means clustering"
		echo "--------------------------------"
		echo " "
		echo -n "Are you running a group or one subject? ('group' or 'subj'):  "
		read TYPE
		echo -n "Enter the $TYPE directory:  "
		read TOP_DIR
		echo -n "Enter the directory for ROI labels:  "
		read ROI_LABELS
		echo -n "Are these ROIs lateralized (i.e., begin with 'L. ' / 'R. ')? T or F?  "
		read lateralized
		echo -n "Enter the range of clusters you would like to use (<start> : <stop>) :  "
		read kk
		echo -n "How many iterations would you like to run this for?  "
		read kk_reps
		echo -n "Enter confidence level for AIC/BIC estimations (0 to 1, 0.95 default):  "
		read conf_lvl
		echo -n "Number of iterations used to synthesize representative clusters:  < NOT CURRENTLY WORKING >"
		read kk_pool
		kk_pool=1 ####### to remove once this if fixed

		clear
		echo 'Computing correlation matrices...'
		Rscript Dependencies/k_means_clustering_beta3.R $TYPE $TOP_DIR $ROI_LABELS $lateralized $kk $kk_reps $conf_lvl $kk_pool
		echo 'Finished.'
		;;
	3)
		echo "Correlate brain state frequency with behavioural performance"
		;;

	4)
		echo "Whole-brain PPI analysis"
		echo "------------------------"
		echo -n "Are you running a group or one subject? ('group' or 'subj'):  "
		read TYPE
		echo -n "Enter the $TYPE directory:  "
		read TOP_DIR
		echo -n "Enter the path for ROI files:  "
		read ROI
		echo -n "Enter the task name:  "
		read TASK
		echo -n "How many volumes should be deleted?  "
		read DEL
		echo -n "What high-pass filter would you like to apply? (Hz):  "
		read HIGH

		clear
		./Dependencies/whole_brain_ppi.sh $TYPE $TOP_DIR $TASK $ROI $DEL $HIGH
		;;

	*)
		echo ' '
		echo "That's not an option. You always ask too much of me."
		echo ' '

esac
