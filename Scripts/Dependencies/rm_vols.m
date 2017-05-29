


disp(['TOP_DIR = ', TOP_DIR]);
disp(['cond = ', cond]);
disp(['output = ', output]);

addpath( genpath('/home/hpc3586/matlab_plugins') );

confound = fullfile(TOP_DIR, 'mot_analysis', [cond '_CONFOUND.par']);
confound = dlmread(confound);
confound = sum(confound, 2);

confound(confound > 1) = 1; % binarize the vector
confound = find(confound);


fmri = load_nii( fullfile(TOP_DIR, 'task_data', 'preproc', ['scrubbed_motreg_snlmt_' cond '.nii']) );

cfmri = fmri;

cfmri.img(:,:,:,confound) = [];
cfmri.hdr.dime.dim(5)     = size(cfmri.img, 4);

save_nii(cfmri, fullfile(TOP_DIR, 'task_data', 'preproc', ['rm_' cond '.nii']) )