%% MAIN

list_tasks = load('list_tasks.mat');
tasks_A=list_tasks.tasks_A;
tasks_B=list_tasks.tasks_B;
tasks_C=list_tasks.tasks_C;

list_contrasts= load('list_contrasts.mat');
contrast_A = list_contrasts.contrast_A;
contrast_B = list_contrasts.contrast_B;
contrast_full = list_contrasts.contrast_full;
contrast_tasks = list_contrasts.contrast_task;

subjects = {'02'};
sessions = {'a1'};
runs = [1,2,3,4,5,6,7,8];
task = 'a';
if task=='a'
    tasks = tasks_A;
    rest_idx = 13;
    idx_comTask = [2, 3, 10, 13, 15, 18, 20, 22, 23, 24, 25, 26, 27];
    elseif task=='b'
    tasks = tasks_B;
    rest_idx = 18;
    idx_comTask = [3, 4, 10, 18, 20, 24, 25, 26, 27, 28, 29, 30, 31];
    
end

paths.path_workdir = '/home/dieudonnem/hpc/design_glm/glm_MDTB/loop5/';
paths.path_dataset = '/home/dieudonnem/hpc/King2019/MDTBdata_download/MDTBdata-download/';
paths.path_events = '/events';
paths.path_result = '/result';
paths.path_report = '/report';

for subjectt = subjects
    subject = char(subjectt);
    str = sprintf('...subject... %s ...',subject);
    disp(str);
    paths.path_subject = ['sub-' subject];
    for session = sessions
        sess = char(session);
        paths.path_session = sess;
        paths.SPM_path = fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_result, 'SPM.mat');
        paths.path_T1w = ['sub-', subject,'_ses-', sess, '_T1w.nii.gz'];
        paths.specify_model_dir = fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_result);
        
        %first_level_analysis('DIR:create', paths, subject, sess)
        %first_level_analysis('MULTICONDITION:create',paths,subject, sess,runs)
        %first_level_analysis('ISOLATE:suit', paths,subject,sess)
        %first_level_analysis('NORMALISATION:suit', paths,subject,sess)
        %first_level_analysis('PREPROCESS:smooth', paths,subject,sess, runs)
        %first_level_analysis('PREPROCESS:split', paths,subject, sess,runs)
%         for run = runs
%             first_level_analysis('PREPROCESS:reslice_suit', paths,subject, sess, run)
%             disp(run)
%         end
        first_level_analysis('MODEL:specify', paths,subject,sess, runs)
        %first_level_analysis('MODEL:estimate', paths,subject, sess)
        %contrasts = contrast_full;
        %first_level_analysis('CONTRAST:manager', paths, subject, contrasts )
        %idx_contrast = [1,2,3,4,5,6,7,8,9,10,11];
        %display_ = false;
        %first_level_analysis('FLATMAP:save', subjects, idx_contrast, contrasts, display_)
        
    end
end


% for subjectt = subjects
%     subject = char(subjectt);
%     for session = sessions
%         sess = char(session);
%         idx_contrast = [1,2,3,4,5,6,7,8,9,10,11];
%         contrasts = contrast_full;
%        
%         
%         % here we define the lut
%         MyMap = brewermap(126, 'RdBu');
%         myLut = flipud(MyMap);
%         
%         first_level_analysis('FLATMAP:display', subjects, idx_contrast, contrasts, myLut)
%         
%     end
% end
