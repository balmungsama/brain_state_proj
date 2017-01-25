TOP_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
ROI_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/roidir_john'

t_win=15
t_skip=5


cd $TOP_DIR

for subj in $(ls); do
  cd $subj

  mkdir time_pts

  N_pts=$(fslnvols fun/s_norm*.nii.gz)

  num_wins=$(expr $N_pts / $t_skip) # number of time points in the 4D scan
  start_pt=$(expr $N_pts - $(expr $num_wins \* $t_skip) )
  start_pt=$(expr $start_pt + 1) #starting point for the sliding time window

  fslsplit fun/s_norm*.nii.gz time_pts/

  ls time_pts/ > vol_list.txt

  cur_point=$start_pt

  num_wins=$(expr $num_wins - $(expr $(expr $t_win - $t_skip) / $t_skip) ) # how many sliding windows are generated?


  mkdir win_vols
  for ((nn=1;nn<=$num_wins;nn++)); do
    sed -n $cur_point,$(expr $cur_point + $(expr $t_win - 1))p vol_list.txt > vols_in_win.txt

    cd time_pts
    fslmerge -t ../win_vols/vol_$cur_point'_'$(expr $cur_point + $(expr $t_win - 1)) $(echo $(cat ../vols_in_win.txt))
    cd ..

    cur_point=$(expr $cur_point + $t_skip)


  done

  mkdir roi_tcourses
  cd roi_tcourses
  for roi in $(ls $ROI_DIR); do
    roi=${roi%'.nii.gz'*}

    for win in $(ls ../win_vols); do
      win=${win%'.nii.gz'*}
      fslstats -t ../win_vols/$win.nii.gz -M -k $ROI_DIR/$roi'.nii.gz' > $roi'_'$win'_tcourse.txt'
    done

  done
  cd ..

  cd $TOP_DIR
done
