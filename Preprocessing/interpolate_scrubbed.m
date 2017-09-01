<<<<<<< HEAD
subj      = load_nii('scrubbed_motreg_snlmt_Resting.nii');
subj_cp   = subj;

CONFOUND  = dlmread('Resting_CONFOUND.par');
=======
%%%%%%%%%%%%%%%%%%%%%%
%% trouble-shooting %%
%%%%%%%%%%%%%%%%%%%%%%

disp('interpolate_scrubbed.m')
disp( ['SUBJ_DIR = ', SUBJ_DIR ] );
disp( ['COND = ', COND ] );

%%%%%%%%%%
%% main %%
%%%%%%%%%%


% disp(['subj: ', SUBJ_DIR]);
% disp(['cond: ', COND    ]);


NIFTI    = fullfile( SUBJ_DIR, 'task_data', 'preproc', ['nuis_snl_norm_mt_' COND '.nii'] );
CONFOUND = fullfile( SUBJ_DIR, 'mot_analysis', [COND '_CONFOUND.par'] );
OUTPUT   = fullfile( SUBJ_DIR, 'task_data', 'preproc', ['interp_nuis_snl_norm_mt_' COND '.nii'] );

subj      = load_untouch_nii(NIFTI);
subj_cp   = subj;

CONFOUND  = dlmread(CONFOUND);
>>>>>>> for_CAC-revamped

index     = sum(CONFOUND,2);
index     = index > 0;

index_int = find(index == 1);
index_kp  = find(index == 0);

length_t  = size(subj.img, 4);

<<<<<<< HEAD
% this is just for a single voxel

voxel_t = subj_cp.img(30,20,52,:); % (x, y, z, t)
voxel_t = reshape(test, [1, length_t]);
voxel_t = double(voxel_t);

val_kp  = subj_cp.img(30,20,52, index_kp);
val_kp  = reshape(val_kp, [1, size(val_kp, 4)]);
val_kp  = double(val_kp);

voxel_int = interp1(index_kp, val_kp, index_int, 'linear');

subj_cp(30,20,52, index_int) = voxel_int; % need to fix this
																					% ERROR: Assignment between unlike types is not allowed.
=======
for xx = 1:size(subj_cp.img, 1)

	for yy = 1:size(subj_cp.img, 2)
	
		for zz = 1:size(subj_cp.img, 3)

			voxel_t = subj_cp.img(xx, yy, zz, :); 
			voxel_t = reshape(voxel_t, [1, length_t]);
			voxel_t = double(voxel_t);

			val_kp  = subj_cp.img(xx, yy, zz, index_kp);
			val_kp  = reshape(val_kp, [1, size(val_kp, 4)]);
			val_kp  = double(val_kp);

			voxel_int = interp1(index_kp, val_kp, index_int, 'nearest', 'extrap');

			subj_cp.img(xx, yy, zz, index_int) = voxel_int; 

		end

	end

end

save_untouch_nii(subj_cp, OUTPUT);

exit
>>>>>>> for_CAC-revamped
