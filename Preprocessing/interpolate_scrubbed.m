subj      = load_nii('scrubbed_motreg_snlmt_Resting.nii');
subj_cp   = subj;

CONFOUND  = dlmread('Resting_CONFOUND.par');

index     = sum(CONFOUND,2);
index     = index > 0;

index_int = find(index == 1);
index_kp  = find(index == 0);

length_t  = size(subj.img, 4);

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

