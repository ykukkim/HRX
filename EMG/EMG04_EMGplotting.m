%% Plotting EMG activities
% 1. Plotting EMG activity through gait cycle of each condition in each
% Participant
% 2. Plotting Onsets & Offsets of each muscle in each condition in each
% Participant
% 3. Plotting average of each firing pattern in each condition over participants.

clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac

    case 0
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/project_only/01_Data/Processed';
        pathCompSep = '/';

    case 1
        TestPath1    = 'D:\HRX\'; % change to the relevant Windows path.
        pathCompSep  = '\';
end

%% Setting Directory for data
addpath(genpath(TestPath1));
currentfolder = pwd;
addpath(genpath(currentfolder));

filenames= dir([TestPath1,'Results',pathCompSep,'EMG',pathCompSep '*.mat']);

emgconcat = load(fullfile(filenames.folder,pathCompSep,filenames.name));
LEG                 = ["RIGHTData" "LEFTData"];

for leg = 1:length(LEG)

    %     %% Plotting for Muscle activity through gait cycle
    emgconcat = plot_xstim_gait(emgconcat,LEG,leg,TestPath1,pathCompSep);
    emgconcat = plot_stim_gait(emgconcat,LEG,leg,TestPath1,pathCompSep);

    %     % Plotting for Muscle activity through Onsets & Offsets
    %     emgconcat = plot_xstim_seg(emgconcat,LEG,leg,TestPath1,pathCompSep);
    %     emgconcat = plot_stim_seg(emgconcat,LEG,leg,TestPath1,pathCompSep);
    %     % Concatenates firing pattern from each condition of all pariticipants
    %     emgconcat = emg_xstim_seg_concat(emgconcat,LEG,leg);
    %     emgconcat = emg_stim_seg_concat(emgconcat,LEG,leg);
    %     % Plotting the average firing pattern of muscle
    %     plot_ave_xstim(emgconcat,LEG,leg,TestPath1,pathCompSep);
    %     plot_ave_stim(emgconcat,LEG,leg,TestPath1,pathCompSep);

    %     % Concatenates muscle activity during the gait cycle
    %     % from each condition of all pariticipants
    emgconcat = emg_xstim_gait_concat(emgconcat,LEG,leg);
    emgconcat = emg_stim_gait_concat(emgconcat,LEG,leg);
    %     % Plotting the average firing pattern of muscle
    %     plot_ave_gait_xstim(emgconcat,LEG,leg,destPath1,pathCompSep);
    %     plot_ave_gait_stim(emgconcat,LEG,leg,TestPath1,pathCompSep);

    %   % Plotting the concatenated averaged of each muscle into
    %   % one(comparison)
    plot_ave_gait_xstim_total(emgconcat,LEG,leg,TestPath1,pathCompSep);
    plot_ave_gait_stim_total(emgconcat,LEG,leg,TestPath1,pathCompSep);

end
