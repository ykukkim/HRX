%% Gait Analysis
% Extracts all the relevant spatio-temporal gait parameters
% 1. It fills the gap by interpolating the missing datasets, but this
% process should be performed in VICON, such as gap filling.
% 1. It detects the IC and TO using FVA from O'connor et al 2007
% 2. Spatio-temporal parameters are calculated from these events
%   i Midstance & Midswing
%   ii.Duration
%       i   duration Gait cycle
%       ii  duration Stance Phase
%       iii duration Swing Phase
%       iv  duration of double limb support
%   iii. Stride and Step lengths
%   iv. Stepwidth
%   v. Phase Coordination Index
clear; close; clc;
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');

switch ifMac

    case 0
        %         TestPath1 = '/Users/YKK/Desktop/H_reflexdata';
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/Data';
        pathCompSep = '/';

    case 1
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data';
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


%% Load the Data
for subjectloop = 22%1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_HRXdata = [temp_dir_vicon(1).folder,pathCompSep,'matfiles'];
    addpath(genpath(DIR_HRXdata))
    destPath= [temp_dir_vicon(1).folder,pathCompSep,'GaitSummary'];

    if ~exist(destPath,'dir')
        mkdir(destPath)
    end

    trialnames = dir([DIR_HRXdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    trialnames(strncmp({trialnames.name}, '.', 1)) = [];
    nooffiles = length(trialnames);

    %% Load all files in directory
    for trial = 1:nooffiles
        filename = trialnames(trial).name(1:end-4);
        data_1 = load(filename);
        VD = data_1.VD;
        Name = filename(1:7);
        Test = filename(9:end);
        try
            if Test ~= "recru_1"
                if isfield(data_1, 'VD')
                    [interpolatedVD,ctrialsfewEvents,ctrialsfewEventsnames] = FillGaps(VD, filename, Name);
                    [GaitEvents,interpolatedVD, error] = StepDetection(interpolatedVD, Name,Test);
                    [GaitEvents, GaitParameters, GaitCycles,GaitPathDescription,VD_tmvy] = GaitWork_Treadmill(interpolatedVD, GaitEvents,filename);

                    GaitSummary.(Particiapnt_Name).(filename).GaitEvents = GaitEvents;

                    GaitSummary.(Particiapnt_Name).(filename).GaitParameters = GaitParameters;
                    GaitSummary.(Particiapnt_Name).(filename).GaitPathDescription = GaitPathDescription;
                    GaitSummary.(Particiapnt_Name).(filename).GaitCycles = GaitCycles;

                    GaitSummary.(Particiapnt_Name).(filename).KinematicData = VD;
                    GaitSummary.(Particiapnt_Name).(filename).KinematicData_tm_Y_v = VD_tmvy;

                elseif ctrialsfewEvents>0
                    disp({ctrialsfewEventsnames});
                    continue;
                else
                    fprintf('%s has not been correctly converted to the MAT format',filename);
                    continue;
                end
            else
                fprintf("%s Recruiment Curve Skipped\n",filename)
                continue;
            end
        catch
            fprintf('error in trial %d \n',trial);
        end
    end

    datasave= fullfile(destPath,GaitSummary);
    save(datasave,Name,'-v7.3');
    clearvars -except TestPath1 pathCompSep currentfolder foldername ProcessedData_idx subjectsNames subjectloop
end
