#!/bin/bash
##

script_path='/home/hpc3586/JE_packages/brain_state_proj/Scripts'

DATE=$(date +%y-%m-%d)

clear
echo "WELCOME TO THE BRAIN STATE"
echo '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
echo ' '
echo "What would you like to do?"
echo ' '
echo '1. Compute group-specific ROIs using an ICA analysis.'
echo '2. Compute sliding time windows for a set of ROIs (subj or group).'
echo '3. Compute brain states.'
echo '4. Find relations between frequency of brain states and behavioural performance.'
echo '5. Perform a whole-brain PPI to find FC patterns associated with behavioural performance.'
echo ' '
echo -n 'Pick a number:  '
read DATA

echo ' '
echo ' '

case $DATA in

	1) echo "ROI - Independent Components Analysis"
	  echo "--------------------"
		echo " "
		echo -n "Are you running a group or one subject? ('group' or 'subj'):  "
		read mode
		echo -n "Enter the $mode directory:  "
		read path
		echo -n "Enter the name of the condition being analyzed:  "
		read cond
		echo -n "Enter the output directory for the ROIs:  "
		read output
		echo -n "How many ROIs would you like? (leave blank if you want this to not be fixed a-priori):  "
		read nROI

		mkdir -p $script_path/logs 

		if [[ ${#nROI} == 0 ]]; then nROI='default'; fi

		if [[ $mode == "subj" ]]; then

			subj=$path
			mkdir -p $subj/roi_tcourses
			mkdir -p logs/$DATE
			name=$(basename $subj)

			qsub -N roi_$name -e $script_path/logs/$DATE/roi_$name.err -o $script_path/logs/$DATE/roi_$name.out $script_path/Dependencies/rm_vols.sh $subj $cond $output $script_path $nROI
			qsub -N ICA_$cond -e $script_path/logs/$DATE/ica_$name.err -o $script_path/logs/$DATE/ica_$name.out -hold_jid 'roi_*' $script_path/Dependencies/ICA_ROI.sh $subj $cond $output $script_path $nROI
		elif [[ $mode == "group" ]]; then

			for subj in $(ls $path); do

				mkdir -p $path/$subj/roi_tcourses
				mkdir -p logs/$DATE
				name=$(basename $subj)

				qsub -N roi_$name -e $script_path/logs/$DATE/roi_$name.err -o $script_path/logs/$DATE/roi_$name.out $script_path/Dependencies/rm_vols.sh $path/$subj $cond $output $script_path $nROI

			done

			qsub -N ICA_$cond -e $script_path/logs/$DATE/ica_$cond.err -o $script_path/logs/$DATE/ica_$cond.out -hold_jid /roi_ $script_path/Dependencies/ICA_ROI.sh $path $cond $output $script_path $nROI $mode

		else
				echo "Please enter either 'subj' or 'group'"
		fi
	;;
	2)	echo "Sliding time windows"
		echo "--------------------"
		echo " "
		echo -n "Are you running a group or one subject? ('group' or 'subj'):  "
		read mode
		echo -n "Enter the $mode directory:  "
		read path
		echo -n "Enter the directory containing ROI files:  "
		read roi
		echo -n "Enter the name of the condition being analyzed:  "
		read cond
		echo -n "Size of the time windows (in TR):  "
		read t_win
		echo -n "Size of the time skip (in TR):  "
		read t_skip

		clear
		echo "Creating ROI time courses..."
		# qsub -q abaqus.q Dependencies/sliding_timewin.sh $mode $t_win $t_skip $path $roi $cond 
		# echo $mode

		##### to submit the jobs #####

		mkdir -p $script_path/logs 

		if [[ $mode == "subj" ]]; then

			subj=$path

			mkdir -p $subj/roi_tcourses

			qsub -q abaqus.q $script_path/Dependencies/sliding_timewin.sh $mode $t_win $t_skip $path $roi $cond 

		elif [[ $mode == "group" ]]; then

				for subj in $(ls $path); do


					mkdir -p $path/$subj/roi_tcourses

					qsub -q abaqus.q -N pp_$subj -o $script_path/logs/$DATE/pp_$subj.out -e $script_path/logs/$DATE/pp_$subj.err $script_path/Dependencies/sliding_timewin.sh $mode $t_win $t_skip $path/$subj $roi $cond 


				done

		else
				echo "Please enter either 'subj' or 'group'"
		fi

		echo "Finished."
		;;
	3)	echo "FC Matrices & K-means clustering"
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
		echo -n "Size of the time window (in TRs):	"
		read win_sz
		echo -n "Size of the time skip (in TRs):	"
		read tskip

		clear
		echo 'Computing correlation matrices...'
		Rscript Dependencies/k_means_clustering_beta3.R $TYPE $TOP_DIR $ROI_LABELS $lateralized $kk $kk_reps $conf_lvl $kk_pool $win_sz $tskip
		echo 'Finished.'
		;;
	4)
		echo "Correlate brain state frequency with behavioural performance"
		;;

	5)
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
