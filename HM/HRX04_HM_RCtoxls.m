%% Analysis of RC for everycondition
% Organising all the RC parameters from each participant
% Sheet 1: All the values for RC condition
% Sheet 2: All the values for each condition from each participant
% Sheet 3: All the raw values from every condition and every participants.
clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking_2';
        pathCompSep = '/';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
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


header_RC = {'Subject','HMratio','H_r2','H_rmse','M_r2','M_rmse','Hmax','Mmax','70Hmax','StimHmax','Stim70Hmax','Bemg'};
HMall_RC = header_RC;
header = {'Subject','HMratio','H_mean(mV P-P)','H_std','M_mean(mV P-P)','M_std','Hmax(mV P-P)','Mma(mV P-P)','StmI(mA)','Bemg_mean(mV)','Bemg_std','CV_H','CV_M','CV_Bemg'};
HMall = header;
header_raw = {'Subject','H_wave(mV P-P)','M_wave(mV P-P)','Stim(mA)'};
HMall_Raw = header_raw;


for subjectloop = 1:length(subjectsNames)

    part = subjectsNames(subjectloop).name;
    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_HRXdata = [temp_dir_vicon(1).folder,pathCompSep,'HM'];
    addpath(genpath(DIR_HRXdata))
    trialnames = dir([DIR_HRXdata, pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat

    if size(trialnames,1) == 1
        filename = trialnames.name;
        [~,baseFileName, extension] = fileparts(filename);

        dataload = load(fullfile(DIR_HRXdata,filename));
        dataload = dataload.(baseFileName);
        fnames = fieldnames(dataload);

        for i = 1: size(fnames)

            data = dataload.(fnames{i});
            data_1_Hraw = data.RecruitmentSummary.HReflex;
            data_1_Mraw = data.RecruitmentSummary.Mwave;
            data_1_Sraw = data.RecruitmentSummary.Stimulus*1000';
            data.RecruitmentSummary.HMALL(2,6) = {std(data.RecruitmentSummary.Mwave)};
            data.RecruitmentSummary.HMALL(1,10) = {'BEmg_mean'};
            data.RecruitmentSummary.HMALL(1,11) = {'BEmg_std'};
            data.RecruitmentSummary.HMALL(2,11) = {std(data.RecruitmentSummary.BEmg)};
            data_1 = data.RecruitmentSummary.HMALL;

            if fnames{i} == "recru"

                tmp_rc = {data_1{2,1},data_1{2,2},data_1{2,3},data_1{2,4},data_1{2,5},data_1{2,6},data_1{2,7},data_1{2,8},data_1{2,9},data_1{2,10},data_1{2,11}*1000,data_1{2,12}};
                HMall_RC = cat(1,HMall_RC,tmp_rc);
                tmp_all_raw = table(repelem(data_1{2,1},[size(data_1_Hraw,1)],[1]),...
                    data_1_Hraw,data_1_Mraw,data_1_Sraw);
                tmp_all_raw = table2cell(tmp_all_raw);
                HMall_Raw = cat(1,HMall_Raw,tmp_all_raw);
                clear data_1

            else
                %% write all together
                tmp_all = {data_1{2,1},data_1{2,2},data_1{2,3},data_1{2,4},data_1{2,5},data_1{2,6},data_1{2,7},data_1{2,8},data_1{2,9}*1000,data_1{2,10},data_1{2,11},(data_1{2,4}/data_1{2,3}),(data_1{2,6}/data_1{2,5}),(data_1{2,11}/data_1{2,10})};
                HMall = cat(1,HMall,tmp_all);
                tmp_all_raw = table(repelem(data_1{2,1},[size(data_1_Hraw,1)],[1]),...
                    data_1_Hraw,data_1_Mraw,data_1_Sraw);
                tmp_all_raw = table2cell(tmp_all_raw);
                HMall_Raw = cat(1,HMall_Raw,tmp_all_raw);
                clear data_1
            end
        end
    else
        fprintf("%s does not have summary\n",part);
        continue;
    end
end

destPath = [TestPath1,'Results',pathCompSep,'HM'];



if ~exist(destPath,'dir')
    mkdir(destPath)
end

FullPathName = fullfile(destPath,'HMdata.xlsx');

xlswrite(FullPathName,HMall_RC,1);     % Recruitment Curve
xlswrite(FullPathName,HMall,2);        % HM Analysis for each Condition
xlswrite(FullPathName,HMall_Raw,3);    % Raw values of each condition
