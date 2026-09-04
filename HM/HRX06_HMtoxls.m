%% Exporting Parameters to Excelsheets of H and M analysis
% Values from script 4 and 5 is gathered and produced as one.
% Output: .xlsx file
clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1 = '/Users/YKK/Desktop/YKKDTOP/ETH/Research/HRX/Data/Results/HM/matfiles_3';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';end
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

header_Summary = {'Subject','HMratio(HSMST)','H_mean(HSMST)','H_std(HSMST)','Hmax(HSMST)','M_mean(HSMST)','M_std(HSMST)','Mmax(HSMST)','StmI(HSMST)',...
    'Bemg_mean(HSMST)','Bemg_Std(HSMST)','Max_Bemg(HSMST)','Gait Phase Mean(%)(HSMST)','Std GP(HSMST)','Max_GP(HSMST)',...
    'HMratio(MSTHO)','H_mean','H_std(MSTHO)','Hmax(MSTHO)','M_mean(MSTHO)','M_std(MSTHO)','Mmax(MSTHO)','StmI(MSTHO)',...
    'Bemg_mean(MSTHO)','Bemg_Std(MSTHO)','Max_Bemg(MSTHO)','Gait Phase Mean(%)(MSTHO)','Std GP(MSTHO)','Max_GP(MSTHO)'};
HMall_Summary = header_Summary;

header_Raw = {'Subject','H_wave(mV P-P)','M_wave(mV P-P)','BEmg(mv P-P)','Stim(mA)','Location of Trigger','Location of HS','Gait Phase(%)'};
HMall = header_Raw;

