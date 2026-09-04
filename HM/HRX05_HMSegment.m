%% Segemntation of values depending on the stimulus location
% HS to Midstance, midstance to Heel off
% Output: .mat files under the participant folder
% clc;close all;clear all;

ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1 = '/Users/YKK/Desktop/YKKDTOP/ETH/Research/HRX/Data/Results/HM/matfiles_3';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
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

for subjectloop = 1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,filesep,subjectsNames(subjectloop).name,filesep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,filesep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    %% Preallocating Spaces
    part = subjectsNames(subjectloop).name;
    DIR_HRXdata = [temp_dir_vicon(1).folder,filesep,'matfiles'];
    addpath(genpath(DIR_HRXdata));
    trialnames = dir([DIR_HRXdata, filesep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    nooffiles = length(trialnames);

    destPath= [temp_dir_vicon(1).folder,filesep,'HMSeperation'];

    if ~exist(destPath,'dir')
        mkdir(destPath)
    end
    for trial = 1:nooffiles

        %% Data Load of EMG
        Names = trialnames(trial).name(1:end-4);  % remove the file extensions
        data_1 = load(Names);

        Name = Names(1:7);
        Condition = Names(9:13);
        No = Names(end);
        Size_markers = size(fieldnames(data_1.VD),1);

        if No == "1" && Condition ~= "recru" && Size_markers > 1

            %% Determination of Dominant leg

            if (subjectloop == 11) || (subjectloop == 8 )
                dom_leg = 'left';
                Voltage_Value = data_1.AnalogCh.Voltage_5;
            else
                dom_leg = 'right';
                Voltage_Value = data_1.AnalogCh.Voltage_1;
            end


            %% Trigger Peak Detection
            Trigger = data_1.AnalogCh.Electric_Current_Trigger_Output;
            StimulusIntensity = data_1.AnalogCh.Electric_Current_Stimulus_Intensity;
            [Pks_t,Locs_t] = findpeaks(Trigger,'MinPeakDistance',500,'MinPeakHeight',1);
            Locs_t_ad = round(Locs_t/6); % Resampling (Vicon @ 500H, EMG @ 3000Hz)

        else
            disp(Names);
            disp('Non stimulus Trial');
            continue;
        end

        %% Heel Data Allocation
        VD = data_1.VD;

        %% Filter
        forder = 4;
        cutfreq = 45;
        sf = VD.SF;
        [b,a] = butter(forder, cutfreq / (sf/2));

        %% Data Allocation
        if strcmp(dom_leg,'right') == 1

            EMG = data_1.AnalogCh.Voltage_1;
            EMGinv = -1*EMG;
            RHEE = VD.RHEE;
            RHEE_filt = filtfilt(b, a, RHEE(:,3));
            [Pksr_f,Locsr_f] = findpeaks(-RHEE_filt,'MinPeakDistance',500,'MinPeakHeight',-80);
            HSlocs = Locsr_f;

        elseif strcmp(dom_leg,'left') == 1

            EMG = data_1.AnalogCh.Voltage_5;
            EMGinv = -1*EMG;
            LHEE = VD.LHEE;
            LHEE_filt = filtfilt(b, a, LHEE(:,3));
            [Pksl_f,Locsl_f] = findpeaks(-LHEE_filt,'MinPeakDistance',500,'MinPeakHeight',-80);
            HSlocs = Locsl_f;

        end

        for i = 1:length(HSlocs)-1
            difference(i) = HSlocs(i+1)- HSlocs(i); % # Data points between strides
        end
        Median_d = median(difference);   % Median value of difference in strides


        %% Checking the Detection of HS and Trigger
        %
        %                 figure;  plot(-LHEE_filt); title('Locsl_f, pksl_f plotted on -LHEE_filt')
        %                 hold on; plot(Locsl_f,Pksl_f,'or');
        %                 figure;  plot(-RHEE_filt); title('Locsr_f, pksr_f plotted on -RHEE_filt')
        %                 hold on; plot(Locsr_f,Pksr_f,'or');
        %                 figure; plot(Trigger); title('Locs_t, pks_t on Trriger');
        %                 hold on; plot(Locs_t,Pks_t,'or');
        %                 figure; plot(Data.EMG.Voltage_1); title('Locs_t, pks_t on Trriger');
        %                 hold on; plot(Locs_t,Data.EMG.Voltage_1(Locs_t),'or');

        try
            %% Peaks between HS and Midstance, Prefered stimulus point as it gives out the maximum H-reflex.
            [HSMidST] = HSMidSTExtraction(Locs_t,HSlocs,Median_d,StimulusIntensity,EMG,data_1.AnalogCh.sf/data_1.VD.SF);

            %% Peaks between Midstance and HO
            [MidSTHO] = MidSTHOExtraction(Locs_t,HSlocs,Median_d,StimulusIntensity,EMG,data_1.AnalogCh.sf/data_1.VD.SF);

            [HMSummary] = HMConcatenate(HSMidST,MidSTHO,Names);
        catch
            fprintf("%s Does not have valid data",Name)
        end
        %% Data Structure
        comd = [Name,'.',Condition,'.HSMidST = HSMidST'];
        eval(comd);

        comd = [Name,'.',Condition, '.MidSTHO = MidSTHO'];
        eval(comd);

        comd = [Name,'.',Condition,'.Summary = HMSummary'];
        eval(comd);

        comd = [Name '= orderfields(', Name ');'];
        eval(comd);

    end

    datasave = fullfile(destPath, Name);
    save(datasave,Name,'-v7.3');
    clearvars -except TestPath1 part filesep subjectloop subjectsNames
end
