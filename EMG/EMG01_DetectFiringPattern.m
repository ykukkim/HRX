%% Detecting OnSets and OffSets of muscle activation
% This should be the first script to be ran in this folder.
% Parameters adjustments are required to have the correct firing detection
% of muscles
% Goes through all paricipants and saves under the participant folder
% https://github.com/GallVp/emgGO
clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1 = '/Users/YKK/Desktop/YKKDTOP/ETH/Research/HRX/Data/Results/HM/matfiles_3';
        pathCompSep = '/';

    case 1
        TestPath1= 'D:\HRX\';
        pathCompSep = '\';
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


for subjectloop = 2:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_HRXdata = [temp_dir_vicon(1).folder,pathCompSep,'matfiles'];
    trialnames = dir([DIR_HRXdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    destPath= [temp_dir_vicon(1).folder,pathCompSep,'EMGfiring'];

    if ~exist(destPath,'dir')
        mkdir(destPath)
    end

    processFolder(DIR_HRXdata, destPath, @runToolboxFunc, [], @editFunc);

end
