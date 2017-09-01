%%%%%%%%%%%%%%%%%%%%%%
%% trouble-shooting %%
%%%%%%%%%%%%%%%%%%%%%%

disp('mot_censor.m')
disp( ['SUBJ_DIR = ', SUBJ_DIR ] );
disp( ['COND = ', COND ] );

%%%%%%%%%%
%% main %%
%%%%%%%%%%

cd(SUBJ_DIR);

if FIN == false 
	INPUT  = [ 'task_data/preproc/scrub_snl_norm_mt_' COND '.nii' ]
	OUTPUT = ['task_data/preproc/censor_snl_norm_mt_' COND '.nii']
elseif FIN == true
	INPUT  = [ 'task_data/preproc/scrub_filt_interp_nuis_snl_norm_mt_' COND '.nii' ]
	OUTPUT = ['task_data/preproc/censor_filt_interp_nuis_snl_norm_mt_' COND '.nii']
end

subj_nifti = load_nii(INPUT);

CONFOUND = importdata([ 'mot_analysis/' COND '_CONFOUND.par' ]);
CONFOUND = sum(CONFOUND, 2);

censorFlag = find(CONFOUND == 1);

volnum.orig = subj_nifti.hdr.dime.dim(5);
volnum.new  = volnum.orig - sum(CONFOUND);

subj_nifti.img(:,:,:,censorFlag) = [];

subj_nifti.hdr.dime.dim(5)          = volnum.new;
subj_nifti.original.hdr.dime.dim(5) = volnum.new;

save_nii( subj_nifti, OUTPUT )

exit