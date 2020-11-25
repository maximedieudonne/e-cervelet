% mean bold response 



work_dir = '/home/dieudonnem/hpc/King2019/fmriprep_output/';
sub = 02;
session = 'a1';
run = 1;

% get the number of volumes in the 4D img
bold4D = fullfile(work_dir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'bold.nii' );
nb_vol = size(spm_vol(bold4D),1);

% get the size of one volume
bold1 = spm_vol(fullfile(work_dir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'bold.nii,1' ));
size_vol = size(spm_read_vols(bold1));

% initialisation meanBold
meanBoldData = zeros(size_vol);

for vol=1:nb_vol
    nextVol = spm_vol(fullfile(work_dir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),strcat('bold.nii,',num2str(vol))));
    nextVolData = spm_read_vols(nextVol);
    meanBoldData = meanBoldData + nextVolData;
end

meanBoldData = meanBoldData/nb_vol;

meanBoldVol = spm_create_vol(bold1);
meanBoldVol.fname = fullfile(work_dir, strcat('sub-', sprintf('%02d',sub)),session, strcat('run-', num2str(run)),'meanBold.nii');
meanBoldNii = spm_write_vol(meanBoldVol, meanBoldData);





