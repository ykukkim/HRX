% This script calculates Time to Contact (TtC) out of gait data
clear; close; clc;

%% Setting Directory for data
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');

switch ifMac

    case 0
        %         TestPath1   = '/Volumes/Macintosh HD - Data/HRX/ProcessedData/';
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/Data/Processed';
        pathCompSep = '/';

    case 1
        TestPath1    = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
        pathCompSep  = '\';
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
load([[TestPath1,'Results',pathCompSep,'CoM'],pathCompSep,'AllCoM.mat']);
load([[TestPath1,'Results',pathCompSep,'CoM'],pathCompSep,'AllCoM_velocity.mat']);
destPath = [TestPath1,'Results',pathCompSep,'TtC'];


if ~exist(destPath, 'dir')
    mkdir(destPath)
end

%% Load the Data
for subjectloop = 1:length(subjectsNames)

    temp_dir = dir([subjectsNames(subjectloop).folder,pathCompSep,subjectsNames(subjectloop).name,pathCompSep]);
    temp_dir(strncmp({temp_dir.name}, '.', 1)) = [];

    Vicon_idx = find(strcmp({temp_dir.name},'Vicon'));
    temp_dir_vicon = dir([temp_dir(Vicon_idx).folder,pathCompSep,temp_dir(Vicon_idx).name]);
    temp_dir_vicon(strncmp({temp_dir_vicon.name}, '.', 1)) = [];

    DIR_HRXdata = [temp_dir_vicon(1).folder,pathCompSep,'GaitSummary'];
    addpath(genpath(DIR_HRXdata))
    ParticpantName = dir([DIR_HRXdata,pathCompSep, '*.mat']); % Specify filename based on the format /*participant*session*trial*.mat
    ParticpantName(strncmp({ParticpantName.name}, '.', 1)) = [];
    Sub=load([DIR_HRXdata,pathCompSep,ParticpantName.name]);
    filename = ParticpantName(1).name(1:end-4);  % remove the file extensions
    Name = filename(1:7);
    condition = fieldnames(Sub.(Name));

    for l=1:length(condition)

        LTO3        = Sub.(Name).(condition{l}).KinematicData.LTO3;
        RTO3        = Sub.(Name).(condition{l}).KinematicData.RTO3;
        LTO5        = Sub.(Name).(condition{l}).KinematicData.LTO5;
        RTO5        = Sub.(Name).(condition{l}).KinematicData.RTO5;
        RHEE        = Sub.(Name).(condition{l}).KinematicData.RHEE;

        LeftHSLocs  = Sub.(Name).(condition{l}).GaitEvents.HSleftlocs;
        LeftTOLocs  = Sub.(Name).(condition{l}).GaitEvents.TOleftlocs;
        RightHSLocs = Sub.(Name).(condition{l}).GaitEvents.HSrightlocs;
        RightTOLocs = Sub.(Name).(condition{l}).GaitEvents.TOrightlocs;

        sf          = Sub.(Name).(condition{l}).KinematicData.SF;

        % position
        for k=1:3
            for com_idx=1:length(Sub.(Name).(condition{l}).KinematicData.SACR)
                CoM(com_idx,k) = mean([Sub.(Name).(condition{l}).KinematicData.SACR(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.LPSI(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.RPSI(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.LTMS(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.RTMS(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.LASI(com_idx,k),...
                    Sub.(Name).(condition{l}).KinematicData.RASI(com_idx,k)]);
            end
        end

        % velocity
        for k = 1:3
            for i= 1:length(CoM)-1
                RTO3_v(i,k) = (Sub.(Name).(condition{l}).KinematicData_tm_Y_v.RTO3(i+1,k)-Sub.(Name).(condition{l}).KinematicData_tm_Y_v.RTO3(i,k))./(1/sf);
                LTO3_v(i,k) = (Sub.(Name).(condition{l}).KinematicData_tm_Y_v.LTO3(i+1,k)-Sub.(Name).(condition{l}).KinematicData_tm_Y_v.LTO3(i,k))./(1/sf);
            end
        end

        CoM_v = allCoM_vel.(Name).(condition{l}).CoM_v_tm_v_Y;
        RTO3_v = movmean(RTO3_v,1.4*sf);
        LTO3_v = movmean(LTO3_v,1.4*sf);
        CoM_v  = movmean(CoM_v,0.1*sf);

        %% ------------------- Calculate TtC Physical Boundary ------------------------%%
        % Finds the time takes for CoM and swing foot to cross
        % the physical boundary
        % Physcal boundary is defined by TO3 of stance foot at
        % contralateral leg's HS.
        % e.g. LTO3 at RHS is the physical boundary, TtC Swing
        % of the right leg is calculated.
        % x = medio-lateral
        % y = anterior-posterior
        % z = vertical
        size_temp = min(size(RightHSLocs,2),size(RightTOLocs,2));
        try
            for m=1:size_temp-1

                k=1;
                k_a = 1;
                idx               = find(RightHSLocs > RightTOLocs(m)); % Windows between TO to next HS
                uneq_idx_CoM_BP   = find(CoM(RightTOLocs(m):RightHSLocs(idx(1)),2)  >= LTO3(RightTOLocs(m):RightHSLocs(idx(1)),2));
                uneq_idx_Sw_BP    = find(RTO3(RightTOLocs(m):RightHSLocs(idx(1)),2) >= LTO3(RightTOLocs(m):RightHSLocs(idx(1)),2));
                uneq_idx_CoM_AP   = length((RightTOLocs(m)+ uneq_idx_CoM_BP(end)):RightHSLocs(idx(1)));
                ave_swingPhase(m) = length(RightTOLocs(m):RightHSLocs(idx(1)));

                if uneq_idx_CoM_BP(end) > 150 && uneq_idx_CoM_BP(end) < 250 && uneq_idx_CoM_AP(end) < 250
                    for i = RightTOLocs(m):(RightTOLocs(m)+uneq_idx_CoM_BP(end))
                        %% Physical Boundary -> CoM and Swing foot
                        TtC_CoM_BPAP(k,m) = abs(LTO3(i,2) - CoM(i,2))  / CoM_v(i,2);
                        TtC_Sw_BPAP(k,m)  = abs(LTO3(i,2) - RTO3(i,2)) / RTO3_v(i,2);
                        TtC_CoM_BPML(k,m) = abs(LTO3(i,1) - CoM(i,1))  / CoM_v(i,1);
                        k = k + 1;
                    end
                    for i = (RightTOLocs(m)+uneq_idx_CoM_BP(end)):RightHSLocs(idx(1))
                        %% Anticipated Boundary
                        TtC_CoM_APAP(k_a,m)  = abs(RHEE(RightHSLocs(idx(1)),2)  - CoM(i,2))  / CoM_v(i,2);
                        TtC_Sw_APAP(k_a,m)   = abs(RTO3(RightHSLocs(idx(1)),2)  - RTO3(i,2)) / RTO3_v(i,2);
                        TtC_CoM_APML(k_a,m)  = abs(LTO3(RightHSLocs(idx(1)),1)  - CoM(i,1))  / CoM_v(i,1);
                        k_a=k_a+1;
                    end
                    %                         TtC_CoM_APAP(1:length(TtC_CoM_APAP_temp),m) = flip(TtC_CoM_APAP_temp,2);
                    uneq_idx_CoM_bp_total(m) = uneq_idx_CoM_BP(end);
                    uneq_idx_CoM_ap_total(m) = uneq_idx_CoM_AP;
                else
                    for i = RightTOLocs(m):(RightTOLocs(m)+floor(median(uneq_idx_CoM_bp_total(:))))
                        %% Physical Boundary -> CoM and Swing foot
                        TtC_CoM_BPAP(k,m)  = abs(LTO3(i,2)  - CoM(i,2))  / CoM_v(i,2);
                        TtC_Sw_BPAP(k,m)   = abs(LTO3(i,2)  - RTO3(i,2)) / RTO3_v(i,2);
                        TtC_CoM_BPML(k,m)  = abs(LTO3(i,1)  - CoM(i,1))  / CoM_v(i,1);
                        k=k+1;
                    end
                    for i = (RightTOLocs(m)+ floor(median(uneq_idx_CoM_ap_total(:)))): (RightTOLocs(m)+ median(uneq_idx_CoM_ap_total(:)) + ...
                            abs(floor(median(uneq_idx_CoM_ap_total(:)))- floor(median(ave_swingPhase))))
                        %% Anticipated Boundary
                        TtC_CoM_APAP(k_a,m)  = abs(RHEE(RightHSLocs(idx(1)),2)  - CoM(i,2))  / CoM_v(i,2);
                        TtC_Sw_APAP(k_a,m)   = abs(RHEE(RightHSLocs(idx(1)),2)  - RTO3(i,2)) / RTO3_v(i,2);
                        TtC_CoM_APML(k_a,m)  = abs(RTO3(RightHSLocs(idx(1)),1)  - CoM(i,1))  / CoM_v(i,1);
                        k_a = k_a +1;
                    end
                    %                         TtC_CoM_APAP(length(TtC_CoM_APAP_temp),m) = flip(TtC_CoM_APAP_temp,2);
                end
            end

            TtC.(condition{l}).(Name).TtC_CoM_BPAP = TtC_CoM_BPAP;
            TtC.(condition{l}).(Name).TtC_Sw_BPAP  = TtC_Sw_BPAP;
            TtC.(condition{l}).(Name).TtC_CoM_BPML = TtC_CoM_BPML;
            TtC.(condition{l}).(Name).TtC_CoM_APAP = TtC_CoM_APAP;
            TtC.(condition{l}).(Name).TtC_Sw_APAP  = TtC_Sw_APAP;
            TtC.(condition{l}).(Name).TtC_CoM_APML = TtC_CoM_APML;
            TtC.(condition{l}).(Name).length       = ave_swingPhase;

        catch
            disp((m));
            disp((Name));
            disp((condition{l}))
        end

        clear CoM CoM_v RTO3 RTO3_v LTO3 LTO3_v  ave_swingPhase size_temp LeftHSLocs LeftTOLocs RightHSLocs RightTOLocs
    end
end


datasave_Ttc_anticipated= fullfile([destPath,pathCompSep,],'TtC');
save(datasave_Ttc_anticipated,'TtC','-v7.3');