for subjectloop = 1:length(subjectsNames)

    part = subjectsNames(subjectloop).name;
    temp_dir = dir([subjectsNames(subjectloop).folder,filesep,subjectsNames(subjectloop).name,filesep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,filesep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];
    DIR_HRXdata = [temp_dir_vicon(1).folder,filesep,'HMSeperation'];

    addpath(genpath(DIR_HRXdata))
    trialnames = dir([DIR_HRXdata, filesep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat

    if size(trialnames,1) == 1
        filename = trialnames.name;
        [~,baseFileName, extension] = fileparts(filename);

        dataload = load(fullfile(DIR_HRXdata,filename));
        dataload = dataload.(baseFileName);
        fnames = fieldnames(dataload);

        for i = 1: size(fnames)

            Data = dataload.(fnames{i});
            Data_HSMidST  = Data.HSMidST;
            Data_MidSTHO  = Data.MidSTHO;
            DataSummary= Data.Summary;

            if isequal(Data_HSMidST,0) == 1  && isequal(Data_MidSTHO,0) == 0

                if size(Data_MidSTHO.Baseline,1) > 1
                    size_MidSTHO = size(Data_MidSTHO.Baseline,1);
                    tmp_all_MidSTHO = table(repelem(DataSummary{2,1},(size_MidSTHO),(1)),Data_MidSTHO.HWave,Data_MidSTHO.MWave,Data_MidSTHO.Baseline,...
                        Data_MidSTHO.StimInt,Data_MidSTHO.LocT,Data_MidSTHO.LocHS,Data_MidSTHO.PerGait);
                    tmp_all_MidSTHO = table2cell(tmp_all_MidSTHO);
                    HMall = cat(1,HMall,tmp_all_MidSTHO);
                elseif size(Data_MidSTHO.Baseline,1) == 1

                    tmp_all_MidSTHO = table(DataSummary{2,1},Data_MidSTHO.HWave,Data_MidSTHO.MWave,Data_MidSTHO.Baseline,...
                        Data_MidSTHO.StimInt,Data_MidSTHO.LocT,Data_MidSTHO.LocHS,Data_MidSTHO.PerGait);
                    tmp_all_MidSTHO = table2cell(tmp_all_MidSTHO);
                    HMall = cat(1,HMall,tmp_all_MidSTHO);

                end

            elseif isequal(Data_HSMidST,0) == 0  && isequal(Data_MidSTHO,0) == 1

                if size(Data_HSMidST.Baseline,1) > 1
                    size_HSMidST = size(Data_HSMidST.Baseline,1);
                    tmp_all_HSMidST = table(repelem(DataSummary{2,1},(size_HSMidST),(1)),Data_HSMidST.HWave,Data_HSMidST.MWave,Data_HSMidST.Baseline,...
                        Data_HSMidST.StimInt,Data_HSMidST.LocT,Data_HSMidST.LocHS,Data_HSMidST.PerGait);
                    tmp_all_HSMidST = table2cell(tmp_all_HSMidST);
                    HMall = cat(1,HMall,tmp_all_HSMidST);
                elseif size(Data_HSMidST.Baseline,1) == 1

                    tmp_all_HSMidST = table(DataSummary{2,1},Data_HSMidST.HWave,Data_HSMidST.MWave,Data_HSMidST.Baseline,...
                        Data_HSMidST.StimInt,Data_HSMidST.LocT,Data_HSMidST.LocHS,Data_HSMidST.PerGait);
                    tmp_all_HSMidST = table2cell(tmp_all_HSMidST);
                    HMall = cat(1,HMall,tmp_all_HSMidST);
                end

            elseif isequal(Data_HSMidST,0) == 0  && isequal(Data_MidSTHO,0) == 0

                if size(Data_HSMidST.Baseline,1) > 1 && size(Data_MidSTHO.Baseline,1) > 1
                    size_HSMidST = size(Data_HSMidST.Baseline,1);
                    tmp_all_HSMidST = table(repelem(DataSummary{2,1},(size_HSMidST),(1)),Data_HSMidST.HWave,Data_HSMidST.MWave,Data_HSMidST.Baseline,...
                        Data_HSMidST.StimInt,Data_HSMidST.LocT,Data_HSMidST.LocHS,Data_HSMidST.PerGait);
                    tmp_all_HSMidST = table2cell(tmp_all_HSMidST);
                    HMall = cat(1,HMall,tmp_all_HSMidST);

                    size_MidSTHO = size(Data_MidSTHO.Baseline,1);
                    tmp_all_MidSTHO = table(repelem(DataSummary{2,1},(size_MidSTHO),(1)),Data_MidSTHO.HWave,Data_MidSTHO.MWave,Data_MidSTHO.Baseline,...
                        Data_MidSTHO.StimInt,Data_MidSTHO.LocT,Data_MidSTHO.LocHS,Data_MidSTHO.PerGait);
                    tmp_all_MidSTHO = table2cell(tmp_all_MidSTHO);
                    HMall = cat(1,HMall,tmp_all_MidSTHO);
                elseif size(Data_HSMidST.Baseline,1) == 1 && size(Data_MidSTHO.Baseline,1) == 1

                    tmp_all_HSMidST = table(DataSummary{2,1},Data_HSMidST.HWave,Data_HSMidST.MWave,Data_HSMidST.Baseline,...
                        Data_HSMidST.StimInt,Data_HSMidST.LocT,Data_HSMidST.LocHS,Data_HSMidST.PerGait);
                    tmp_all_HSMidST = table2cell(tmp_all_HSMidST);
                    HMall = cat(1,HMall,tmp_all_HSMidST);

                    tmp_all_MidSTHO = table(DataSummary{2,1},Data_MidSTHO.HWave,Data_MidSTHO.MWave,Data_MidSTHO.Baseline,...
                        Data_MidSTHO.StimInt0,Data_MidSTHO.LocT,Data_MidSTHO.LocHS,Data_MidSTHO.PerGait);
                    tmp_all_MidSTHO = table2cell(tmp_all_MidSTHO);
                    HMall = cat(1,HMall,tmp_all_MidSTHO);
                end
            end
            tmp_all_summary = {DataSummary{2,1},DataSummary{2,2},DataSummary{2,3},DataSummary{2,4},DataSummary{2,5},DataSummary{2,6},...
                DataSummary{2,7},DataSummary{2,8},DataSummary{2,9},DataSummary{2,10},DataSummary{2,11},DataSummary{2,12},DataSummary{2,13},...
                DataSummary{2,14},DataSummary{2,15},DataSummary{2,16},DataSummary{2,17},DataSummary{2,18},DataSummary{2,19},DataSummary{2,20},...
                DataSummary{2,21},DataSummary{2,22},DataSummary{2,23},DataSummary{2,24},DataSummary{2,25},DataSummary{2,26},DataSummary{2,27},...
                DataSummary{2,28},DataSummary{2,29}};
            HMall_Summary = cat(1,HMall_Summary,tmp_all_summary);

            clearvars Data Data_HSMidST Data_MidSTHO DataSummary...
                tmp_all_HSMidST tmp_all_MidSTHO tmp_all_summary
        end
    else
        fprintf("%s does not have summary\n",part);
        continue;
    end
end

destPath = [TestPath1,'Results',filesep,'HM'];

if ~exist(destPath,'dir')
    mkdir(destPath)
end

FullPathName = fullfile(destPath,'HMdata_correctBemg.xlsx');

xlswrite(FullPathName,HMall,4);
xlswrite(FullPathName,HMall_Summary,5);
