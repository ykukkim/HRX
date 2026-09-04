%% Collecting all parameters from EMG firing data
clc;clear; close all;

%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1= '/Users/YKK/Desktop/ETH/Research/HRX_Walking/Data/ProcessedData';

        pathCompSep = '/';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1= 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Students\Yong\HRX_Walking\Data\ProcessedData';


        CalibPath = '';
        pathCompSep = '\';
end
%DIR = '/Users/YKK/Desktop/ETH/Research/HRX_Walking/Data/ProcessedData';
addpath(genpath(TestPath1));
currentfolder = pwd;
% addpath(genpath(currentfolder));
subjectNames = dir(TestPath1);
subjectNames(strncmp({subjectNames.name}, '.', 1)) = [];


destPath = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Students\Yong\HRX_Walking\Data\Results';
if ~exist(destPath,'dir')
    mkdir(destPath)
end
RLT_Total = [];
for subjectloop = 1:length(subjectNames)

    part = subjectNames(subjectloop).name;
    DIR_EMGdata = [TestPath1, pathCompSep,part,pathCompSep,'EMGfiring'];
    trialnames = dir([DIR_EMGdata, pathCompSep, '*.mat']);
    TR_Param = [];
    TL_Param = [];
    Subject = [];
    for trial = 1:size(trialnames,1)
        filename = trialnames(trial).name;
        dataload = load(fullfile(DIR_EMGdata,filename));
        TR_Param = cat(1,TR_Param,dataload.RIGHTParam);
        TL_Param = cat(1,TL_Param,dataload.LEFTParam);
        Name = table(repelem(filename(1:end-4),[size(dataload.RIGHTParam,1)],[1]));
        Subject = cat(1,Subject,Name);
    end

    RT = array2table(TR_Param);
    LT = array2table(TL_Param);
    RLT = horzcat(RT,LT);
    RLT2 = horzcat(Subject,RLT);
    RLT_Total = cat(1,RLT_Total,RLT2);

end

RLT_Total.Properties.VariableNames = {'Name','RSOL','RTIA','RGAL','RGAM','RVAM','RVAL','RBIF','LSOL','LTIA','LGAL','LGAM','LVAM','LVAL','LBIF'};
TestPath2 = 'P:\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\Students\Yong\HRX_Walking\Data\Results';
Filesave= [TestPath2, pathCompSep, 'Summary',pathCompSep, 'EMGSummary'];
if ~exist(Filesave,'dir')
    mkdir(Filesave)
end

FullPathName = fullfile(Filesave,'EMGdata.csv');

writetable(RLT_Total,FullPathName,1);
