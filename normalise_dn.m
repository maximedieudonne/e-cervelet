path_dataset = '/home/dieudonnem/hpc/King2019/MDTBdata_download/';
workdir = '/home/dieudonnem/hpc/King2019/fmriprep_output';
sub = 03;
session= 'a1';
run = 1;
t1_folder = strcat('sub-',sprintf('%02d',sub),'_ses-',session,'_T1w.nii.gz_dentate');
GM = 't1_seg1.nii,1';
WM = 't1_seg2.nii,1';
isolation = 'c_t1_pcereb.nii,1';

% get the number of volumes in the 4D img
bold4D = fullfile(workdir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'bold.nii' );
nb_vol = size(spm_vol(bold4D),1);

% get the size of one volume
bold1 = spm_vol(fullfile(workdir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'bold.nii,1' ));
size_vol = size(spm_read_vols(bold1));

% initialisation meanBold
meanBoldData = zeros(size_vol);

for vol=1:nb_vol
    nextVol = spm_vol(fullfile(workdir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),strcat('bold.nii,',num2str(vol))));
    nextVolData = spm_read_vols(nextVol);
    meanBoldData = meanBoldData + nextVolData;
end

meanBoldData = meanBoldData/nb_vol;

meanBoldVol = spm_create_vol(bold1);
meanBoldVol.fname = fullfile(workdir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'meanBold.nii');
meanBoldNii = spm_write_vol(meanBoldVol, meanBoldData);


%% normalise


matlabbatch{1}.spm.tools.suit.normalise_dentate.subjND.gray = {fullfile(path_dataset, strcat('sub-',sprintf('%02d',sub)), session, t1_folder, GM)};
matlabbatch{1}.spm.tools.suit.normalise_dentate.subjND.white = {fullfile(path_dataset, strcat('sub-',sprintf('%02d',sub)), session, t1_folder, WM)};
matlabbatch{1}.spm.tools.suit.normalise_dentate.subjND.isolation = {fullfile(path_dataset, strcat('sub-',sprintf('%02d',sub)), session, t1_folder, isolation)};
matlabbatch{1}.spm.tools.suit.normalise_dentate.subjND.dentateROI = {fullfile(workdir, strcat('sub-',sprintf('%02d',sub)), session, strcat('run-',num2str(run)), 'mask_dentate.nii,1')};

spm_jobman('initcfg');
spm('defaults','FMRI');
spm_jobman('run', matlabbatch);

%% comparaison
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

