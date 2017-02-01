TOP_DIR  = '/media/member/Data1/osu_alltasks/behav';
SUBJ_DIR = '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john';

TASK    = 'GoNogo';
subj_ls = dir(SUBJ_DIR);
subj_ls = {subj_ls(:).name};

for subj_i  = subj_ls
    subj  = subj_i{1};
    disp(subj)
    
    if isempty(strfind(subj, '.')) == false
        continue
    end
    
    behav = load([TOP_DIR, '/', subj, 'ZL_', TASK, '.mat']);
    conds = behav.rec(:,2);
    conds( conds == 1 ) = -1;
    conds( conds == 2 ) =  1;
    
    mkdir([SUBJ_DIR, '/', subj '/behav_ons']);
    [status] = system([' touch ', SUBJ_DIR, '/', subj '/behav_ons/', subj, '_' TASK, '.txt']);
    
    
%     save([ SUBJ_DIR, '/', subj, '/behav_ons/', subj, '_', TASK, '.txt' ], 'conds', '-ascii');
    disp([ SUBJ_DIR, '/', subj, 'behav_ons/', subj, '_', TASK, '.txt' ]);
    fid = fopen([ SUBJ_DIR, '/', subj, '/behav_ons/', subj, '_', TASK, '.txt' ], 'r+');
    fprintf(fid, '%i\n', conds);
    fclose(fid);true
end

