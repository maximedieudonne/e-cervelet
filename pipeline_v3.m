%
%[31,30,29,28,27,26,25,24,22,21,20,19,17,14,12,10,09,08,06,04,03,02]
%for sub = [28,27,26,25,24,22,20,19,14,10,08,04,03,02]
for sub = [08,04,03,02]
% create dir 

disp('... create dir ...\n')
mkdir( fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'/a1/events'))
mkdir( fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'/a1/mask'))
mkdir( fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'/a1/report'))
mkdir( fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'/a1/result'))

% create multi condition files
disp('... create multi condition files ... \n')
for i = 1:8
    path_bold = char(strcat('sub-',sprintf('%02d', sub),'_ses-a1', '_task-a_run-', num2str(i), '_bold.nii.gz'));
    file = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'/a1', path_bold, 'events.tsv');
    [names, onsets, durations] = multiConditions(file, 'tsv');
    name_matfile = ['multiConditions_','run-',int2str(i),'.mat'];
    save(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'/a1/events', name_matfile), 'names', 'onsets', 'durations');
end

% create mask 
disp('... create explicit mask ...\n')
exp_mask_init = spm_vol(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'/a1/run-1/bold.nii,1'));
exp_mask_data = spm_read_vols(exp_mask_init);
exp_mask_newdata = ones(size(exp_mask_data));
exp_mask = spm_create_vol(exp_mask_init);
exp_mask.fname = fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'/a1/mask/explicit_mask.nii');
explicit_mask= spm_write_vol(exp_mask, exp_mask_newdata);

% % smooth 
% 
% i = 1;
% for i = 1:8
%     
%     nb_vol = size(spm_vol(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/sub-15/a1', strcat('run-', num2str(i)), 'bold.nii')),1);
%     matlabbatch_smooth{i}.spm.spatial.smooth.data = {};
%     for i=1:nb_vol
%         matlabbatch_smooth{i}.spm.spatial.smooth.data{end+1,1} = fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/sub-15/a1', strcat('run-', num2str(i)), strcat('bold.nii,',num2str(i)));
%     end
%     matlabbatch_smooth{i}.spm.spatial.smooth.fwhm = [8 8 8];
%     matlabbatch_smooth{i}.spm.spatial.smooth.dtype = 0;
%     matlabbatch_smooth{i}.spm.spatial.smooth.im = 0;
%     matlabbatch_smooth{i}.spm.spatial.smooth.prefix = 's';
%     i = i+1;
% end
% 
% spm_jobman('initcfg');
% spm('defaults','FMRI');
% spm_jobman('run', matlabbatch_smooth);


% specify
disp('... specify ...\n')
matlabbatch{1}.spm.stats.fmri_spec.dir = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'/a1/result')};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for idx_run = 1:8
    list_img = {};
    nb_scan = size(spm_vol(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('run-', num2str(idx_run)),'/bold.nii')),1);
    for i = 1:nb_scan
        list_img{i,1} = fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)), 'a1',strcat('run-', num2str(idx_run)),strcat('/bold.nii,',num2str(i)));
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).scans = list_img;
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'/a1/events',strcat('multiConditions_run-',num2str(idx_run),'.mat'))};
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).multi_reg = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(idx_run).hpf = 128;
end

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
matlabbatch{1}.spm.stats.fmri_spec.mask = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'/a1/mask/explicit_mask.nii')};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch);


load(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'a1/result/SPM.mat'));
SPM.xM.TH = -Inf(size(SPM.xM.TH));
SPM.xM.xs = 'explicit mask';
save SPM.mat SPM -v6
movefile('SPM.mat', fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'a1/result/SPM.mat'))


% estimate
disp('... estimate ...\n')
matlabbatch_es{1}.spm.stats.fmri_est.spmmat = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'a1/result/SPM.mat')};
matlabbatch_es{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch_es{1}.spm.stats.fmri_est.method.Classical = 1;
spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch_es);


% contrast
disp('... contrast ...\n')
contrast = load('/home/dieudonnem/hpc/design_glm/glm_MDTB/src_matlab/list_contrasts.mat');
contrast=contrast.contrast_full;
list_tasks = load('/home/dieudonnem/hpc/design_glm/glm_MDTB/src_matlab/list_tasks.mat');
tasks=list_tasks.tasks_A;
nb_run=8;
for i=1:length(contrast)
    cont = zeros(1, length(tasks)*nb_run);
    
    for cond = 1:length(contrast{1,i}{1,3})
        cont(contrast{1,i}{1,2}(cond):length(tasks):length(tasks)*nb_run ) = contrast{1,i}{1,4}(cond);
    end
    matlabbatch_cm{i}.spm.stats.con.spmmat = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/',strcat('sub-',sprintf('%02d', sub)),'a1/result/SPM.mat')};
    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.name = [contrast{1,i}{1,1}];
    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.weights = cont;
    matlabbatch_cm{i}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch_cm{i}.spm.stats.con.delete = 0;
end

spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch_cm);

% isolate
disp('... isolate ...\n')
suit_isolate_seg({fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz'),'/t1.nii')})


% normalise
disp('... normalize ...\n')
GM = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz/t1_seg1.nii'));
WM = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz/t1_seg2.nii'));
isolation_mask = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz/c_t1_pcereb.nii'));
job.subjND.gray={GM};
job.subjND.white={WM};
job.subjND.isolation={isolation_mask};
suit_normalize_dartel(job)

% %% smooth
% 
% for i = 1:11
%     matlabbatch_smooth{i}.spm.spatial.smooth.data = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output/sub-15/a1/result', strcat('spmT_', sprintf('%04d',i),'.nii'))};
%     
%     matlabbatch_smooth{i}.spm.spatial.smooth.fwhm = [8 8 8];
%     matlabbatch_smooth{i}.spm.spatial.smooth.dtype = 0;
%     matlabbatch_smooth{i}.spm.spatial.smooth.im = 0;
%     matlabbatch_smooth{i}.spm.spatial.smooth.prefix = 's';
% 
% end
% 
% spm_jobman('initcfg');
% spm('defaults','FMRI');
% spm_jobman('run', matlabbatch_smooth);

% reslice
disp('... reslice ...\n')
for i=1:11
    isolation_mask = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz'),'c_t1_pcereb.nii');
    affine = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz'),'Affine_t1_seg1.mat');
    flowfield = fullfile('/home/dieudonnem/hpc/King2019/MDTBdata_download/',strcat('sub-',sprintf('%02d', sub)),'a1',strcat('sub-',sprintf('%02d', sub),'_ses-a1_T1w.nii.gz'),'u_a_t1_seg1.nii');
    job.subj.affineTr = {affine};
    job.subj.flowfield = {flowfield};
    job.subj.mask={isolation_mask};
    job.subj.resample = {fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'a1/result', strcat('spmT_', sprintf('%04d',i),'.nii'))};
    suit_reslice_dartel(job);
end


% flatmap
disp('... flatmap...\n')
for i = 1:11
data = suit_map2surf(fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'a1/result', strcat('wdspmT_', sprintf('%04d',i),'.nii')));
clf
fig = spm_figure('GetWin','Graphics');
suit_plotflatmap(data, 'cmap', hot);
title(strcat('subject-',sprintf('%02d', sub), '_a1_', contrast{1,i}{1,1}))
name = fullfile('/home/dieudonnem/hpc/King2019/fmriprep_output',strcat('sub-',sprintf('%02d', sub)),'a1/report', strcat('wdspmT_', sprintf('%04d',i),'.jpg'));
saveas(fig,name);
end
end
