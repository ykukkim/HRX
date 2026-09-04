
clear;close all; clc;

load('P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Data\ProcessedData\RealMeasurements\MoS_clean.mat')
load('P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Data\ProcessedData\RealMeasurements\stepWidth_clean.mat')
load('P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Data\ProcessedData\RealMeasurements\strideTime_clean.mat')

%%

% done like this because one participant has an other order
Participants = fieldnames(MoS_clean);
subjectName = Participants(1);
subjectName = cell2mat(subjectName);
Condition = fieldnames(MoS_clean.(subjectName));
Results = {'CV_APL_';'CV_APR_';'CV_MLL_';'CV_MLR_';'CV_sWL_';'CV_sWR_';'CV_sTL_';'CV_sTR_'};

Width = length(Results);

Titles(1,1:Width+2) = {'Subject'};
Titles(1,2) = {'Condition'};
Titles(1,3:end) = Results;

Results_CoefOfVar(1:length(Participants)*length(Condition),1:Width+2) = {'-'};

endpoint_old = 0;

for i = 1:length(Participants)

    endpoint_new = endpoint_old+length(Condition);

    subjectName = Participants(i);
    subjectName = cell2mat(subjectName);

    Results_CoefOfVar(endpoint_old+1:endpoint_new,1) = {subjectName};

    if i == 9
        MoS_clean.DIZE_52.wei20_0.AP_Left = 1;
        MoS_clean.DIZE_52.wei20_0.AP_Right = 1;
        MoS_clean.DIZE_52.wei20_0.ML_Left = 1;
        MoS_clean.DIZE_52.wei20_0.ML_Right = 1;
        stepWidth_clean.DIZE_52.wei20_0.Left = 1;
        stepWidth_clean.DIZE_52.wei20_0.Right = 1;
        strideTime_clean.DIZE_52.wei20_0.Left = 1;
        strideTime_clean.DIZE_52.wei20_0.Right = 1;
    end

    for j = 1:length(Condition)

        currentfdname = Condition(j);
        condition = cell2mat(currentfdname);

        k = endpoint_old+j;

        Results_CoefOfVar(k,2) = {condition};

        APL = MoS_clean.(subjectName).(condition).AP_Left;
        APR = MoS_clean.(subjectName).(condition).AP_Right;
        MLL = MoS_clean.(subjectName).(condition).ML_Left;
        MLR = MoS_clean.(subjectName).(condition).ML_Right;
        Results_CoefOfVar(k,3) = {(std(APL)/mean(APL))*100};
        Results_CoefOfVar(k,4) = {(std(APR)/mean(APR))*100};
        Results_CoefOfVar(k,5) = {(std(MLL)/mean(MLL))*100};
        Results_CoefOfVar(k,6) = {(std(MLR)/mean(MLR))*100};

        SWL = stepWidth_clean.(subjectName).(condition).Left;
        SWR = stepWidth_clean.(subjectName).(condition).Right;
        Results_CoefOfVar(k,7) = {(std(SWL)/mean(SWL))*100};
        Results_CoefOfVar(k,8) = {(std(SWR)/mean(SWR))*100};

        STL = strideTime_clean.(subjectName).(condition).Left;
        STR = strideTime_clean.(subjectName).(condition).Right;
        Results_CoefOfVar(k,9) = {(std(STL)/mean(STL))*100};
        Results_CoefOfVar(k,10) = {(std(STR)/mean(STR))*100};

    end

    if i==9
        Results_CoefOfVar(endpoint_old+7,3:end) = {'-'};
    end

    endpoint_old = endpoint_new;

end

%% now creating the excel file

CV_all(1:length(Results_CoefOfVar)+1,1:length(Results_CoefOfVar(1,:))) = {'-'};
CV_all(1,1:end) = Titles;
CV_all(2:length(Results_CoefOfVar)+1,1:end) = Results_CoefOfVar;

cd 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Data\ProcessedData\RealMeasurements'

filename = 'CV_all.xlsx';
xlswrite(filename,CV_all)
