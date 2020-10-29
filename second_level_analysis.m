% 01/10/2020
% script second level analysis
% sub : 3,4
% sess : a1, a2


function second_level_analysis(what, varargin)

subjects = varargin{1};
sessions = varargin{2};
contrasts = varargin{3};

switch what
    % Suit space normalisation of contrast
    case 'SUIT:reslice'
        
        for subject = 3:4
            for session = {'a1','a2'}
                path_subject = ['sub-' num2str(subject,'%02.f')];
                path_session = char(session);
                path_T1w = ['sub-', sprintf('%02d', subject),'_ses-',path_session, '_T1w.nii.gz'];
                SPM_path = fullfile(path_workdir, path_subject, path_session, path_result, 'SPM.m');
                affine = 'Affine_t1_seg1.mat';
                flowfield = 'u_a_t1_seg1.nii';
                isolation_mask = 'c_t1_pcereb.nii';
                
                % Reslice
                for i = 1:length(tasks)
                    job.subj.affineTr = {fullfile(path_dataset, path_subject, path_session,path_T1w, affine)};
                    job.subj.flowfield = {fullfile(path_dataset, path_subject, path_session,path_T1w,flowfield)};
                    job.subj.resample={fullfile(path_workdir,path_subject, path_session, path_result,['con_', sprintf('%04d', i),'.nii'])};
                    job.subj.mask={fullfile(path_dataset, path_subject, path_session, path_T1w, isolation_mask)};
                    suit_reslice_dartel(job);
                end
            end
        end
        
        
        % specify 2nd level analysis
    case 'MODEL:specify'
        
        
        for i = 1:length(contrasts)
            mkdir(fullfile(path_workdir, path_second_level, path_subject,cell2mat(tasks(i)),path_result));
            specify_result_dir = fullfile(path_workdir, path_second_level,path_subject, cell2mat(tasks(i)) ,path_result);
            matlabbatch_spec{i}.spm.stats.factorial_design.dir = {specify_result_dir};
            matlabbatch_spec{i}.spm.stats.factorial_design.des.t1.scans = {};
            for sub = subjects
                for se = sessions
                    path_con = fullfile(path_workdir, ['sub-', sprintf('%02d',sub)], char(se),path_result,['con_',sprintf('%04d',i),'.nii,1']);
                    matlabbatch_spec{i}.spm.stats.factorial_design.des.t1.scans {end + 1,1} = path_con;
                end
            end
            
            matlabbatch_spec{i}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch_spec{i}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
            matlabbatch_spec{i}.spm.stats.factorial_design.masking.tm.tm_none = 1;
            matlabbatch_spec{i}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch_spec{i}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch_spec{i}.spm.stats.factorial_design.globalc.g_omit = 1;
            matlabbatch_spec{i}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
            matlabbatch_spec{i}.spm.stats.factorial_design.globalm.glonorm = 1;
        end
        
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch_spec);
        
        %% estimate 2nd level analysis
        for i = 1:length(tasks)
            SPM_path = fullfile(path_workdir, path_second_level,path_subject, cell2mat(tasks(i)) ,path_result, 'SPM.mat');
            matlabbatch_est{i}.spm.stats.fmri_est.spmmat = {SPM_path};
            matlabbatch_est{i}.spm.stats.fmri_est.write_residuals = 0;
            matlabbatch_est{i}.spm.stats.fmri_est.method.Classical = 1;
        end
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch_est);
        
        %% result
        for i = 1:length(tasks)
            SPM_path = fullfile(path_workdir, path_second_level, path_subject,cell2mat(tasks(i)) ,path_result, 'SPM.mat');
            cont = 1;
            matlabbatch_cm{1}.spm.stats.con.spmmat = {SPM_path};
            matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.name = cell2mat(tasks(i));
            matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.weights = cont;
            matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch_cm{1}.spm.stats.con.delete = 0;
            
            spm_jobman('initcfg');
            spm('defaults','FMRI');
            spm_jobman('run', matlabbatch_cm);
        end
        %% flatmap
        for i = 1:length(tasks)
            task = cell2mat(tasks(i));
            mkdir(fullfile(path_workdir, path_second_level, path_subject, task, path_report));
            spmT = fullfile(path_workdir, path_second_level, path_subject, task, path_result, 'spmT_0001.nii');
            flatmap=suit_map2surf(spmT);
            save(fullfile(path_workdir, path_second_level, path_subject, task, path_report,'flatmap.mat'), 'flatmap')
        end
        
        %% plot flatmap
        path_workdir = '/home/dieudonnem/hpc/design_glm/glm_MDTB';
        path_dataset = '/home/dieudonnem/hpc/King2019/MDTBdata_download/MDTBdata-download/';
        path_second_level = '/second_level_analysis';
        path_subject = 'sub-3-4_task-a';
        path_result = '/result';
        path_report = '/report';
        tasks = {'MDTB09_Digit_Judgment', 'MDTB16_Finger_Sequence', 'MDTB15_Finger_Simple', 'MDTB02_Go', 'MDTB12_Happy_Faces', ...
            'MDTB13_Interval_Timing', 'MDTB08_Math', 'MDTB14_Motor_Imagery', 'MDTB01_No-Go', 'MDTB20_Object_2Back', 'MDTB10_Object_Viewing',...
            'MDTB07_Pleasant_Scenes', 'MDTB29_Rest', 'MDTB11_Sad_Faces', 'MDTB21_Spatial_Imagery', 'MDTB23_Stroop_Congruent', 'MDTB22_Stroop_Incongruent',...
            'MDTB03_Theory_Of_Mind', 'MDTB06_Unpleasant_Scenes', 'MDTB24_Verb_Generation', 'MDTB18_Verbal_2Back', 'MDTB04_Action_Observation',...
            'MDTB05_Video_Knots', 'MDTB26_Visual_Search_Small', 'MDTB28_Visual_Search_Large', 'MDTB27_Visual_Search_Medium', 'MDTB25_Word_Reading'};
        for i = 1:length(tasks)
            task = cell2mat(tasks(i));
            Data = load(fullfile(path_workdir, path_second_level, path_subject, cell2mat(tasks(i)), path_report, 'flatmap.mat'));
            Data = Data.flatmap;
            fig = spm_figure('GetWin','Graphics');
            
            MyMap = brewermap(126, 'RdBu');
            myMap = flipud(MyMap);
            
            subplot(2,2,1)
            suit_plotflatmap(Data,'cmap', myMap);
            title('personal results')
            
            subplot(2,2,2)
            Data_official = suit_map2surf(fullfile('/home/dieudonnem/hpc/soft/spm12/toolbox/suit/functionalMapsSUIT/',[task, '.nii']));
            suit_plotflatmap(Data_official,'cmap', myMap);
            title('official results')
            
            subplot(2,2,3)
            suit_plotflatmap(Data,'cmap', hot);
            title('personal results')
            
            subplot(2,2,4)
            Data_official = suit_map2surf(fullfile('/home/dieudonnem/hpc/soft/spm12/toolbox/suit/functionalMapsSUIT/',[task, '.nii']));
            suit_plotflatmap(Data_official,'cmap', hot);
            title('official results')
            
            name = fullfile(path_workdir, path_second_level, path_subject, cell2mat(tasks(i)), path_report,[task '.jpg']);
            suptitle(task)
            saveas(fig,name);
            clc;
        end
        
end
end

