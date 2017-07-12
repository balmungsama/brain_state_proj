cd [ SUBJ_DIR ];

subj_nifti = load_nii([ 'task_data/preproc/scrub_snl_norm_mt_' COND '.nii' ]);

CONFOUND = importdata([ 'mot_analysis/' COND '_CONFOUND.par' ]);
CONFOUND = sum(CONFOUND, 2);

censorFlag = find(CONFOUND == 1);

volnum.orig = subj_nifti.hdr.dime.dim(5);
volnum.new  = volnum.orig - sum(CONFOUND);

subj_nifti.img(:,:,:,censorFlag) = [];

subj_nifti.hdr.dime.dim(5)          = volnum.new;
subj_nifti.original.hdr.dime.dim(5) = volnum.new;

save_nii( subj_nifti, ['task_data/preproc/censor_snl_norm_mt_' COND '.nii'] )

exit