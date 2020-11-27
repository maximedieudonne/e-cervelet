% save for each 8 run, a multi-condition mat files with 'names',
% 'durations' and 'onsets'.

function [names, onsets, durations] = multiConditions(file, typefile) 
    % open tsv file
    if typefile == 'tsv'
        info = readtable(file, 'FileType', 'text'); 
    elseif typefile == 'txt'
        info = readtable(file); %for 23/09/2020
    end
    info = table2cell(info);
    % names of trial type   
    names = unique(info(:,3));
    names(ismember(names,'Instruct')) = []; %remove the Instruction from trial type list
    names = reshape(names,[1, length(names)]); 
    % load onset info
    onset_data = info(:,1);
    onset_data = cell2mat(onset_data);
    onset_data = reshape(onset_data,[1,length(onset_data)]);
    % load duration info
    duration_data = info(:,2);
    duration_data = cell2mat(duration_data);
    duration_data = reshape(duration_data,[1,length(duration_data)]);
    % re-write onset and duration info for multi condition spm format
    onsets = cell(1,length(names));
    durations = cell(1,length(names));
    for tt = 1 : length(names)
        onsets{tt} = onset_data(strcmp(info(:,3),names(tt)));
        durations{tt} = duration_data(strcmp(info(:,3),names(tt)));
    end
    
    
    
   