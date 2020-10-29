
function first_level_analysis(what, varargin)
% case 'DIR:create'
% case 'MULTICONDITION:create'
% case 'MODEL:specify'
% case 'MODEL:estimate'
% case 'CONTRAST:manager'
% case 'ISOLATE:suit'
% case 'NORMALISATION:suit'
% case 'RESLICE:suit'
% case 'FLATMAP:save'
% case 'FLATMAP:display'

subjects = varargin{1};
for subjectt = subjects

    subject = char(subjectt);
    for sessionn = {'a1'}
        session = char(sessionn);
           
        task_idx = num2cell(session);
        task = task_idx{1};
        
        %number of run per subject
        nb_run = 8;
        %list of the tasks
        tasks_A = {'MDTB09_Digit_Judgment', 'MDTB16_Finger_Sequence', 'MDTB15_Finger_Simple', 'MDTB02_Go', 'MDTB12_Happy_Faces', ...
            'MDTB13_Interval_Timing', 'MDTB08_Math', 'MDTB14_Motor_Imagery', 'MDTB01_No-Go', 'MDTB20_Object_2Back', 'MDTB10_Object_Viewing',...
            'MDTB07_Pleasant_Scenes', 'MDTB29_Rest', 'MDTB11_Sad_Faces', 'MDTB21_Spatial_Imagery', 'MDTB23_Stroop_Congruent', 'MDTB22_Stroop_Incongruent',...
            'MDTB03_Theory_Of_Mind', 'MDTB06_Unpleasant_Scenes', 'MDTB24_Verb_Generation', 'MDTB18_Verbal_2Back', 'MDTB04_Action_Observation',...
            'MDTB05_Video_Knots', 'MDTB26_Visual_Search_Small', 'MDTB28_Visual_Search_Large', 'MDTB27_Visual_Search_Medium', 'MDTB25_Word_Reading'};
        tasks_B = {'MDTB38_Animated_Movie', ...
            'MDTB43_Biological_Motion',...
            'MDTB16_Finger_Sequence',...
            'MDTB15_Finger_Simple',...
            'MDTB39_Landscape_Movie',...
            'MDTB40_Mental_Rotation_Easy',...
            'MDTB42_Mental_Rotation_Hard',...
            'MDTB41_Mental_Rotation_Medium',...
            'MDTB37_Nature_Movie',...
            'MDTB20_Object_2Back',...
            'MDTB30_CPRO',...
            'MDTB31_Prediction',...
            'MDTB33_Prediction_Scrambled',...
            'MDTB32_Prediction_Violated',...
            'MDTB45_Response_Alternatives_Easy',...
            'MDTB47_Response_Alternatives_Hard',...
            'MDTB46_Response_Alternatives_Medium',...
            'MDTB29_Rest',...
            'MDTB44_Scrambled_Motion',...
            'MDTB21_Spatial_Imagery',...
            'MDTB34_Spatial_Map_Easy',...
            'MDTB36_Spatial_Map_Hard',...
            'MDTB35_Spatial_Map_Medium',...
            'MDTB03_Theory_Of_Mind',...
            'MDTB24_Verb_Generation',...
            'MDTB04_Action_Observation',...
            'MDTB05_Video_Knots',...
            'MDTB26_Visual_Search_Small',...
            'MDTB28_Visual_Search_Large',...
            'MDTB27_Visual_Search_Medium',...
            'MDTB25_Word_Reading'
            };
        tasks_C = {'MDTB16_Finger_Sequence',...
            'MDTB15_Finger_Simple',...
            'MDTB20_Object_2Back',...
            'MDTB29_Rest',...
            'MDTB21_Spatial_Imagery',...
            'MDTB03_Theory_Of_Mind',...
            'MDTB24_Verb_Generation',...
            'MDTB04_Action_Observation',...
            'MDTB05_Video_Knots',...
            'MDTB26_Visual_Search_Small',...
            'MDTB28_Visual_Search_Large',...
            'MDTB27_Visual_Search_Medium',...
            'MDTB25_Word_Reading'
            };
        
         
        
        if task=='a'
            tasks = tasks_A;
            rest_idx = 13;
            idx_comTask = [2, 3, 10, 13, 15, 18, 20, 22, 23, 24, 25, 26, 27];
            
        elseif task=='b'
            tasks = tasks_B;
            rest_idx = 18;
            idx_comTask = [3, 4, 10, 18, 20, 24, 25, 26, 27, 28, 29, 30, 31];
            
        end
        
        path_workdir = '/home/dieudonnem/hpc/design_glm/glm_MDTB/vsRest/';
        path_dataset = '/home/dieudonnem/hpc/King2019/MDTBdata_download/MDTBdata-download/';
        path_subject = ['sub-' subject];
        path_session = session;
        path_events = '/events_task-vs-rest';
        path_result = '/result_task-vs-rest';
        path_report = '/report_task-vs-rest';
        SPM_path = fullfile(path_workdir, path_subject, path_session, path_result, 'SPM.mat');
        path_T1w = ['sub-', subject,'_ses-', session, '_T1w.nii.gz'];
        
        specify_model_dir = fullfile(path_workdir, path_subject, path_session, path_result);
        
        
        switch what
            % 00  creation dossier sujet
            case 'DIR:create'
                if isfile(fullfile(path_workdir, path_subject, path_session, path_events))
                    disp('folder event create') 
                else
                    mkdir(fullfile(path_workdir, path_subject, path_session, path_events))
                end
                if isfile(fullfile(path_workdir, path_subject, path_session, path_result))
                    disp('folder result create') 
                else
                mkdir(fullfile(path_workdir, path_subject, path_session, path_result))
                end
                if isfile(fullfile(path_workdir, path_subject, path_session, path_report))
                    disp('folder report create') 
                else
                    mkdir(fullfile(path_workdir, path_subject, path_session, path_report))
                end
                
                
            case 'MULTICONDITION:create'
                % 01 Create multi-condition files
                if isfile(fullfile(path_workdir, path_subject, path_session, path_events, 'multiConditions_run-',int2str(nb_run),'.mat'))
                    disp(disp("multi condition files ok -------------------"))
                else
                    disp("Generation of multi condition files -------------------")
                    for run = 1: nb_run
                        path_bold = ['sub-',subject, '_ses-', session, '_task-', task, '_run-', num2str(run), '_bold.nii.gz'];
                        file = fullfile(path_dataset, path_subject, path_session, path_bold, 'events.tsv');
                        [names, onsets, durations] = multiConditions(file, 'tsv');
                        name_matfile = ['multiConditions_','run-',int2str(run),'.mat'];
                        save(fullfile(path_workdir, path_subject, path_session, path_events, name_matfile), 'names', 'onsets', 'durations');
                    end
                    disp("multi condition files ok -------------------")
                end
              
            case 'MODEL:specify'
                
                runs = varargin{2};

                matlabbatch{1}.spm.stats.fmri_spec.dir = {specify_model_dir};
                matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
                matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
                matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
                
                for idx_run = runs
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).scans = {};
                    path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-', task, '_run-', num2str(idx_run), '_bold.nii.gz'];
                    size_nii = length(dir(fullfile(path_dataset,path_subject, path_session, path_bold, 'bold_*')));
                    for idx_img = 1:size_nii
                        path_bold = ['sub-', subject, '_ses-', session, '_task-', task, '_run-', num2str(idx_run), '_bold.nii.gz'];
                        matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).scans {end + 1,1} = fullfile(path_dataset, path_subject, path_session, path_bold, ['wdbold_', sprintf('%05d', idx_img), '.nii']);
                    end
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi = {fullfile(path_workdir, path_subject, path_session, path_events, ['multiConditions_run-', num2str(idx_run), '.mat'])};
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).regress = struct('name', {}, 'val', {});
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi_reg = {''};
                    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).hpf = 128;
                    
                end
                
                matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
                matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
                matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
                matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
                matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
                matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
                
                %job run
                spm_jobman('initcfg');
                spm('defaults','FMRI');
                spm_jobman('run', matlabbatch);
                
                %03 estimate
                
            case 'MODEL:estimate'
                matlabbatch_est{1}.spm.stats.fmri_est.spmmat = {SPM_path};
                matlabbatch_est{1}.spm.stats.fmri_est.write_residuals = 0;
                matlabbatch_est{1}.spm.stats.fmri_est.method.Classical = 1;
                
                spm_jobman('initcfg');
                spm('defaults','FMRI');
                spm_jobman('run', matlabbatch_est);
               
                
            case 'Normalisation:getMeanCommonTask'
                %initialisation beta mean
                beta_init = fullfile(path_workdir, path_subject, path_session, path_result, ['beta_', sprintf('%04d', 1), '.nii']);
                mean_comTask = spm_vol(beta_init);
                mean_comTask = spm_read_vols(mean_comTask);
                mean_comTask(isnan(mean_comTask))=0;
                mean_comTask = 0*mean_comTask;
                for i = idx_comTask
                    beta = fullfile(path_workdir, path_subject, path_session, path_result, ['beta_', sprintf('%04d', i), '.nii']);
                    beta_spm = spm_vol(beta);
                    beta_3Dimg = spm_read_vols(beta_spm);
                    beta_3Dimg(isnan(beta_3Dimg))=0;
                    mean_comTask = mean_comTask + beta_3Dimg;
                    
                end
                mean_comTask = mean_comTask / length(idx_comTask);
                struct_init = spm_vol(beta_init);
                new_nii = spm_create_vol(struct_init);
                movefile(fullfile(path_workdir, path_subject, path_session, path_result, ['beta_', sprintf('%04d', i), '.nii']),...
                    fullfile(path_workdir, path_subject, path_session, path_result, 'original'))
                new_nii.fname = fullfile(path_workdir, path_subject, path_session, path_result, ['beta_', sprintf('%04d', i), '.nii']);
                new_img = spm_write_vol(new_nii, mean_comTask);
                
            case 'Normalisation:substractMeanCommonTask'
                mean_comTask = fullfile(path_workdir, path_subject, path_session, path_result, 'mean_comTask.nii');
                mean_comTask = spm_vol(mean_comTask);
                mean_comTask = spm_read_vols(mean_comTask);
                mean_comTask(isnan(mean_comTask))=0;
                for i = 1:length(tasks)
                    beta = fullfile(path_workdir, path_subject, path_session, path_result, ['beta_', sprintf('%04d', i), '.nii']);
                    beta_spm = spm_vol(beta);
                    beta_3Dimg = spm_read_vols(beta_spm);
                    beta_3Dimg(isnan(beta_3Dimg))=0;
                    beta_comTask_center = beta_3Dimg - mean_comTask;
                    % saving nifti 
                    struct_init = spm_vol(beta_spm);
                    new_nii = spm_create_vol(struct_init);
                    new_nii.fname = fullfile(path_workdir, path_subject, path_session,  path_result, ['beta_comTask_center', srpintf('%04d',i), '.nii']);
                    new_img = spm_write_vol(new_nii, beta_comTask_center);
                    
                end

                % contrast manager
            case 'CONTRAST:manager'
                
                contrast = varargin{2};
                
                for i=1:length(contrast)
                    cont = zeros(1, length(tasks)*nb_run);
                    
                    for cond = 1:length(contrast{1,i}{1,3})
                        cont(contrast{1,i}{1,2}(cond):length(tasks):length(tasks)*nb_run ) = contrast{1,i}{1,4}(cond);
                        
                    end
                    matlabbatch_cm{i}.spm.stats.con.spmmat = {SPM_path};
                    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.name = [contrast{1,i}{1,1}, '_vs_Rest'];
                    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.weights = cont;
                    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
                    matlabbatch_cm{i}.spm.stats.con.delete = 0;
                    
                end
                
                spm_jobman('initcfg');
                spm('defaults','FMRI');
                spm_jobman('run', matlabbatch_cm);
                
                %reslice contrast in suit space
            case 'ISOLATE:suit'
                % check
                if isfile(fullfile(path_dataset, path_subject, path_session, path_T1w, 't1_seg1.nii'))
                       disp('suit_isolate_seg already done for this subject')
                else
                    suit_isolate_seg({fullfile(path_dataset, path_subject, path_session, path_T1w, 't1.nii')})
                end
                
                %Normalisation
            case 'NORMALISATION:suit'
                if isfile(fullfile(path_dataset, path_subject, path_session, path_T1w, 'Affine_t1_seg1.mat'))
                    disp('Normalisation already done for this subject')
                else
                    GM = 't1_seg1.nii';
                    WM = 't1_seg2.nii';
                    isolation_mask = 'c_t1_pcereb.nii';
                    job.subjND.gray={fullfile(path_dataset, path_subject, path_session,path_T1w, GM)};
                    job.subjND.white={fullfile(path_dataset, path_subject, path_session,path_T1w, WM)};
                    job.subjND.isolation={fullfile(path_dataset, path_subject, path_session,path_T1w, isolation_mask)};
                    suit_normalize_dartel(job)
                end
                
                %Reslice
                
                
            case 'SPM:split'
                runs = varargin{2};
                for run = runs
                    path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-', task, '_run-', num2str(run), '_bold.nii.gz'];
                    if isfile(fullfile(path_dataset, path_subject, path_session, path_bold, 'bold_00001.nii'))
                        fprintf('subject %s, session %s, run %d ... split already done \n', subject, session, run)
                    else
                        spm_file_split(fullfile(path_dataset, path_subject, path_session, path_bold, 'bold.nii'))
                        fprintf('subject %s, session %s, run %d ... split done \n', subject, session, run)
                    end
                end
                
            case 'RESLICE:suit'
                
                
                runs = varargin{2};
                
                isolation_mask = 'c_t1_pcereb.nii';
                affine = 'Affine_t1_seg1.mat';
                flowfield = 'u_a_t1_seg1.nii';
                job.subj.affineTr = {fullfile(path_dataset, path_subject, path_session,path_T1w, affine)};
                job.subj.flowfield = {fullfile(path_dataset, path_subject, path_session,path_T1w,flowfield)};
                job.subj.mask={fullfile(path_dataset, path_subject, path_session, path_T1w, isolation_mask)};
                
                for run = runs
                    list_3d = {};
                    path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-', task, '_run-', num2str(run), '_bold.nii.gz'];
                    size_nii = length(dir(fullfile(path_dataset,path_subject, path_session, path_bold, 'bold_*')));
                    for i=1:size_nii
                        
                        
                        list_3d{1,end+1} = fullfile(path_dataset,path_subject, path_session, path_bold, ['bold_', sprintf('%05d', i), '.nii,1']);
                        %list_3d{1,end+1} = fullfile(path_dataset,path_subject, path_session, path_bold, ['bold.nii,', num2str(i)]);
       
                        
                    end
                    job.subj.resample = list_3d;
                    
                    %if isfile(fullfile(path_dataset,path_subject, path_session, path_bold, ['bold_', sprintf('%05d', 4), '.nii']))
                        suit_reslice_dartel(job);
                    %else
                     %   disp('file doesnt exist')
                    %end
                end

