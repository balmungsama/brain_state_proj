[status, FSLDIR] = system('echo $FSLDIR');

%%%%%%%%%%%%%%%%%%%%%%
%% trouble-shooting %%
%%%%%%%%%%%%%%%%%%%%%%

disp('model_BOLD.m')
disp( ['SUBJ_DIR = ', SUBJ_DIR ] );
disp( ['COND = ', COND ] );


%%%%%%%%%%
%% main %%
%%%%%%%%%%

cd(SUBJ_DIR);

BETAS      = load_nii([ 'nuisance/BETAS_' COND '.nii'                ]);
subj_nifti = load_nii([ 'task_data/preproc/snl_norm_mt_' COND '.nii' ]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% experimental start %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subj_mask     = load_nii([ FSLDIR '/data/standard/MNI152_T1_2mm_brain_mask.nii.gz' ]);
subj_mask.img = double(subj_mask.img) ;

for ii = 1:size(subj_nifti.img,4)
	masked_nifti.img(:,:,:, ii) = subj_nifti.img(:,:,:, ii) .* subj_mask.img ;
end

grand_mean = mean2(masked_nifti.img) ;
grand_sd   =  std2(masked_nifti.img) ;

subj_nifti.img = subj_nifti.img - grand_mean ;
subj_nifti.img = subj_nifti.img / grand_sd   ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% experimental end %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

estim_tcourse(:,:,:,:) = 0 * subj_nifti.img(:,:,:,:);

for vol = 1:size(subj_nifti.img, 4)

	% disp([ 'VOL  ', num2str(vol) ])

	for beta = 1:size(BETAS.img, 4)
		
		estim_tcourse(:,:,:, vol) = estim_tcourse(:,:,:, vol) + ( subj_nifti.img(:,:,:, vol) .* BETAS.img(:,:,:, beta) );
	
	end
	
end

subj_nifti.img = subj_nifti.img - estim_tcourse;

for ii = 1:size(subj_nifti.img,4)
	subj_nifti.img(:,:,:, ii) = subj_nifti.img(:,:,:, ii) .* subj_mask.img ;
end

subj_nifti.img(isnan(subj_nifti.img)) = 0 ;

save_nii(subj_nifti, [ 'task_data/preproc/nuis_snl_norm_mt_' COND '.nii' ]) ;

exit