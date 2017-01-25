GRP_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john'
K_DIR='/media/member/Data1/Thalia/brain_variability_osu_data/k_clusters'

k_list=$K_DIR/'kclus_*.txt'

IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

for kclus in $k_list; do
  clus_nm=$(basename -s .txt $kclus)
  echo $clus_nm

  k_dir=$K_DIR/$clus_nm'_FILES'
  mkdir $k_dir

  while read curr_k; do

    curr_k=${curr_k//'"'}
    # echo $curr_k
    base=$(echo "$curr_k" | grep -oP "^$GRP_DIR/\K.*")
    subj=${base%%/*}
    vol=${base##*/}
    echo subj = $subj
    echo vol = $vol

    cp $curr_k $k_dir/$subj'_'$vol

    echo ' '

  done < $kclus

  fslmerge -t $K_DIR/nifti_imgs/$clus_nm'.nii.gz' $K_DIR/$clus_nm'_FILES'/*
  rm -r $K_DIR/$clus_nm'_FILES'/*
  fslmaths $K_DIR/nifti_imgs/$clus_nm'.nii.gz' -Tmean $K_DIR/nifti_imgs/avg_$clus_nm'.nii.gz'

done
