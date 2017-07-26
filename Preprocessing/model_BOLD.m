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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% experimental start %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

grand_mean = mean2(subj_nifti.img) ;
grand_sd   =  std2(subj_nifti.img) ;

tmp_subj_nifti = subj_nifti;

tmp_subj_nifti.img = tmp_subj_nifti.img - grand_mean ;
tmp_subj_nifti.img = tmp_subj_nifti.img / grand_sd   ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% experimental end %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

estim_tcourse(:,:,:,:) = 0 * subj_nifti.img(:,:,:,:);

for vol = 1:size(subj_nifti.img, 4)

	% disp([ 'VOL  ', num2str(vol) ])

	for beta = 1:size(BETAS.img, 4)
		estim_tcourse(:,:,:, vol) = estim_tcourse(:,:,:, vol) + ( tmp_subj_nifti.img(:,:,:, vol) .* BETAS.img(:,:,:, beta) );
		
		% disp( estim_tcourse(30, 60, 40, vol) )
	end
	
end

subj_nifti.img = tmp_subj_nifti.img - estim_tcourse;

save_nii(subj_nifti, [ 'task_data/preproc/nuis_snl_norm_mt_' COND '.nii' ]);

exit