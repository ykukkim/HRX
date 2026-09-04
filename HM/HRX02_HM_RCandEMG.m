%% EMG analysis H and M waves for recruitment curve for stimulus and non stimulus
% Extracts parameters of H, M, Baseline, and stimulus intesnity of each
% particiapnt
% Input: mat struct containing AnalogCh signal e.g. Soleus EMG, Stimulus Output, Stimulus
% Intensity
% Output: mat struct RecruitmentSummary.mat, plot of recruitment curve

clear all; clc; close all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1   = '/Users/YKK/Desktop/YKKDTOP/ETH/Research/HRX/Data/Results/HM/matfiles';
    case 1
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
end

%% Setting Directory for data
addpath(genpath(TestPath1));
currentfolder = pwd;
addpath(genpath(currentfolder));
foldername = dir(TestPath1);
foldername(strncmp({foldername.name}, '.', 1)) = [];

ProcessedData_idx = find(strcmp({foldername.name},'Processed'));
subjectsNames = dir([foldername(ProcessedData_idx).folder,filesep,foldername(ProcessedData_idx).name]);
subjectsNames(strncmp({subjectsNames.name}, '.', 1)) = [];

%% Pre-initialisation
linefit = @Linefit;
linefit_stim = @Linefit_stim;

for subjectloop = 3%1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,filesep,subjectsNames(subjectloop).name,filesep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,filesep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    %% Preallocating Spaces
    part = subjectsNames(subjectloop).name;
    DIR_HRXdata = [temp_dir_vicon(1).folder,filesep,'matfiles'];
    addpath(genpath(DIR_HRXdata));
    trialnames = dir([DIR_HRXdata, filesep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    nooffiles = length(trialnames);

    for trial = 1:nooffiles

        filename = trialnames(trial).name(1:end-4);  % remove the file extensions
        data_1 = load(fullfile(DIR_HRXdata,filename));
        Analog = data_1.AnalogCh;

        Name = filename(1:7);
        Test = filename(9:13);
        No = filename(end);

        if isfield(data_1, 'AnalogCh') && No == "1"

            %             max_V1 = max(Analog.Voltage_1);
            %             max_V5 = max(Analog.Voltage_5);
            %
            %             if max_V5>=max_V1
            %                 dom_leg = 'left';
            %                 sol_EMG = Analog.Voltage_5;
            %             else

            if (subjectloop == 11) || (subjectloop == 8 )
                dom_leg = 'left';
                sol_EMG = Analog.Voltage_5;
            else
                dom_leg = 'right';
                sol_EMG = Analog.Voltage_1;
            end
            disp(dom_leg);
            destPath= [temp_dir_vicon(1).folder,filesep,'RCSummary'];

            if ~exist(destPath, 'dir')
                mkdir(destPath)
            end

            [AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,i,destPath]= ...
                detectHreflex(data_1,sol_EMG,destPath,filename);

            RecruitmentSummary.HReflex = AmplitudeHwave';
            RecruitmentSummary.Mwave = AmplitudeMwave';
            RecruitmentSummary.BEmg = AmplitudeBaseline';
            RecruitmentSummary.Stimulus = x1';
            RawValues.EMG  = Analog.Voltage_1;
            RawValues.Stimulus = Analog.Electric_Current_Stimulus_Intensity;

            %% Eval function need to be sorted.
            comd = [Name,'.',Test, '.RecruitmentSummary = RecruitmentSummary;'];
            eval(comd);

            comd = [Name,'.',Test, '.RawValues = RawValues;'];
            eval(comd);

            comd = [Name '= orderfields(', Name ');'];
            eval(comd);
            close;

        else
            disp(filename);
            disp('Skipping the trial with stimulus');
            continue;
        end
    end

    datasave = fullfile(destPath, Name);
    save(datasave,Name,'-v7.3');
    clearvars -except DIR DIR_dest currentfolder destPath subjectsNames trialnames DIR_HRXdata subjectloop trial part filesep
end
