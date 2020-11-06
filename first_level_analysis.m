
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

paths = varargin{1};
subject = varargin{2};
session = varargin{3};

switch what
    case 'DIR:create'
        if isfile(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_events))
            disp('folder event create')
        else
            mkdir(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_events))
        end
        if isfile(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_result))
            disp('folder result create')
        else
            mkdir(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_result))
        end
        if isfile(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_report))
            disp('folder report create')
        else
            mkdir(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_report))
        end
        
        
    case 'MULTICONDITION:create'
        runs = varargin{4};
        for run = runs
            path_bold = char(strcat('sub-',subject, '_ses-', session, '_task-a_run-', num2str(run), '_bold.nii.gz'));
            file = fullfile(paths.path_dataset, paths.path_subject, paths.path_session, path_bold, 'events.tsv');
            [names, onsets, durations] = multiConditions(file, 'tsv');
            name_matfile = ['multiConditions_','run-',int2str(run),'.mat'];
            save(fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_events, name_matfile), 'names', 'onsets', 'durations');
            str = sprintf('subject %s .... session %s .... run %s .... multi condition files ok',subject,session,num2str(run));
            disp(str);
        end
        
        
    case 'PREPROCESS:smooth'
        runs = varargin{4};
        for run = runs
            path_bold = char(strcat('sub-',subject, '_ses-', session, '_task-a_run-', num2str(run), '_bold.nii.gz'));
            nb_vol = size(spm_vol(fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, 'bold.nii')),1);
            matlabbatch_smooth{run}.spm.spatial.smooth.data = {};
            for i=1:nb_vol
                matlabbatch_smooth{run}.spm.spatial.smooth.data{end+1,1} = fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, strcat('bold.nii,',num2str(i)));
            end
            save('a','matlabbatch_smooth');
            matlabbatch_smooth{run}.spm.spatial.smooth.fwhm = [8 8 8];
            matlabbatch_smooth{run}.spm.spatial.smooth.dtype = 0;
            matlabbatch_smooth{run}.spm.spatial.smooth.im = 0;
            matlabbatch_smooth{run}.spm.spatial.smooth.prefix = 's';
        end
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch_smooth);
        
    case 'PREPROCESS:split'
        runs = varargin{4};
        for run = runs
            path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-a_run-', num2str(run), '_bold.nii.gz'];
            spm_file_split(fullfile(paths.path_dataset, paths.path_subject, paths.path_session, path_bold, 'sbold.nii'))
            fprintf('subject %s, session %s, run %d ... split done \n', subject, session, run)
            
        end
        
    case 'PREPROCESS:reslice_suit'
        run = varargin{4};
        isolation_mask = 'c_t1_pcereb.nii';
        affine = 'Affine_t1_seg1.mat';
        flowfield = 'u_a_t1_seg1.nii';
        job.subj.affineTr = {fullfile(paths.path_dataset, paths.path_subject, paths.path_session,paths.path_T1w, affine)};
        job.subj.flowfield = {fullfile(paths.path_dataset, paths.path_subject, paths.path_session,paths.path_T1w,flowfield)};
        job.subj.mask={fullfile(paths.path_dataset, paths.path_subject, paths.path_session, paths.path_T1w, isolation_mask)};
        list_3d = {};
        path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-a_run-', num2str(run), '_bold.nii.gz'];
        nb_vol = size(spm_vol(fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, 'sbold.nii')),1);
        for i=1:nb_vol
            list_3d{1,end+1} = fullfile(paths.path_dataset,paths.path_subject, paths.path_session, path_bold, ['sbold_', sprintf('%05d', i), '.nii,1']);
            %list_3d{end+1,1} = fullfile(paths.path_dataset,paths.path_subject, paths.path_session, path_bold, strcat('sbold.nii,',num2str(i)));
        end
        job.subj.resample = list_3d;
        suit_reslice_dartel(job);
        save('eee','job')
        
        
    case 'MODEL:specify'
        runs = varargin{4};
        % creation explicit mask
        for idx_run = runs
            path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-a_run-', num2str(idx_run), '_bold.nii.gz'];
            
            img = spm_vol(fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, 'wdsbold_00001.nii'));
            
            fprintf('... run ... %s \n', num2str(idx_run))
            disp(img.dim)
            
            exp_mask_init = spm_vol(fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, 'wdsbold_00001.nii'));
            exp_mask_data = spm_read_vols(exp_mask_init);
            disp(size(exp_mask_data))
            exp_mask_newdata = ones(size(exp_mask_data));
            exp_mask = spm_create_vol(exp_mask_init);
            exp_mask.fname = fullfile(paths.path_dataset, paths.path_subject, paths.path_session, path_bold, 'explicit_mask.nii');
            explicit_mask= spm_write_vol(exp_mask, exp_mask_newdata);
            
        end
        
        runs = varargin{4};
        
        matlabbatch{1}.spm.stats.fmri_spec.dir = {paths.specify_model_dir};
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
        
        for idx_run = runs
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).scans = {};
            path_bold = ['sub-', num2str(subject),'_ses-', session,'_task-a_run-', num2str(idx_run), '_bold.nii.gz'];
            nb_vol = size(spm_vol(fullfile(paths.path_dataset, paths.path_subject,paths.path_session, path_bold, 'sbold.nii')),1);
            for idx_img = 1:nb_vol
                path_bold = ['sub-', subject, '_ses-', session, '_task-a_run-', num2str(idx_run), '_bold.nii.gz'];
                matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).scans {end + 1,1} = fullfile(paths.path_dataset, paths.path_subject, paths.path_session, path_bold, ['wdsbold_', sprintf('%05d', idx_img), '.nii']);
            end
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi = {fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_events, ['multiConditions_run-', num2str(idx_run), '.mat'])};
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).regress = struct('name', {}, 'val', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi_reg = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).hpf = 128;
            
        end

        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
        matlabbatch{1}.spm.stats.fmri_spec.mask = {fullfile(paths.path_dataset, paths.path_subject, paths.path_session, paths.path_session, path_bold, 'explicit_mask.nii')};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch);
        

    case 'MODEL:estimate'
        matlabbatch_est{1}.spm.stats.fmri_est.spmmat = {paths.SPM_path};
        matlabbatch_est{1}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch_est{1}.spm.stats.fmri_est.method.Classical = 1;
        
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch_est);
        

    case 'CONTRAST:manager'
        tasks = varargin{4};
        contrast = varargin{5};
        nb_run=8;
        for i=1:length(contrast)
            cont = zeros(1, length(tasks)*nb_run);
            
            for cond = 1:length(contrast{1,i}{1,3})
                cont(contrast{1,i}{1,2}(cond):length(tasks):length(tasks)*nb_run ) = contrast{1,i}{1,4}(cond);
            end
            matlabbatch_cm{i}.spm.stats.con.spmmat = {paths.SPM_path};
            matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.name = [contrast{1,i}{1,1}];
            matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.weights = cont;
            matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
            matlabbatch_cm{i}.spm.stats.con.delete = 0;
        end
        
        spm_jobman('initcfg');
        spm('defaults','FMRI');
        spm_jobman('run', matlabbatch_cm);
        

    case 'ISOLATE:suit'
        if isfile(fullfile(path_dataset, path_subject, path_session, path_T1w, 't1_seg1.nii'))
            disp('suit_isolate_seg already done for this subject')
        else
            suit_isolate_seg({fullfile(path_dataset, path_subject, path_session, path_T1w, 't1.nii')})
        end
        
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

    case 'FLATMAP:save'
        % DESCRIPTION :
        % Create flatmap and save flatmap in .mat
        % USE :
        % >> first_level_analysis('FLATMAP:save', subjects, contrast, display)
        % INPUTS :
        %   subject     : {'02','03'}
        %   contrast    : { {'name_contrast', [index_in_list_of_condition], {name_conditions}, [weight]} }
        %   display     : boolean
        
        idx_contrast = varargin{3};
        contrast = varargin{4};
        display = varargin{5};
        ii=1;
        for i = idx_contrast
            %task = cell2mat(tasks(i));
            task = contrast{1,ii}{1,1};
            spmT_idx = sprintf('%04d',i);
            spmT = fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_result, ['spmT_', spmT_idx,'.nii']);
            Data=suit_map2surf(spmT);
            name = fullfile(paths.path_workdir, paths.path_subject, paths.path_session, paths.path_report,[task '-vs-Rest.mat']);
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

