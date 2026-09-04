%% Converts mat-files from c3d-files. Runs over common Vicon Database structure
% Aimed to create variables needed to calculate recruitment curve
% Prerequisit is installed btk-toolkit

% Input: c3d files containing Analog signals e.g. Soleus EMG, Stimulus Output, Stimulus
% Intensity
% Output: mat files containing Soleus EMG, Stimulus Output, Stimulus
% Intensity

% User choose location of Vicon Database and folder for mat-files storage
% Hierarchy: Level1[HRX]\Level2[HRX_WALKING]\Level3[P01]\Level4[S01]\c3d-data [Select folder Level1]

clc; clear all; close all

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking_2/Data/Processed';
        pathCompSep = '/';

    case 1
        TestPath1= '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data';
        %         TestPath1 = 'D:\HRX';
        pathCompSep = '\';
end

currentfolder = pwd;
addpath(genpath('Functions'));
addpath(genpath('btk'));

% Get first level directories
listL1 = dir(TestPath1);
listL1(strncmp({listL1.name}, '.', 1)) = [];
dirFlagsL1 = [listL1.isdir];
listL1 = listL1(dirFlagsL1);

% Walk through each subdirectory
for i =  1%:length(listL1)

    tmpDir2 = fullfile([listL1(i).folder,pathCompSep,listL1(i).name]);
    listL2 = dir(tmpDir2);
    listL2(strncmp({listL2.name}, '.', 1)) = [];
    dirFlagsL2 = [listL2.isdir];
    listL2 = listL2(dirFlagsL2);

    for j = 1:length(listL2)
        tmpDir3 = fullfile(TestPath1,listL1(i).name,listL2(j).name);
        listL3 = dir(tmpDir3);
        listL3(strncmp({listL3.name}, '.', 1)) = [];
        dirFlagsL3 = [listL3.isdir];
        listL3 = listL3(dirFlagsL3);

        for k = 1:length(listL3)

            tmpDir4 = fullfile(TestPath1,listL1(i).name,listL2(j).name,listL3(k).name,'c3d');
            dirFiles = dir(fullfile(tmpDir4,'*.c3d'));

            if size(dirFiles,1) >= 1
                ParticipantName = randomName();
                part = listL1(i).name;

                %                 destPath = [TestPath1,pathCompSep,part,pathCompSep,'Vicon',pathCompSep,'matfiles'];
                destPath =  fullfile(TestPath1,listL1(i).name,listL2(j).name,listL3(k).name,'matfiles');
                if ~exist(destPath,'dir')
                    mkdir(destPath)
                end

                cd (tmpDir4);

                for l = 1:length(dirFiles)
                    try
                        filename = dirFiles(l,1).name(1:end-4);
                        c3dfiletoLoad = dirFiles(l).name;
                        acq = btkReadAcquisition(c3dfiletoLoad);

                        % Kinematic Data
                        VD = btkGetMarkers(acq);
                        VD.SF = btkGetPointFrequency(acq);

                        % Analog Values
                        AnalogCh = btkGetAnalogs(acq);
                        AnalogCh.ratio = btkGetAnalogSampleNumberPerFrame(acq);
                        AnalogCh.sf = btkGetAnalogFrequency(acq);

                        AnalogCh.analchannelNo = btkGetAnalogNumber(acq);
                        AnalogCh.EMG = btkGetAnalogsValues(acq);

                        tmpfilenametosave = [ParticipantName,'_',dirFiles(l).name(1:end-4),'.mat'];
                        tmpfiletosave = fullfile(destPath, tmpfilenametosave);

                        save(tmpfiletosave,'VD','AnalogCh');

                        clear AnalogCh
                        clear VD
                    catch
                        warning('Problem using function.');
                        clear EMG
                        clear VD
                    end
                end
            end
        end
    end
end
