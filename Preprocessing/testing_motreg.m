TOP_DIR = 'C:\Users\john\Desktop\tmp_preproc';

cd(TOP_DIR);

betas   = load_nii('glm_betas.nii.gz');
image   = load_nii('mt_Resting.nii.gz');
outcome = load_nii('motreg_mt_Resting.nii.gz');

MPE = dlmread('mt_Resting.par');

dims = size(image.img);

voxel.coords = dims / 2;
voxel.coords = voxel.coords(1:3);
voxel.coords = round(voxel.coords, 0);

voxel.orig = image.img(voxel.coords(1), voxel.coords(2), voxel.coords(3), :);
voxel.orig = reshape(voxel.orig, [dims(4), 1]);

voxel.reg = outcome.img(voxel.coords(1), voxel.coords(2), voxel.coords(3), :);
voxel.reg = reshape(voxel.reg, [dims(4), 1]);

[b,bint,r] = regress(voxel.orig, MPE);

voxel.pred = r;

plot(1:dims(4), voxel.orig, ...
     1:dims(4), voxel.reg, ...
     1:dims(4), voxel.pred);
 
 nMPE = zscore(MPE);
 
 plot(1:dims(4), nMPE);