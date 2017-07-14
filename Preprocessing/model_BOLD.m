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

BETAS      = load_nii([ 'nuisance/BETAS_' COND '.nii' ]);
subj_nifti = load_nii([ 'task_data/preproc/snl_norm_mt_' COND '.nii' ]);

estim_tcourse(:,:,:,:) = 0 * subj_nifti.img(:,:,:,:);

for vol = 1:size(subj_nifti.img, 4)

	for beta = 1:size(BETAS.img, 4)
		estim_tcourse(:,:,:,vol) = estim_tcourse(:,:,:, vol) + ( subj_nifti.img(:,:,:, vol) .* BETAS.img(:,:,:, beta) );
	end
	
end

subj_nifti.img = subj_nifti.img - estim_tcourse;

save_nii(subj_nifti, [ 'task_data/preproc/nuis_snl_norm_mt_' COND '.nii' ]);

exit