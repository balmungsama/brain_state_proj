TOP_DIR  = '/media/member/Data1/osu_alltasks/behav';
SUBJ_DIR = '/media/member/Data1/Thalia/brain_variability_osu_data/resting_cp_john';
TR       = 2 ;

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
    tot_TRs  = behav.p.runSecs / TR ;
    disp(['tot TRs = ', num2str(tot_TRs)]);
    conds = behav.rec(:,2);
    start = behav.rec(:,5);
    
    start_in_TR = start / TR ;
%     dur = behav.p.dur ;

    tcourse = [];
    for scan = 1:tot_TRs
        if any(scan==start_in_TR)
            ind = find(scan==start_in_TR) ;
            tmp = behav.rec(ind, 2) ;
            tcourse = [tcourse(:); tmp];
        else 
            tcourse = [tcourse(:); 0];
        end
    end
    
    tcourse( tcourse == 1 ) = -1;
    tcourse( tcourse == 2 ) =  1;
    
    mkdir([SUBJ_DIR, '/', subj '/behav_ons']);
    [status] = system([' touch ', SUBJ_DIR, '/', subj '/behav_ons/', subj, '_' TASK, '.txt']);
    
    
%     save([ SUBJ_DIR, '/', subj, '/behav_ons/', subj, '_', TASK, '.txt' ], 'conds', '-ascii');
    disp([ SUBJ_DIR, '/', subj, 'behav_ons/', subj, '_', TASK, '.txt' ]);
    fid = fopen([ SUBJ_DIR, '/', subj, '/behav_ons/', subj, '_', TASK, '.txt' ], 'r+');
    fprintf(fid, '%i\n', tcourse);
    fclose(fid);true
end

