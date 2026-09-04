%% Organising and Concatenating all EMG activities across all participants
% Third script
% Non-Stimulus
% - Muscle activity through gait
% - Firing Pattern Segment specific
% Stimulus
% - Muscle activity through gait
% - Firing Pattern Segment specific
clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac

    case 0
        %         TestPath1   = '/Volumes/Macintosh HD - Data/HRX/ProcessedData/';
        %         TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/Data/Processed';
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking_2/';
        pathCompSep = '/';

    case 1
        TestPath1    = 'D:\HRX\'; % change to the relevant Windows path.
        pathCompSep  = '\';
end

%% Setting Directory for data
addpath(genpath(TestPath1));
currentfolder = pwd;
addpath(genpath(currentfolder));
foldername = dir(TestPath1);
foldername(strncmp({foldername.name}, '.', 1)) = [];

ProcessedData_idx = find(strcmp({foldername.name},'Processed'));
subjectsNames = dir([foldername(ProcessedData_idx).folder,pathCompSep,foldername(ProcessedData_idx).name]);
subjectsNames(strncmp({subjectsNames.name}, '.', 1)) = [];

CHANNEL_INFO    = ["SOL" "TIA" "GAL" "GAM" "VAM" "VAL" "BIF"];
LEG             = ["RIGHTData" "LEFTData"];

for subjectloop = 1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_EMGdata =  [temp_dir_vicon(1).folder,pathCompSep,'EMGanaylsis'];
    addpath(genpath(DIR_EMGdata))
    trialnames = dir([DIR_EMGdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    trialnames(strncmp({trialnames.name}, '.', 1)) = [];

    %% Data Load of EMG Analysis for all participants
    filename = trialnames(1).name(1:end-4);  % remove the file extensions
    data_1.concatemg = load(filename);

    for leg = 1: length(LEG)

        %% Non_stimulus
        size_of_condition = numel(fieldnames(data_1.concatemg.(filename).ConcData.xstim));
        name_of_condition = fieldnames(data_1.concatemg.(filename).ConcData.xstim);

        for conditionsize = 1:size_of_condition
            emgconcat.xstim.(LEG{leg}).gaitparameters.(name_of_condition{conditionsize,1}).(filename).HS = data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).HS;
            emgconcat.xstim.(LEG{leg}).gaitparameters.(name_of_condition{conditionsize,1}).(filename).TO = data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).TO;

            % Muscle activity through whole gait
            name_of_muscle = fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait);
            size_of_muscle = numel(fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait));
            for musclesize = 1:size_of_muscle
                try
                    emgconcat.xstim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclesize}).(filename)= ...
                        data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait.(name_of_muscle{musclesize});
                catch
                    fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                    fprintf("%s leg of %s_0 does not have %s muslces for MAWG\n", LEG{leg}(1:end-4),fullname,(name_of_muscle{musclesize_gait}));
                    continue
                end
            end
            clearvars size_of_muscle name_of_muscle
            % Firing Pattern Segement Specific
            try
                if ~isempty((data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg))
                    name_of_muscle = fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg);
                    size_of_muscle = numel(fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg));
                    for musclesize = 1:size_of_muscle
                        try
                            emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}).(name_of_muscle{musclesize}).(filename)= ...
                                data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg.(name_of_muscle{musclesize});
                        catch
                            fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                            fprintf("%s leg of %s_0 does not have %s muscles for FPSS\n", LEG{leg}(1:end-4),fullname,(name_of_muscle{musclesize}))
                            continue
                        end
                    end
                end
            catch
                fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                fprintf("%s leg of %s_0 does not have firing pattern \n", LEG{leg}(1:end-4),fullname);
            end
        end

        clearvars size_of_condtion name_of_condition conditionsize musclesize name_of_muscle size_of_muscle


        %% Stimulus
        size_of_condition =  numel(fieldnames(data_1.concatemg.(filename).ConcData.stim));
        name_of_condition = fieldnames(data_1.concatemg.(filename).ConcData.stim);

        for conditionsize = 1:size_of_condition
            emgconcat.stim.(LEG{leg}).gaitparameters.(name_of_condition{conditionsize,1}).(filename).HS = data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).HS;
            emgconcat.stim.(LEG{leg}).gaitparameters.(name_of_condition{conditionsize,1}).(filename).TO = data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).TO;

            % Muscle activity through whole gait
            name_of_muscle = fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait);
            size_of_muscle = numel(fieldnames(data_1.concatemg.(filename).ConcData.xstim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait));
            for musclesize = 1:length(CHANNEL_INFO)
                try
                    emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclesize}).(filename)=  ...
                        data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).gait.(CHANNEL_INFO(1,musclesize));
                catch
                    fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                    fprintf("%s leg of %s_1 does not have %s muslces for MAWG\n", LEG{leg}(1:end-4),fullname,(CHANNEL_INFO(1,musclesize)));
                    continue
                end
            end

            % Firing Pattern Segement Specific
            try
                if ~isempty((data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg))
                    size_of_muscles = numel(fieldnames(data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg));
                    for musclesize = 1:size_of_muscles
                        try
                            emgconcat.stim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}).(name_of_muscle{musclesize}).(filename)= ...
                                data_1.concatemg.(filename).ConcData.stim.(name_of_condition{conditionsize,1}).(LEG{leg}).seg.(CHANNEL_INFO(1,musclesize));
                        catch
                            fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                            fprintf("%s leg of %s_1 does not have %s muscles for FPSS\n", LEG{leg}(1:end-4),fullname,(CHANNEL_INFO(1,musclesize)));
                            continue
                        end
                    end
                end
            catch
                fullname = append(filename,'_',(name_of_condition{conditionsize,1}));
                fprintf("%s leg of %s_1 does not have firing pattern \n", LEG{leg}(1:end-4),fullname);
            end
        end
    end
    clearvars size_of_condtion name_of_condition conditionsize musclesize
end

%% Save as .mat file

destPath = [TestPath1,'Results',pathCompSep,'EMG'];
if ~exist(destPath,'dir')
    mkdir(destPath)
end

datasave = fullfile(destPath,'EMGConcat');
save(datasave,'emgconcat','-v7.3');
