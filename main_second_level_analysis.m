% Second level analysis

path_workdir = '/home/dieudonnem/hpc/design_glm/glm_MDTB/vsRest';
path_second_level = '/second_level_analysis';
path_subject = 'sub-3-4-8-18-19-20-21';
path_result = 'result_task-vs-rest';
path_report = '/report';

tasks = {'MDTB09_Digit_Judgment', 'MDTB16_Finger_Sequence', 'MDTB15_Finger_Simple', 'MDTB02_Go', 'MDTB12_Happy_Faces', ...
        'MDTB13_Interval_Timing', 'MDTB08_Math', 'MDTB14_Motor_Imagery', 'MDTB01_No-Go', 'MDTB20_Object_2Back', 'MDTB10_Object_Viewing',...
        'MDTB07_Pleasant_Scenes', 'MDTB29_Rest', 'MDTB11_Sad_Faces', 'MDTB21_Spatial_Imagery', 'MDTB23_Stroop_Congruent', 'MDTB22_Stroop_Incongruent',...
        'MDTB03_Theory_Of_Mind', 'MDTB06_Unpleasant_Scenes', 'MDTB24_Verb_Generation', 'MDTB18_Verbal_2Back', 'MDTB04_Action_Observation',...
        'MDTB05_Video_Knots', 'MDTB26_Visual_Search_Small', 'MDTB28_Visual_Search_Large', 'MDTB27_Visual_Search_Medium', 'MDTB25_Word_Reading'};


% load spm.mat to get the name of the contrasts


subjects = {'03','04','08','18','19','20','21'};

sessions = {'a1'};
SPM = load(fullfile(path_workdir, ['sub-', '18'], 'a1', path_result, 'SPM.mat'));
SPM = SPM.SPM;
contrast_name = {SPM.xCon.name};

% specify model

i=1;
for cn = contrast_name
    mkdir(fullfile(path_workdir, path_second_level, path_subject, cell2mat(cn), path_result));
    specify_result_dir = fullfile(path_workdir, path_second_level, path_subject, cell2mat(cn) ,path_result);
    matlabbatch_spec{i}.spm.stats.factorial_design.dir = {specify_result_dir};
    matlabbatch_spec{i}.spm.stats.factorial_design.des.t1.scans = {};
    for sub = subjects
        sub = char(sub);
        for se = sessions
            path_con = fullfile(path_workdir, ['sub-', sprintf('%02s',sub)], char(se),path_result,['con_',sprintf('%04d',i),'.nii,1']);
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
    i=i+1;
end

spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch_spec);


% config model

i=1;
for cn = contrast_name
    SPM_path = fullfile(path_workdir, path_second_level,path_subject, cell2mat(cn) ,path_result, 'SPM.mat');
    matlabbatch_est{i}.spm.stats.fmri_est.spmmat = {SPM_path};
    matlabbatch_est{i}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch_est{i}.spm.stats.fmri_est.method.Classical = 1;
    i=i+1;
end
spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch_est);


% Result

i=1;
for cn = contrast_name
    SPM_path = fullfile(path_workdir, path_second_level, path_subject,cell2mat(cn) ,path_result, 'SPM.mat');
    cont = 1;
    matlabbatch_cm{1}.spm.stats.con.spmmat = {SPM_path};
    matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.name = cell2mat(tasks(i));
    matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.weights = cont;
    matlabbatch_cm{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch_cm{1}.spm.stats.con.delete = 0;
    
    spm_jobman('initcfg');
    spm('defaults','FMRI');
    spm_jobman('run', matlabbatch_cm);
    i=i+1;
end



%% flatmap
for cn = contrast_name
    task = cell2mat(cn);
    mkdir(fullfile(path_workdir, path_second_level, path_subject, task, path_report));
    spmT = fullfile(path_workdir, path_second_level, path_subject, task, path_result, 'spmT_0001.nii');
    flatmap=suit_map2surf(spmT);
    save(fullfile(path_workdir, path_second_level, path_subject, task, path_report,'flatmap.mat'), 'flatmap')
end
        

%% plot flatmap

for cn = contrast_name
    task = cell2mat(cn);
    Data = load(fullfile(path_workdir, path_second_level, path_subject, task, path_report, 'flatmap.mat'));
    Data = Data.flatmap;
    fig = spm_figure('GetWin','Graphics');
    
    MyMap = brewermap(126, 'RdBu');
    myMap = flipud(MyMap);
  
    suit_plotflatmap(Data,'cmap', myMap);
    title(task)
   
    
    name = fullfile(path_workdir, path_second_level, path_subject, task, path_report,[task '.jpg']);
    suptitle(task)
    saveas(fig,name);
    clc;
end