QC_dir   = '/mnt/c/Users/john/OneDrive/2017-2018/brain_state_proj/Preprocessing/QualityControl' ;
template = '$FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz' ;

cd(QC_dir) ;
load('dos160_new.mat') ;

proper_name = false ;

fid = fopen('afni_roi_spheres/roi_labels.txt', 'w') ;

for ROI = 1:size(dos_labels_n, 1);
	
  disp( [ '+++++++ Running ROI ', num2str(ROI) ] )
	
	roi_coords = dos_centers_n(ROI,:) ;
    
	if proper_name == true
	
		roi_label  = dos_labels_n{ROI} ;
			
		%% Assign a hemisphere %%
		
		if roi_coords(1) > 0
			hemi = 'R' ;
		elseif roi_coords(1) < 0
			hemi = 'L' ;
		elseif roi_coords(1) == 0
			hemi = 'M';
		end
		
		roi_coords = num2str(roi_coords)  ;
		
		%% has this roi name been used before? %%
		
		match = strmatch(roi_label, dos_labels_n(1:ROI)) ;
		match = length(match) ;
		match = num2str(match) ;
		
		%% Remove spaces in region names %%
		
		if isempty(findstr(roi_label, ' ')) == 0
			roi_label = strsplit(roi_label);
			roi_label = [ roi_label{:} ]   ;
		end
		
		%% changing the roi label %%
		
		roi_label = [hemi, '_', roi_label, '_', match] ;
		disp(roi_label)
		
	elseif proper_name == false
		
		roi_coords = num2str(roi_coords) ;
		roi_label  = num2str(ROI)        ;
	
	end
    
    %% Running AFNI commands %%
    
    [status] = system( [ 'echo ' roi_coords ' > tmp_coords.txt' ], '-echo' ) ;
    roi_cmd  = ['3dUndump -prefix afni_roi_spheres/', roi_label, ' -master ', template, ' -srad 5 -xyz tmp_coords.txt'] ;
    
    [status] = system( roi_cmd, '-echo' ) ;
    [status] = system( [ '3dAFNItoNIFTI -prefix afni_roi_spheres/', roi_label, ' afni_roi_spheres/', roi_label, '+tlrc.*' ], '-echo' ) ;
    [status] = system( ['rm afni_roi_spheres/', roi_label, '+tlrc.*'], '-echo' ) ;
	
	fprintf(fid, [dos_labels_n{ROI}, '\n'] ) ;
    
end

fclose(fid) ;