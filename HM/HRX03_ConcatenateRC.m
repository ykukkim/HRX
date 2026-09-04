%% EMG analysis H and M waves for recruitment curve for stimulus and non stimulus
% Concatenates Bemg, H, and M waves of all trials.
% Line fitting for the RC trials

clear all; clc; close all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1= '/Users/YKK/Desktop/YKKDTOP/ETH/Research/HRX/Data/Results/HM/matfiles';
    case 1
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
end

%% Setting Directory for data
currentfolder = pwd;
addpath(genpath(TestPath1));
addpath(genpath(currentfolder));
foldername = dir(TestPath1);
foldername(strncmp({foldername.name}, '.', 1)) = [];

ProcessedData_idx = find(strcmp({foldername.name},'Processed'));
subjectsNames = dir([foldername(ProcessedData_idx).folder,filesep,foldername(ProcessedData_idx).name]);
subjectsNames(strncmp({subjectsNames.name}, '.', 1)) = [];

%% Pre-initialisation
linefit_RC   = @Linefit_RC;
linefit_rest = @Linefit_nonRC;

for subjectloop = 3%1:length(subjectsNames)

    %% Preallocating Spaces
    part = subjectsNames(subjectloop).name;
    [~,baseFileName, extension] = fileparts(part);

    temp_dir = dir([subjectsNames(subjectloop).folder,filesep,subjectsNames(subjectloop).name,filesep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,filesep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];
    DIR_HRXdata = [temp_dir_vicon(1).folder,filesep,'RCSummary'];

    trialnames = dir([DIR_HRXdata, filesep, '*.mat']);
    dataload = load(fullfile([trialnames.folder, filesep,trialnames.name]));
    fnames = fieldnames(dataload.(trialnames.name(1:end-4)));
    destPath= [temp_dir_vicon(1).folder,filesep,'HM'];

    if ~exist(destPath, 'dir')
        mkdir(destPath)
    end

    for i = 1: size(fnames)

        filename = [(trialnames.name(1:end-4)),'_',fnames{i}];
        if fnames{i} == "recru"
            [HMALL] = linefit_RC(dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.HReflex,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.Mwave,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.BEmg,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.Stimulus,destPath,filename);
            RecruitmentSummary = dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary;
            RawValues= dataload.(trialnames.name(1:end-4)).(fnames{i}).RawValues;
            RecruitmentSummary.HMALL = HMALL;

        else
            [HMALL] = linefit_rest(dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.HReflex,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.Mwave,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.BEmg,...
                dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary.Stimulus,filename);
            RecruitmentSummary = dataload.(trialnames.name(1:end-4)).(fnames{i}).RecruitmentSummary;
            RawValues= dataload.(trialnames.name(1:end-4)).(fnames{i}).RawValues;
            RecruitmentSummary.HMALL = HMALL;
        end
        comd = [(trialnames.name(1:end-4)),'.',fnames{i}, '.RecruitmentSummary = RecruitmentSummary;'];
        eval(comd);
    end

    close;

    datasave = fullfile(destPath,(trialnames.name(1:end-4)));
    save(datasave,(trialnames.name(1:end-4)),'-v7.3');
    clearvars -except TestPath1 filesep subjectsNames subjectloop linefit_RC linefit_rest
end
