%% Correlating EMG activities and Gait Cycle
% Second Script
% Segments EMG activieties in every stride
% e.g. Onsets & offsests between HS(1) and HS(2)
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

vis = 0;
tofreqfilt = 1;


for subjectloop = 1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_Gaitdata =  [temp_dir_vicon(1).folder,pathCompSep,'GaitSummary'];
    addpath(genpath(DIR_Gaitdata))
    ParticpantName = dir([DIR_Gaitdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    ParticpantName(strncmp({ParticpantName.name}, '.', 1)) = [];
    Gait_data = load([DIR_Gaitdata,pathCompSep,ParticpantName.name]);

    DIR_EMGdata = [temp_dir_vicon(1).folder,pathCompSep, 'EMGfiring'];
    addpath(genpath(DIR_EMGdata))
    trialnames = dir([DIR_EMGdata, pathCompSep, '*.mat']);

    destPath = [temp_dir_vicon(1).folder,pathCompSep, 'EMGanaylsis'];

    if ~exist(destPath, 'dir')
        mkdir(destPath)
    end
    nooffiles = length(trialnames);

    for trial = 1:nooffiles

        %% Data Load of EMG
        filename = trialnames(trial).name(1:end-4);  % remove the file extensions
        data_emg = load(filename);

        Name = filename(1:7);
        Condition = filename(9:end-2);
        Stimulation = filename(end-1:end);

        % Recruitment file does not have gait paremeters hence not needed.
        if  Condition ~= "recru"
            try
                Data_gait = Gait_data.(Name).([(Condition) (Stimulation)]);
                RHS = Data_gait.GaitEvents.HSrightlocs;
                RTO = Data_gait.GaitEvents.TOrightlocs;
                LHS = Data_gait.GaitEvents.HSleftlocs;
                LTO = Data_gait.GaitEvents.TOleftlocs;
            catch
                fprintf("No Gait file at %s\n", filename);
                continue
            end
            %% Non Stimulus
            if Stimulation == "_0"

                ConcData.xstim.(Condition)  = filterEMG(data_emg,100,RHS,LHS,filename, tofreqfilt, vis);
                ConcData.xstim.(Condition)  = emgCatergorise(ConcData.xstim.(Condition),RHS,RTO,LHS,LTO,filename);

                %% Stimulus
            elseif Stimulation == "_1"
                ConcData.stim.(Condition)  = filterEMG(data_emg,100,RHS,LHS,filename, tofreqfilt, vis);
                ConcData.stim.(Condition)  = emgCatergorise(ConcData.stim.(Condition),RHS,RTO,LHS,LTO,filename);

            end
            clearvars -except ConcData trialnames Gait_data Name destPath subjectsNames TestPath1 vis tofreqfilt pathCompSep
        end
    end

    comd = [Name,'.ConcData = ConcData'];
    eval(comd);

    datasave = fullfile(destPath, Name);
    save(datasave,Name,'-v7.3');

end
