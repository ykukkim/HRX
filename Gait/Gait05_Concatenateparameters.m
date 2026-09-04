%% Concatenates relevant spatio-temporal gait parameters
% This scripts concatenates relevant gait parameters into one.
% Then box plots
% clear; close; clc;

% Setting Directory for data
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac\n');

switch ifMac

    case 0
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/Data/Processed';
        pathCompSep = '/';

    case 1
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
        pathCompSep  = '\';
end

% Setting Directory for data
addpath(genpath(TestPath1));
currentfolder = pwd;
addpath(genpath(currentfolder));
foldername = dir(TestPath1);
foldername(strncmp({foldername.name}, '.', 1)) = [];

ProcessedData_idx = find(strcmp({foldername.name},'Processed'));
subjectsNames = dir([foldername(ProcessedData_idx).folder,pathCompSep,foldername(ProcessedData_idx).name]);
subjectsNames(strncmp({subjectsNames.name}, '.', 1)) = [];

load(fullfile([TestPath1,'Results',pathCompSep,'Mos'],'allMoS'));
destPath = [TestPath1,'Results',pathCompSep,'Gait'];

if ~exist(destPath, 'dir')
    mkdir(destPath)
end
% ======================================== Extracting interested parameters from each Participant ================================================ %%
for subjectloop = 1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_HRXdata = [temp_dir_vicon(1).folder,pathCompSep,'GaitSummary'];
    addpath(genpath(DIR_HRXdata))
    trialnames = dir([DIR_HRXdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    trialnames(strncmp({trialnames.name}, '.', 1)) = [];

    Sub=load([DIR_HRXdata,pathCompSep,trialnames.name]);
    filename = trialnames(1).name(1:end-4);  % remove the file extensions
    Name = filename(1:7);
    condition = fieldnames(Sub.(Name));

    for trial = 1:length(fieldnames(Sub.(Name)))

        % Step index
        HSloc.(Name).(condition{trial}).left.time    = Sub.(Name).(condition{trial}).GaitEvents.HSleftlocs;
        HSloc.(Name).(condition{trial}).right.time   = Sub.(Name).(condition{trial}).GaitEvents.HSrightlocs;

        % Double limb support time
        dls.(Name).(condition{trial}).left.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.dlsL);
        dls.(Name).(condition{trial}).left.mean   = mean(dls.(Name).(condition{trial}).left.time);
        dls.(Name).(condition{trial}).left.std    = std(dls.(Name).(condition{trial}).left.time);
        dls.(Name).(condition{trial}).left.median = median(dls.(Name).(condition{trial}).left.time);

        dls.(Name).(condition{trial}).right.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.dlsR);
        dls.(Name).(condition{trial}).right.mean   = mean(dls.(Name).(condition{trial}).right.time);
        dls.(Name).(condition{trial}).right.std    = std(dls.(Name).(condition{trial}).right.time);
        dls.(Name).(condition{trial}).right.median = median(dls.(Name).(condition{trial}).right.time);

        % Gait Cycle Duration
        durationGaitCycle.(Name).(condition{trial}).left.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationGaitCycleL);
        durationGaitCycle.(Name).(condition{trial}).left.mean   = mean(durationGaitCycle.(Name).(condition{trial}).left.time);
        durationGaitCycle.(Name).(condition{trial}).left.std    = std(durationGaitCycle.(Name).(condition{trial}).left.time);
        durationGaitCycle.(Name).(condition{trial}).left.median = median(durationGaitCycle.(Name).(condition{trial}).left.time);

        durationGaitCycle.(Name).(condition{trial}).right.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationGaitCycleR);
        durationGaitCycle.(Name).(condition{trial}).right.mean   = mean(durationGaitCycle.(Name).(condition{trial}).right.time);
        durationGaitCycle.(Name).(condition{trial}).right.std    = std(durationGaitCycle.(Name).(condition{trial}).right.time);
        durationGaitCycle.(Name).(condition{trial}).right.median = median(durationGaitCycle.(Name).(condition{trial}).right.time);

        % Step Width
        stepwidth.(Name).(condition{trial}).left.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.stepWidthL);
        stepwidth.(Name).(condition{trial}).left.mean   = mean(stepwidth.(Name).(condition{trial}).left.length);
        stepwidth.(Name).(condition{trial}).left.std    = std(stepwidth.(Name).(condition{trial}).left.length);
        stepwidth.(Name).(condition{trial}).left.median = median(stepwidth.(Name).(condition{trial}).left.length);

        stepwidth.(Name).(condition{trial}).right.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.stepWidthR);
        stepwidth.(Name).(condition{trial}).right.mean   = mean(stepwidth.(Name).(condition{trial}).right.length);
        stepwidth.(Name).(condition{trial}).right.std    = std(stepwidth.(Name).(condition{trial}).right.length);
        stepwidth.(Name).(condition{trial}).right.median = median(stepwidth.(Name).(condition{trial}).right.length);

        % Stride length
        stridelength.(Name).(condition{trial}).left.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.strideLengthL);
        stridelength.(Name).(condition{trial}).left.mean   = mean(stridelength.(Name).(condition{trial}).left.length);
        stridelength.(Name).(condition{trial}).left.std    = std(stridelength.(Name).(condition{trial}).left.length);
        stridelength.(Name).(condition{trial}).left.median = median(stridelength.(Name).(condition{trial}).left.length);

        stridelength.(Name).(condition{trial}).right.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.strideLengthR);
        stridelength.(Name).(condition{trial}).right.mean   = mean(stridelength.(Name).(condition{trial}).right.length);
        stridelength.(Name).(condition{trial}).right.std    = std(stridelength.(Name).(condition{trial}).right.length);
        stridelength.(Name).(condition{trial}).right.median = median(stridelength.(Name).(condition{trial}).right.length);

        % Step Length
        steplength.(Name).(condition{trial}).left.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.stepLengthL);
        steplength.(Name).(condition{trial}).left.mean   = mean(steplength.(Name).(condition{trial}).left.length);
        steplength.(Name).(condition{trial}).left.std    = std(steplength.(Name).(condition{trial}).left.length);
        steplength.(Name).(condition{trial}).left.median = median(steplength.(Name).(condition{trial}).left.length);

        steplength.(Name).(condition{trial}).right.length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.stepLengthR);
        steplength.(Name).(condition{trial}).right.mean   = mean(steplength.(Name).(condition{trial}).right.length);
        steplength.(Name).(condition{trial}).right.std    = std(steplength.(Name).(condition{trial}).right.length);
        steplength.(Name).(condition{trial}).right.median = median(steplength.(Name).(condition{trial}).right.length);

        % Swing Phase
        swingPhase.(Name).(condition{trial}).left.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationSwingPhL);
        swingPhase.(Name).(condition{trial}).left.mean   = mean(swingPhase.(Name).(condition{trial}).left.time);
        swingPhase.(Name).(condition{trial}).left.std    = std(swingPhase.(Name).(condition{trial}).left.time);
        swingPhase.(Name).(condition{trial}).left.median = median(swingPhase.(Name).(condition{trial}).left.time);

        swingPhase.(Name).(condition{trial}).right.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationSwingPhR);
        swingPhase.(Name).(condition{trial}).right.mean   = mean(swingPhase.(Name).(condition{trial}).right.time);
        swingPhase.(Name).(condition{trial}).right.std    = std(swingPhase.(Name).(condition{trial}).right.time);
        swingPhase.(Name).(condition{trial}).right.median = median(swingPhase.(Name).(condition{trial}).right.time);

        % Stance Phase
        stancePhase.(Name).(condition{trial}).left.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationStancePhL);
        stancePhase.(Name).(condition{trial}).left.mean   = mean(stancePhase.(Name).(condition{trial}).left.time);
        stancePhase.(Name).(condition{trial}).left.std    = std(stancePhase.(Name).(condition{trial}).left.time);
        stancePhase.(Name).(condition{trial}).left.median = median(stancePhase.(Name).(condition{trial}).left.time);

        stancePhase.(Name).(condition{trial}).right.time   = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.durationStancePhR);
        stancePhase.(Name).(condition{trial}).right.mean   = mean(stancePhase.(Name).(condition{trial}).right.time);
        stancePhase.(Name).(condition{trial}).right.std    = std(stancePhase.(Name).(condition{trial}).right.time);
        stancePhase.(Name).(condition{trial}).right.median = median(stancePhase.(Name).(condition{trial}).right.time);

        % MoS
        MoS.(Name).(condition{trial}).left.length = rmoutliers(allMoS.(Name).(condition{trial}).MOS_Left_atLHS);
        MoS.(Name).(condition{trial}).left.mean   = mean(MoS.(Name).(condition{trial}).left.length);
        MoS.(Name).(condition{trial}).left.std    = std(MoS.(Name).(condition{trial}).left.length);
        MoS.(Name).(condition{trial}).left.median = median(MoS.(Name).(condition{trial}).left.length);

        MoS.(Name).(condition{trial}).right.length = rmoutliers(allMoS.(Name).(condition{trial}).MOS_Right_atRHS);
        MoS.(Name).(condition{trial}).right.mean   = mean(MoS.(Name).(condition{trial}).right.length);
        MoS.(Name).(condition{trial}).right.std    = std(MoS.(Name).(condition{trial}).right.length);
        MoS.(Name).(condition{trial}).right.median = median(MoS.(Name).(condition{trial}).right.length);

        % Cadence
        cadence.(Name).(condition{trial}).length = rmoutliers(Sub.(Name).(condition{trial}).GaitParameters.Cadence);
        cadence.(Name).(condition{trial}).mean   = mean(cadence.(Name).(condition{trial}).length );
        cadence.(Name).(condition{trial}).std    = std(cadence.(Name).(condition{trial}).length );
        cadence.(Name).(condition{trial}).median = median(cadence.(Name).(condition{trial}).length );
    end
end

datasave= fullfile(destPath,'HSloc');
save(datasave,'HSloc','-v7.3');
datasave= fullfile(destPath,'dls');
save(datasave,'dls','-v7.3');
datasave= fullfile(destPath,'durationGaitCycle');
save(datasave,'durationGaitCycle','-v7.3');
datasave= fullfile(destPath,'stepwidth');
save(datasave,'stepwidth','-v7.3');
datasave= fullfile(destPath,'stridelength');
save(datasave,'stridelength','-v7.3');
datasave= fullfile(destPath,'steplength');
save(datasave,'steplength','-v7.3');
datasave= fullfile(destPath,'swingPhase');
save(datasave,'swingPhase','-v7.3');
datasave= fullfile(destPath,'stancePhase');
save(datasave,'stancePhase','-v7.3');
datasave= fullfile(destPath,'MoS');
save(datasave,'MoS','-v7.3');
datasave= fullfile(destPath,'cadence');
save(datasave,'cadence','-v7.3');
