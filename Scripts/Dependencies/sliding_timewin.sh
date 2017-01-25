TOP_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
ROI_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/roidir_john'

t_win=15
t_skip=5

cd $TOP_DIR

for subj in $(ls); do

  # if [ "$subj" -gt "2357" ]; then
  #   continue
  # fi

  cd $subj
  echo  $subj

  N_pts=$(fslnvols fun/s_norm*.nii.gz)
  num_wins=$(expr $N_pts / $t_skip) # number of time points in the 4D scan
  start_pt=$(expr $N_pts - $(expr $num_wins \* $t_skip) )
  start_pt=$(expr $start_pt + 1) #starting point for the sliding time window

  cur_point=$start_pt

  num_wins=$(expr $num_wins - $(expr $(expr $t_win - $t_skip) / $t_skip) ) # how many sliding windows are generated?

  mkdir roi_tcourses
  cd roi_tcourses
  for roi in $(ls $ROI_DIR); do
    roi=${roi%'.nii.gz'*}

    fslstats -t ../fun/s_norm*.nii.gz -k $ROI_DIR/$roi'.nii.gz' -M > $roi'_tcourse.txt'

  done
  cd ..

  cd $TOP_DIR
done