%                 runs = varargin{2};
%                 
%                 isolation_mask = 'c_t1_pcereb.nii';
%                 affine = 'Affine_t1_seg1.mat';
%                 flowfield = 'u_a_t1_seg1.nii';
%                 job.subj.affineTr = {fullfile(path_dataset, path_subject, path_session,path_T1w, affine)};
%                 job.subj.flowfield = {fullfile(path_dataset, path_subject, path_session,path_T1w,flowfield)};
%                 job.subj.mask={fullfile(path_dataset, path_subject, path_session, path_T1w, isolation_mask)};
%   
%                 path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-', task, '_run-', num2str(1), '_bold.nii.gz'];
%                 job.subj.resample = {fullfile(path_dataset,path_subject, path_session, path_bold, 'bold.nii,1')}
%                 
%                 
%                 suit_reslice_dartel(job);
                    
        

                

            case 'FLATMAP:save'
                % DESCRIPTION : 
                % Create flatmap and save flatmap in .mat
                % USE : 
                % >> first_level_analysis('FLATMAP:save', subjects, contrast, display)
                % INPUTS :
                %   subject     : {'02','03'}
                %   contrast    : { {'name_contrast', [index_in_list_of_condition], {name_conditions}, [weight]} }
                %   display     : boolean
                
                idx_contrast = varargin{2};
                contrast = varargin{3};
                display = varargin{4};
                ii=1;
                for i = idx_contrast
                    %task = cell2mat(tasks(i));
                    task = contrast{1,ii}{1,1};
                    spmT_idx = sprintf('%04d',i);
                    spmT = fullfile(path_workdir, path_subject, path_session, path_result, ['spmT_', spmT_idx,'.nii']);
                    Data=suit_map2surf(spmT);
                    name = fullfile(path_workdir, path_subject, path_session, path_report,[task '-vs-Rest.mat']);
                    save(name,'Data')
                    if display
                        fig = spm_figure('GetWin','Graphics');
                        suit_plotflatmap(Data,'cmap', hot);
                    end
                    ii= ii+1;
                end
                
                % display flatmap
                
            case 'FLATMAP:display'
                % DESCRIPTION : 
                % Diplay flatmap saved in .mat
                % USE : 
                % >> first_level_analysis('FLATMAP:dipay', subjects, contrast, lut)
                % INPUTS :
                %   subject     : {'02','03'}
                %   contrast    : { {'name_contrast', [index_in_list_of_condition], {name_conditions}, [weight]} }
                %   lut     :  standart format compatible with plot matlab
                
                idx_contrast = varargin{2};
                contrast = varargin{3};
                myLut = varargin{4};
                ii=1;
                for i = idx_contrast
                    clc;
                    %task = cell2mat(tasks(i));
                    task = contrast{1,ii}{1,1};
                    fdata = load(fullfile(path_workdir, path_subject, path_session, path_report,[task '-vs-Rest.mat']));
                    fdata = fdata.Data;
                  
                    %figure
                  
                    fig = spm_figure('GetWin','Graphics');
              
%                     subplot(1,2,1)
                    suit_plotflatmap(fdata,'cmap', myLut);
                    title([path_subject, '_', path_session,'_', task '.mat'])
%                     
%                     subplot(1,2,2)
%                     Data_official = suit_map2surf(fullfile('/home/dieudonnem/hpc/soft/spm12/toolbox/suit/functionalMapsSUIT/',[task, '.nii']));
%                     suit_plotflatmap(Data_official,'cmap', myLut);
%                     title('official results')

                    % save
                    name = fullfile(path_workdir, path_subject, path_session, path_report,[task '.jpg']);
                    saveas(fig,name);
                    ii=ii+1;
                end
                clc; clear;
        end
    end
end
end
