% Plots the trajectory of CoM, XCoM
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
destPath = [TestPath1,'Results',pathCompSep,'MoS'];

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
        VD_tm_Y_v = Sub.(Name).(condition{l}).KinematicData_tm_Y_v;
        VD = Sub.(Name).(condition{l}).KinematicData;

%         if length(VD_tm_Y_v.RTO1) > 150000
%             Useful_Length = 150000;
%         else
%             Useful_Length = 30000;
%         end
        %% Data allocation

        LeftHSLocs  = Sub.(Name).(condition{l}).GaitEvents.HSleftlocs;
        LeftTOLocs  = Sub.(Name).(condition{l}).GaitEvents.TOleftlocs;
        RightHSLocs = Sub.(Name).(condition{l}).GaitEvents.HSrightlocs;
        RightTOLocs = Sub.(Name).(condition{l}).GaitEvents.TOrightlocs;
        sf          = Sub.(Name).(condition{l}).KinematicData.SF;

        %         %% Determine Useful Length of the Data
        %         % Use only middle 5 minutes or 150'000 data points here
        %
        %         OriginalLength_Data = length(VD_tm_Y_v.LTO3);
        %         LengthFactor = round((OriginalLength_Data - Useful_Length)/2);
        %
        %         startAna = LengthFactor+1;
        %         endAna = Useful_Length+LengthFactor;
        %
        %         LeftHSLocs(LeftHSLocs<startAna) = [];
        %         LeftHSLocs(LeftHSLocs>endAna) = [];
        %
        %         RightHSLocs(RightHSLocs<startAna) = [];
        %         RightHSLocs(RightHSLocs>endAna) = [];
        %
        %         LeftHSLocs  = LeftHSLocs - startAna;
        %         RightHSLocs = RightHSLocs - startAna;
        %
        %         % If the new location is exactly the starting point of the series
        %         % Very miniature arrangement to avoid zeros
        %
        %         if LeftHSLocs(1) == 0
        %             LeftHSLocs(1) = LeftHSLocs(1)+1;
        %         elseif RightHSLocs(1) == 0
        %             RightHSLocs(1) = RightHSLocs(1)+1;
        %         end
        startAna = 1;
        endAna = length(VD.RTO1);
        endAna_tm_Y_v        = length(VD_tm_Y_v.RTO1);

        %% Calculate XCoM - treadmill
        % Heel Marker
        LHEE_Kin_tm_Y_v = VD_tm_Y_v.LHEE(startAna:endAna_tm_Y_v,:);  % LHEE for Heel strike
        RHEE_Kin_tm_Y_v = VD_tm_Y_v.RHEE(startAna:endAna_tm_Y_v,:);
        LHEE_Kin        = VD.LHEE(startAna:endAna,:);  % LHEE for Heel strike
        RHEE_Kin        = VD.RHEE(startAna:endAna,:);

        LTO3_Kin_tm_Y_v = VD_tm_Y_v.LTO3(startAna:endAna_tm_Y_v,:);
        RTO3_Kin_tm_Y_v = VD_tm_Y_v.RTO3(startAna:endAna_tm_Y_v,:);
        LTO3_Kin        = VD.LTO3(startAna:endAna,:);
        RTO3_Kin        = VD.RTO3(startAna:endAna,:);

        LTO5_Kin_tm_Y_v = VD_tm_Y_v.LTO5(startAna:endAna_tm_Y_v,:);  % LTO5 for ML
        RTO5_Kin_tm_Y_v = VD_tm_Y_v.RTO5(startAna:endAna_tm_Y_v,:);
        LTO5_Kin        = VD.LTO5(startAna:endAna,:);
        RTO5_Kin        = VD.RTO5(startAna:endAna,:);

        LTO1_Kin_tm_Y_v = VD_tm_Y_v.LTO1(startAna:endAna_tm_Y_v,:);  % LTO1 for AP
        RTO1_Kin_tm_Y_v = VD_tm_Y_v.RTO1(startAna:endAna_tm_Y_v,:);
        LTO1_Kin        = VD.LTO1(startAna:endAna,:);
        RTO1_Kin        = VD.RTO1(startAna:endAna,:);

        % Malleoli Marker
        LLMA_Kin_tm_Y_v  = VD_tm_Y_v.LLMA(startAna:endAna_tm_Y_v,:);
        RLMA_Kin_tm_Y_v  = VD_tm_Y_v.RLMA(startAna:endAna_tm_Y_v,:);
        LMMA_Kin_tm_Y_v  = VD_tm_Y_v.LMMA(startAna:endAna_tm_Y_v,:);
        RMMA_Kin_tm_Y_v  = VD_tm_Y_v.RMMA(startAna:endAna_tm_Y_v,:);

        % Malleoli Marker
        LLMA_Kin  = VD.LLMA(startAna:endAna,:);
        RLMA_Kin  = VD.RLMA(startAna:endAna,:);
        LMMA_Kin  = VD.LMMA(startAna:endAna,:);
        RMMA_Kin  = VD.RMMA(startAna:endAna,:);

        for k=1:3
            for m=1:length(LLMA_Kin_tm_Y_v )
                L2MA_Kin_tm_Y_v(m,k) = mean([LLMA_Kin_tm_Y_v(m,k),... % midpoint between the 2 malleoli marker
                    LMMA_Kin_tm_Y_v(m,k)]);
                R2MA_Kin_tm_Y_v(m,k) = mean([RLMA_Kin_tm_Y_v(m,k),... % midpoint between the 2 malleoli marker
                    RMMA_Kin_tm_Y_v(m,k)]);
            end
        end

        for k=1:3
            for m=1:length(LLMA_Kin)
                L2MA_Kin(m,k) = mean([LLMA_Kin(m,k),... % midpoint between the 2 malleoli marker
                    LMMA_Kin(m,k)]);
                R2MA_Kin(m,k) = mean([RLMA_Kin(m,k),... % midpoint between the 2 malleoli marker
                    RMMA_Kin(m,k)]);
            end
        end

        L2MA_atLHS_tm_Y_v = L2MA_Kin_tm_Y_v(LeftHSLocs,:);
        R2MA_atRHS_tm_Y_v = R2MA_Kin_tm_Y_v(RightHSLocs,:);

        L2MA_atLHS = L2MA_Kin(LeftHSLocs,:);
        R2MA_atRHS = R2MA_Kin(RightHSLocs,:);

        LHEE_atLHS = LHEE_Kin(LeftHSLocs,:);
        RHEE_atRHS= RHEE_Kin(RightHSLocs,:);

        LHEE_atLHS_tm_Y_v = LHEE_Kin_tm_Y_v(LeftHSLocs,:);
        RHEE_atRHS_tm_Y_v = RHEE_Kin_tm_Y_v(RightHSLocs,:);

        LTO5_atLHS = LTO5_Kin(LeftHSLocs,:);
        RTO5_atRHS = RTO5_Kin(RightHSLocs,:);

        LTO5_atLHS_tm_Y_v  = LTO5_Kin_tm_Y_v(LeftHSLocs,:);
        RTO5_atRHS_tm_Y_v  = RTO5_Kin_tm_Y_v(RightHSLocs,:);

        LTO3_atLHS = LTO3_Kin(LeftHSLocs,:);
        RTO3_atRHS = RTO3_Kin(RightHSLocs,:);

        LTO3_atLHS_tm_Y_v  = LTO3_Kin_tm_Y_v(LeftHSLocs,:);
        RTO3_atRHS_tm_Y_v  = RTO3_Kin_tm_Y_v(RightHSLocs,:);

        LTO1_atLHS = LTO1_Kin(LeftHSLocs,:);
        RTO1_atRHS = RTO1_Kin(RightHSLocs,:);

        LTO1_atLHS_tm_Y_v  = LTO1_Kin_tm_Y_v(LeftHSLocs,:);
        RTO1_atRHS_tm_Y_v  = RTO1_Kin_tm_Y_v(RightHSLocs,:);

        LLMA_atLHS = LLMA_Kin(LeftHSLocs,:);
        RLMA_atRHS = RLMA_Kin(RightHSLocs,:);

        LLMA_atLHS_tm_Y_v = LLMA_Kin_tm_Y_v(LeftHSLocs,:);
        RLMA_atRHS_tm_Y_v = RLMA_Kin_tm_Y_v(RightHSLocs,:);

        % COM Position
        Current_COM_Data = allCoM_pos.(Name).(condition{l}).CoM(startAna:endAna,:);
        Current_COMVelocity_Data = allCoM_vel.(Name).(condition{l}).CoM_v(startAna:endAna_tm_Y_v-1,:);

        % COM - treadmill included
        Current_COM_Data_tm_Y_v = allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y(startAna:endAna,:);
        Current_COMVelocity_Data_tm_Y_v = allCoM_vel.(Name).(condition{l}).CoM_v_tm_v_Y(startAna:endAna_tm_Y_v-1,:);

        Current_COM_Data_atLHS = Current_COM_Data(LeftHSLocs,:);
        Current_COM_Data_atRHS = Current_COM_Data(RightHSLocs,:);

        Current_COM_Data_atLHS_tm_Y_v = Current_COM_Data_tm_Y_v(LeftHSLocs,:);
        Current_COM_Data_atRHS_tm_Y_v = Current_COM_Data_tm_Y_v(RightHSLocs,:);

        for k= 1:size(Current_COMVelocity_Data,2)
            leftlegdif(:,k) = abs(LHEE_atLHS(:,k) - RHEE_Kin_tm_Y_v(LeftHSLocs,k));
            rightlegdif(:,k) = abs(RHEE_atRHS(:,k)- LHEE_Kin_tm_Y_v(RightHSLocs,k));
        end

        %% Pendulum Length
        % from Malleolus
        PendLeng_Left_M = sqrt((Current_COM_Data_atLHS(:,1) - L2MA_atLHS(:,1)).^2+...
            abs((Current_COM_Data_atLHS(:,2) - L2MA_atLHS(:,2))).^2+...
            (Current_COM_Data_atLHS(:,3) - L2MA_atLHS(:,3)).^2);

        PendLeng_Right_M = sqrt((Current_COM_Data_atRHS(:,1) - R2MA_atRHS(:,1)).^2+...
            (Current_COM_Data_atRHS(:,2) - R2MA_atRHS(:,2)).^2+...
            (Current_COM_Data_atRHS(:,3) - R2MA_atRHS(:,3)).^2);

        Average_PendLeng_Left  =  mean(PendLeng_Left_M);
        Average_PendLeng_Right =  mean(PendLeng_Right_M);

        Pendulumlength.(Name).(condition{l}).Left  = Average_PendLeng_Left;
        Pendulumlength.(Name).(condition{l}).Right = Average_PendLeng_Right;

        % Calculate XCOM in the medio-lateral direction
        PendLeng = [Average_PendLeng_Left, Average_PendLeng_Right];
        Average_PendLeng = mean(PendLeng);

        for k=1:size(Current_COMVelocity_Data,2)
            XCOM(:,k) = Current_COM_Data(1:size(Current_COMVelocity_Data,1),k) + (Current_COMVelocity_Data(:,k)./(sqrt((9.81*1000)/Average_PendLeng))); % in mm
        end

        % XCOM at Heel Strikes
        XCOM_atLHS = XCOM(LeftHSLocs,:);
        XCOM_atRHS = XCOM(RightHSLocs,:);

        % Margin of Stability Calculation
        allMoS.(Name).(condition{l}).MOS_Left(:,1)  = XCOM(:,1) - LTO5_Kin(1:size(XCOM,1),1);
        allMoS.(Name).(condition{l}).MOS_Left(:,2)  = XCOM(:,2) - LTO1_Kin(1:size(XCOM,1),2);

        allMoS.(Name).(condition{l}).MOS_Right(:,1) = XCOM(:,1) - RTO5_Kin(1:size(XCOM,1),1);
        allMoS.(Name).(condition{l}).MOS_Right(:,2) = XCOM(:,2) - RTO1_Kin(1:size(XCOM,1),2);

        allMoS.(Name).(condition{l}).MOS_Left_atLHS(:,1)  = XCOM_atLHS(:,1) - LTO5_atLHS(:,1);
        allMoS.(Name).(condition{l}).MOS_Left_atLHS(:,2)  = XCOM_atLHS(:,2) - LTO1_atLHS(:,2);

        allMoS.(Name).(condition{l}).MOS_Right_atRHS(:,1) = XCOM_atRHS(:,1) - RTO5_atRHS(:,1);
        allMoS.(Name).(condition{l}).MOS_Right_atRHS(:,2) = XCOM_atRHS(:,2) - RTO1_atRHS(:,2);


        %% Pendulum Length_treadmill
        % from Malleolus
        PendLeng_Left_M_tm_Y_v = sqrt((Current_COM_Data_atLHS_tm_Y_v(:,1) - L2MA_atLHS_tm_Y_v(:,1)).^2+...
            abs((Current_COM_Data_atLHS_tm_Y_v(:,2) - L2MA_atLHS_tm_Y_v(:,2))).^2+...
            (Current_COM_Data_atLHS_tm_Y_v(:,3) - L2MA_atLHS_tm_Y_v(:,3)).^2);

        PendLeng_Right_M_tm_Y_v = sqrt((Current_COM_Data_atRHS_tm_Y_v(:,1) - R2MA_atRHS_tm_Y_v(:,1)).^2+...
            (Current_COM_Data_atRHS_tm_Y_v(:,2) - R2MA_atRHS_tm_Y_v(:,2)).^2+...
            (Current_COM_Data_atRHS_tm_Y_v(:,3) - R2MA_atRHS_tm_Y_v(:,3)).^2);

        Average_PendLeng_Left_tm_Y_v  =  mean(PendLeng_Left_M_tm_Y_v);
        Average_PendLeng_Right_tm_Y_v =  mean(PendLeng_Right_M_tm_Y_v);

        Pendulumlength.(Name).(condition{l}).Left_tm_Y_v  = Average_PendLeng_Left_tm_Y_v;
        Pendulumlength.(Name).(condition{l}).Right_tm_Y_v = Average_PendLeng_Right_tm_Y_v;

        % Calculate XCOM in the medio-lateral direction
        PendLeng_tm_Y_v = [Average_PendLeng_Left_tm_Y_v, Average_PendLeng_Right_tm_Y_v];
        Average_PendLeng_tm_Y_v = mean(PendLeng_tm_Y_v);

        for k=1:size(Current_COMVelocity_Data_tm_Y_v,2)
            XCOM_tm_Y_v(:,k) = Current_COM_Data_tm_Y_v(1:size(Current_COMVelocity_Data_tm_Y_v,1),k) + (Current_COMVelocity_Data_tm_Y_v(:,k)./(sqrt((9.81*1000)/Average_PendLeng_tm_Y_v))); % in mm
        end

        % XCOM at Heel Strikes
        XCOM_atLHS_tm_Y_v = XCOM_tm_Y_v(LeftHSLocs,:);
        XCOM_atRHS_tm_Y_v = XCOM_tm_Y_v(RightHSLocs,:);

        % Margin of Stability Calculation
        allMoS.(Name).(condition{l}).MOS_Left_tm_Y_v(:,1)  = XCOM_tm_Y_v(:,1) - LTO5_Kin(1:size(XCOM,1),1);
        allMoS.(Name).(condition{l}).MOS_Left_tm_Y_v(:,2)  = XCOM_tm_Y_v(:,2) - LTO1_Kin(1:size(XCOM,1),2);

        allMoS.(Name).(condition{l}).MOS_Right_tm_Y_v(:,1) = XCOM_tm_Y_v(:,1) - RTO5_Kin(1:size(XCOM,1),1);
        allMoS.(Name).(condition{l}).MOS_Right_tm_Y_v(:,2) = XCOM_tm_Y_v(:,2) - RTO1_Kin(1:size(XCOM,1),2);

        allMoS.(Name).(condition{l}).MOS_Left_atLHS_tm_Y_v(:,1)  = XCOM_atLHS_tm_Y_v(:,1) - LTO5_atLHS(:,1);
        allMoS.(Name).(condition{l}).MOS_Left_atLHS_tm_Y_v(:,2)  = XCOM_atLHS_tm_Y_v(:,2) - LTO1_atLHS(:,2);

        allMoS.(Name).(condition{l}).MOS_Right_atRHS_tm_Y_v(:,1) = XCOM_atRHS_tm_Y_v(:,1) - RTO5_atRHS(:,1);
        allMoS.(Name).(condition{l}).MOS_Right_atRHS_tm_Y_v(:,2) = XCOM_atRHS_tm_Y_v(:,2) - RTO1_atRHS(:,2);

        %                 %% plotting in AP
        %
        %                 LH  = LHEE_Kin/1000;
        %                 LT3 = LTO3_Kin/1000;
        %                 LT5 = LTO5_Kin/1000;
        %                 RH  = RHEE_Kin/1000;
        %                 RT3 = RTO3_Kin/1000;
        %                 RT5 = RTO3_Kin/1000;
        %                 XCOMnew = XCOM/1000;
        %                 COMnew = Current_COM_Data/1000;
        %
        %                 h1=figure('units','normalized','outerposition',[0 0 1 1]);
        %                 hold on
        %                 grid on
        %                 xlim([min(-LH(:,1)-1) max(-RH(:,1))+1])
        %
        %                 start_frame = 10000;
        %                 end_frame = 15000;
        %
        %                 ax1 = plot(-XCOMnew(start_frame:end_frame,1),-XCOMnew(start_frame:end_frame,2),'g','LineWidth',1);
        %                 ax2 = plot(-COMnew(start_frame:end_frame,1),-COMnew(start_frame:end_frame,2),'r','LineWidth',1);
        %
        %                 for i = start_frame:end_frame
        %                     for j=1:length(LeftHSLocs)
        %                         if i == LeftHSLocs(j)
        %                             leftfoot = line([-LH(LeftHSLocs(j),1) -LH(LeftHSLocs(j),1)],...
        %                                 [-LH(LeftHSLocs(j),2) -LT3(LeftHSLocs(j),2)],'Color','b','LineWidth',10);
        %                         end
        %                     end
        %                     for j=1:length(RightHSLocs)
        %                         if i == RightHSLocs(j)
        %                             rightfoot = line([-RH(RightHSLocs(j),1) -RH(RightHSLocs(j),1)],...
        %                                 [-RH(RightHSLocs(j),2) -RT3(RightHSLocs(j),2)],'Color','m','LineWidth',10);
        %                         end
        %                     end
        %                 end
        %                 legend([ax1 ax2 leftfoot rightfoot],{'XCoM','CoM','leftfoot','rightfoot'},'FontSize' ,12);
        %                 xlabel('Width [m]','FontSize' ,16)
        %                 ylabel('Length [m]','FontSize' ,16)
        %                 title_name = ['\fontsize{16}Walking (TOP View)  ','{\color{magenta}Condition} = ',(condition)];
        %                 save_name = [(condition)];
        %                 title(title_name,'Color','blue');
        %                 savePlot = fullfile(destPath,[save_name,'.pdf']);
        %                 saveas(h1,savePlot);
        %                 close(h1);

        %% Orientation correction
        mpd = 0.8 * sf;
        [~, loc_max_right] = findpeaks(RTO3_Kin(:,2), 'minpeakdistance', mpd);
        [~, loc_min_right] = findpeaks(-RTO3_Kin(:,2),'minpeakdistance', mpd);
        [~,  loc_max_left]  = findpeaks(LTO3_Kin(:,2),  'minpeakdistance', mpd);
        [~,  loc_min_left]  = findpeaks(-LTO3_Kin(:,2), 'minpeakdistance', mpd);

        start_min_point = find(loc_min_right> loc_max_right(1));
        loc_min_right = loc_min_right(start_min_point(1):end);
        start_min_point = find(loc_min_left> loc_max_left(1));
        loc_min_left = loc_min_left(start_min_point(1):end);

        min_right = min(length(loc_max_right),length(loc_min_right));
        min_left = min(length(loc_max_left),length(loc_min_left));

        % setup the sequence: determine the leading leg
        try
            for  i=1:min(min_right,min_left)-10
                idx     = find(loc_max_right > loc_min_right(i));

                X_left(i)  = LTO3_Kin(floor(loc_max_left(idx(1))-0.*sf),1)-LTO3_Kin(floor(loc_min_left(i)+0.15*sf),1);
                X_right(i) = RTO3_Kin(floor(loc_max_right(idx(1))-0.*sf),1)-RTO3_Kin(floor(loc_min_right(i)+0.15*sf),1);
                Y_left(i)  = LTO5_Kin(floor(loc_max_left(idx(1))-0.*sf),2)-LTO5_Kin(floor(loc_min_left(i)+0.15*sf),2);
                Y_right(i) = RTO5_Kin(floor(loc_max_right(idx(1))-0.*sf),2)-RTO5_Kin(floor(loc_min_right(i)+0.15*sf),2);
                Z_left(i)  = LTO3_Kin(floor(loc_max_left(idx(1))-0.*sf),3)-LTO3_Kin(floor(loc_min_left(i)+0.15*sf),3);
                Z_right(i) = RTO3_Kin(floor(loc_max_right(idx(1))-0.*sf),3)-RTO3_Kin(floor(loc_min_right(i)+0.15*sf),3);
                left_vector(i,1)=X_left(i); left_vector(i,2)=Y_left(i); left_vector(i,3)=Z_left(i);
                right_vector(i,1)=X_right(i); right_vector(i,2)=Y_right(i); right_vector(i,3)=Z_right(i);
            end
        catch
            fprintf("%s %s \n", Name, condition{l});
        end

        X_left_mean = mean(X_left);
        X_right_mean = mean(X_right);
        Y_left_mean = mean(Y_left);
        Y_right_mean = mean(Y_right);
        Z_left_mean = mean(Z_left);
        Z_right_mean = mean(Z_right);

        vec1 = [(X_left_mean+X_right_mean)/2;(Y_left_mean+Y_right_mean)/2;(Z_left_mean+Z_right_mean)/2];
        vec2 = [0;1;0];

        vector.vec1(:,subjectloop) = vec1;
        vector.components(1,subjectloop) = X_left_mean;
        vector.components(2,subjectloop) = X_right_mean;
        vector.components(3,subjectloop) = Y_left_mean;
        vector.components(4,subjectloop) = Y_right_mean;
        vector.components(5,subjectloop) = Z_left_mean;
        vector.components(6,subjectloop) = Z_right_mean;

        % match the size of the matrices
        minLength = min([length(XCOM_atRHS(:,1)), length(XCOM_atLHS(:,1)), length(leftlegdif(:,1)), length(rightlegdif(2:end,1))]);

        XCOM_atRHS = XCOM_atRHS(1:minLength,:);
        XCOM_atRHS_tm_Y_v = XCOM_atRHS_tm_Y_v(1:minLength,:);
        rightlegdif = rightlegdif(1:minLength,:);

        XCOM_atLHS = XCOM_atLHS(1:minLength,:);
        XCOM_atLHS_tm_Y_v = XCOM_atLHS_tm_Y_v(1:minLength,:);
        leftlegdif = leftlegdif(1:minLength,:);

        [leadLeg, indleadLeg] = min([LeftHSLocs(1) RightHSLocs(1)]);

        [R_m] = getRotM(vec1,vec2);

        %% Margin of Stability Calculation
        XCOM_atLHS_rot = R_m*XCOM_atLHS';
        XCOM_atLHS_rot = XCOM_atLHS_rot';
        LTO5_atLHS_rot = R_m*LTO5_atLHS';
        LTO5_atLHS_rot = LTO5_atLHS_rot';
        LTO1_atLHS_rot = R_m*LTO1_atLHS';
        LTO1_atLHS_rot = LTO1_atLHS_rot';
        LHEE_atLHS_rot = R_m*LHEE_atLHS';
        LHEE_atLHS_rot = LHEE_atLHS_rot';

        XCOM_atRHS_rot = R_m*XCOM_atRHS';
        XCOM_atRHS_rot = XCOM_atRHS_rot';
        RTO5_atRHS_rot = R_m*RTO5_atRHS';
        RTO5_atRHS_rot = RTO5_atRHS_rot';
        RTO1_atRHS_rot = R_m*RTO1_atRHS';
        RTO1_atRHS_rot = RTO1_atRHS_rot';
        RHEE_atRHS_rot = R_m*RHEE_atRHS';
        RHEE_atRHS_rot = RHEE_atRHS_rot';

        MOS_Left_rot(:,1)  = XCOM_atLHS_rot(:,1) - LTO5_atLHS_rot(size(XCOM_atLHS_rot,1),1);
        MOS_Left_rot(:,2)  = XCOM_atLHS_rot(:,2) - LTO1_atLHS_rot(size(XCOM_atLHS_rot,1),2);
        MOS_Left_rot(:,3)  = XCOM_atLHS_rot(:,3) - LHEE_atLHS_rot(size(XCOM_atLHS_rot,1),3);

        MOS_Right_rot(:,1) = XCOM_atRHS_rot(:,1) - RTO5_atRHS_rot(size(XCOM_atRHS_rot,1),1);
        MOS_Right_rot(:,2) = XCOM_atRHS_rot(:,2) - RTO1_atRHS_rot(size(XCOM_atRHS_rot,1),2);
        MOS_Right_rot(:,3) = XCOM_atRHS_rot(:,3) - RHEE_atRHS_rot(size(XCOM_atRHS_rot,1),3);

        allMoS.(Name).(condition{l}).MOS_Left_rot  = MOS_Left_rot;
        allMoS.(Name).(condition{l}).MOS_Right_rot = MOS_Right_rot;

        %% Margin of Stability Calculation - treadmill
        XCOM_atLHS_rot_tm_Y_v = R_m*XCOM_atLHS_tm_Y_v';
        XCOM_atLHS_rot_tm_Y_v = XCOM_atLHS_rot_tm_Y_v';
        LTO5_atLHS_rot_tm_Y_v = R_m*LTO5_atLHS_tm_Y_v';
        LTO5_atLHS_rot_tm_Y_v = LTO5_atLHS_rot_tm_Y_v';
        LTO1_atLHS_rot_tm_Y_v = R_m*LTO1_atLHS_tm_Y_v';
        LTO1_atLHS_rot_tm_Y_v = LTO1_atLHS_rot_tm_Y_v';
        LHEE_atLHS_rot_tm_Y_v = R_m*LHEE_atLHS_tm_Y_v';
        LHEE_atLHS_rot_tm_Y_v = LHEE_atLHS_rot_tm_Y_v';

        XCOM_atRHS_rot_tm_Y_v = R_m*XCOM_atRHS_tm_Y_v';
        XCOM_atRHS_rot_tm_Y_v = XCOM_atRHS_rot_tm_Y_v';
        RTO5_atRHS_rot_tm_Y_v = R_m*RTO5_atRHS_tm_Y_v';
        RTO5_atRHS_rot_tm_Y_v = RTO5_atRHS_rot_tm_Y_v';
        RTO1_atRHS_rot_tm_Y_v = R_m*RTO1_atRHS_tm_Y_v';
        RTO1_atRHS_rot_tm_Y_v = RTO1_atRHS_rot_tm_Y_v';
        RHEE_atRHS_rot_tm_Y_v = R_m*RHEE_atRHS_tm_Y_v';
        RHEE_atRHS_rot_tm_Y_v = RHEE_atRHS_rot_tm_Y_v';

        MOS_Left_rot_tm_Y_v(:,1)  = XCOM_atLHS_rot_tm_Y_v(:,1) - LTO5_atLHS_rot_tm_Y_v(size(XCOM_atLHS_rot_tm_Y_v,1),1);
        MOS_Left_rot_tm_Y_v(:,2)  = XCOM_atLHS_rot_tm_Y_v(:,2) - LTO1_atLHS_rot_tm_Y_v(size(XCOM_atLHS_rot_tm_Y_v,1),2);
        MOS_Left_rot_tm_Y_v(:,3)  = XCOM_atLHS_rot_tm_Y_v(:,3) - LHEE_atLHS_rot_tm_Y_v(size(XCOM_atLHS_rot_tm_Y_v,1),3);

        MOS_Right_rot_tm_Y_v(:,1) = XCOM_atRHS_rot_tm_Y_v(:,1) - RTO5_atRHS_rot_tm_Y_v(size(XCOM_atRHS_rot_tm_Y_v,1),1);
        MOS_Right_rot_tm_Y_v(:,2) = XCOM_atRHS_rot_tm_Y_v(:,2) - RTO1_atRHS_rot_tm_Y_v(size(XCOM_atRHS_rot_tm_Y_v,1),2);
        MOS_Right_rot_tm_Y_v(:,3) = XCOM_atRHS_rot_tm_Y_v(:,3) - RHEE_atRHS_rot_tm_Y_v(size(XCOM_atRHS_rot_tm_Y_v,1),3);

        allMoS.(Name).(condition{l}).MOS_Left_rot_tm_Y_v  = MOS_Left_rot_tm_Y_v;
        allMoS.(Name).(condition{l}).MOS_Right_rot_tm_Y_v = MOS_Right_rot_tm_Y_v;

        if indleadLeg == 1 % i.e. left leg is leading
            %% regression with step width and step length and their first difference for the lagging (right) leg

            footfallbalancePred_right = [ones(size(XCOM_atRHS(2:end,1))) leftlegdif(2:end,1) leftlegdif(2:end,2) rightlegdif(2:end,1) rightlegdif(2:end,2) ...
                diff(leftlegdif(:,1)) diff(leftlegdif(:,2)) diff(rightlegdif(:,1)) diff(rightlegdif(:,2))];
            balanceResponse_ML_atRHS = XCOM_atRHS(2:end,3);
            [coeff_ML_atRHS,coeff_int_ML_atRHS,resid_ML_atRHS,resid_int_ML_atRHS,stats_ML_atRHS] = regress(balanceResponse_ML_atRHS, footfallbalancePred_right);

            balanceResponse_AP_atRHS = XCOM_atRHS(2:end,1);
            [coeff_AP_atRHS,coeff_int_AP_atRHS,resid_AP_atRHS,resid_int_AP_atRHS,stats_AP_atRHS] = regress(balanceResponse_AP_atRHS, footfallbalancePred_right);

            %% regression with step width and step length and their first difference for the lagging (right) leg filtered data
            % filtered
            balanceResponse_ML_tm_Y_v_atRHS = XCOM_atRHS_tm_Y_v(2:end,3);
            [coeff_ML_tm_Y_v_atRHS,coeff_int_ML_tm_Y_v_atRHS,resid_ML_tm_Y_v_atRHS,resid_int_ML_tm_Y_v_atRHS,stats_ML_tm_Y_v_atRHS] = regress(balanceResponse_ML_tm_Y_v_atRHS, footfallbalancePred_right);

            balanceResponse_AP_tm_Y_v_atRHS = XCOM_atRHS_tm_Y_v(2:end,1);
            [coeff_AP_tm_Y_v_atRHS,coeff_int_AP_tm_Y_v_atRHS,resid_AP_tm_Y_v_atRHS,resid_int_AP_tm_Y_v_atRHS,stats_AP_tm_Y_v_atRHS] = regress(balanceResponse_AP_tm_Y_v_atRHS, footfallbalancePred_right);
            %% regression with step width and step length and their first and second difference for the lagging (right) leg

            footfallbalancePred_acc_right = [ones(size(XCOM_atRHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
                diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2)) ...
                diff(diff(leftlegdif(:,1))) diff(diff(leftlegdif(:,2))) diff(diff(rightlegdif(:,1))) diff(diff(rightlegdif(:,2)))];

            balanceResponse_ML_atRHS_acc = XCOM_atRHS(3:end,3);
            [coeff_ML_atRHS_acc,coeff_int_ML_atRHS_acc,resid_ML_atRHS_acc,resid_int_ML_atRHS_acc,stats_ML_atRHS_acc] = regress(balanceResponse_ML_atRHS_acc, footfallbalancePred_acc_right);

            balanceResponse_AP_atRHS_acc = XCOM_atRHS(3:end,1);
            [coeff_AP_atRHS_acc,coeff_int_AP_atRHS_acc,resid_AP_atRHS_acc,resid_int_AP_atRHS_acc,stats_AP_atRHS_acc] = regress(balanceResponse_AP_atRHS_acc, footfallbalancePred_acc_right);
            %% regression with step width and step length and their second difference for the lagging (right) leg: filtered data
            % filtered
            balanceResponse_ML_tm_Y_v_atRHS_acc = XCOM_atRHS_tm_Y_v(3:end,3);
            [coeff_ML_tm_Y_v_atRHS_acc,coeff_int_ML_tm_Y_v_atRHS_acc,resid_ML_tm_Y_v_atRHS_acc,resid_int_ML_tm_Y_v_atRHS_acc,stats_ML_tm_Y_v_atRHS_acc] = regress(balanceResponse_ML_tm_Y_v_atRHS_acc, footfallbalancePred_acc_right);

            balanceResponse_AP_tm_Y_v_atRHS_acc = XCOM_atRHS_tm_Y_v(3:end,1);
            [coeff_AP_tm_Y_v_atRHS_acc,coeff_int_AP_tm_Y_v_atRHS_acc,resid_AP_tm_Y_v_atRHS_acc,resid_int_AP_tm_Y_v_atRHS_acc,stats_AP_tm_Y_v_atRHS_acc] = regress(balanceResponse_AP_tm_Y_v_atRHS_acc, footfallbalancePred_acc_right);
            %% regression with step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg

            footfallbalancePred_left = [ones(size(XCOM_atLHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(2:end-1,1) rightlegdif(2:end-1,2) ...
                diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(1:end-1,1)) diff(rightlegdif(1:end-1,2))];

            balanceResponse_ML_atLHS = XCOM_atLHS(3:end,3);
            [coeff_ML_atLHS,coeff_int_ML_atLHS,resid_ML_atLHS,resid_int_ML_atLHS,stats_ML_atLHS] = regress(balanceResponse_ML_atLHS, footfallbalancePred_left);

            balanceResponse_AP_atLHS = XCOM_atLHS(3:end,1);
            [coeff_AP_atLHS,coeff_int_AP_atLHS,resid_AP_atLHS,resid_int_AP_atLHS,stats_AP_atLHS] = regress(balanceResponse_AP_atLHS, footfallbalancePred_left);

            %% regression with step width and step length and their first difference - filtered data: Shift the sequence at the start of the matrix for the leading leg
            % filtered
            balanceResponse_ML_tm_Y_v_atLHS = XCOM_atLHS_tm_Y_v(3:end,3);
            [coeff_ML_tm_Y_v_atLHS,coeff_int_ML_tm_Y_v_atLHS,resid_ML_tm_Y_v_atLHS,resid_int_ML_tm_Y_v_atLHS,stats_ML_tm_Y_v_atLHS] = regress(balanceResponse_ML_tm_Y_v_atLHS, footfallbalancePred_left);

            balanceResponse_AP_tm_Y_v_atLHS = XCOM_atLHS_tm_Y_v(3:end,1);
            [coeff_AP_tm_Y_v_atLHS,coeff_int_AP_tm_Y_v_atLHS,resid_AP_tm_Y_v_atLHS,resid_int_AP_tm_Y_v_atLHS,stats_AP_tm_Y_v_atLHS] = regress(balanceResponse_AP_tm_Y_v_atLHS, footfallbalancePred_left);

            %% regression with step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg

            footfallbalancePred_acc_left = [ones(size(XCOM_atLHS(4:end,1))) leftlegdif(4:end,1) leftlegdif(4:end,2) rightlegdif(3:end-1,1) rightlegdif(3:end-1,2) ...
                diff(leftlegdif(3:end,1)) diff(leftlegdif(3:end,2)) diff(rightlegdif(2:end-1,1)) diff(rightlegdif(2:end-1,2)) ...
                diff(diff(leftlegdif(2:end,1))) diff(diff(leftlegdif(2:end,2))) diff(diff(rightlegdif(1:end-1,1))) diff(diff(rightlegdif(1:end-1,2)))];

            balanceResponse_ML_atLHS_acc = XCOM_atLHS(4:end,3);
            [coeff_ML_atLHS_acc,coeff_int_ML_atLHS_acc,resid_ML_atLHS_acc,resid_int_ML_atLHS_acc,stats_ML_atLHS_acc] = regress(balanceResponse_ML_atLHS_acc, footfallbalancePred_acc_left);

            balanceResponse_AP_atLHS_acc = XCOM_atLHS(4:end,1);
            [coeff_AP_atLHS_acc,coeff_int_AP_atLHS_acc,resid_AP_atLHS_acc,resid_int_AP_atLHS_acc,stats_AP_atLHS_acc] = regress(balanceResponse_AP_atLHS_acc, footfallbalancePred_acc_left);

            %% filtered data: regression with step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg

            balanceResponse_ML_tm_Y_v_atLHS_acc = XCOM_atLHS_tm_Y_v(4:end,3);
            [coeff_ML_tm_Y_v_atLHS_acc,coeff_int_ML_tm_Y_v_atLHS_acc,resid_ML_tm_Y_v_atLHS_acc,resid_int_ML_tm_Y_v_atLHS_acc,stats_ML_tm_Y_v_atLHS_acc] = regress(balanceResponse_ML_tm_Y_v_atLHS_acc, footfallbalancePred_acc_left);

            balanceResponse_AP_tm_Y_v_atLHS_acc = XCOM_atLHS_tm_Y_v(4:end,1);
            [coeff_AP_tm_Y_v_atLHS_acc,coeff_int_AP_tm_Y_v_atLHS_acc,resid_AP_tm_Y_v_atLHS_acc,resid_int_AP_tm_Y_v_atLHS_acc,stats_AP_tm_Y_v_atLHS_acc] = regress(balanceResponse_AP_tm_Y_v_atLHS_acc, footfallbalancePred_acc_left);

        elseif indleadLeg == 2 % i.e. right leg is leading
            %% regression lagging leg: step width and step length and their first difference - left leg
            footfallbalancePred_left = [ones(size(XCOM_atLHS(2:end,1))) leftlegdif(2:end,1) leftlegdif(2:end,2) rightlegdif(2:end,1) rightlegdif(2:end,2) ...
                diff(leftlegdif(:,1)) diff(leftlegdif(:,2)) diff(rightlegdif(:,1)) diff(rightlegdif(:,2))];

            balanceResponse_ML_atLHS = XCOM_atLHS(2:end,3);
            [coeff_ML_atLHS,coeff_int_ML_atLHS,resid_ML_atLHS,resid_int_ML_atLHS,stats_ML_atLHS] = regress(balanceResponse_ML_atLHS, footfallbalancePred_left);

            balanceResponse_AP_atLHS = XCOM_atLHS(2:end,1);
            [coeff_AP_atLHS,coeff_int_AP_atLHS,resid_AP_atLHS,resid_int_AP_atLHS,stats_AP_atLHS] = regress(balanceResponse_AP_atLHS, footfallbalancePred_left);

            %% filtered data regression lagging leg: step width and step length and their first difference - left leg
            balanceResponse_ML_tm_Y_v_atLHS = XCOM_atLHS_tm_Y_v(2:end,3);
            [coeff_ML_tm_Y_v_atLHS,coeff_int_ML_tm_Y_v_atLHS,resid_ML_tm_Y_v_atLHS,resid_int_ML_tm_Y_v_atLHS,stats_ML_tm_Y_v_atLHS] = regress(balanceResponse_ML_tm_Y_v_atLHS, footfallbalancePred_left);

            balanceResponse_AP_tm_Y_v_atLHS = XCOM_atLHS_tm_Y_v(2:end,1);
            [coeff_AP_tm_Y_v_atLHS,coeff_int_AP_tm_Y_v_atLHS,resid_AP_tm_Y_v_atLHS,resid_int_AP_tm_Y_v_atLHS,stats_AP_tm_Y_v_atLHS] = regress(balanceResponse_AP_tm_Y_v_atLHS, footfallbalancePred_left);

            %% regression lagging leg: step width and step length and their first and second difference - left leg
            footfallbalancePred_acc_left = [ones(size(XCOM_atLHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
                diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2)) ...
                diff(diff(leftlegdif(:,1))) diff(diff(leftlegdif(:,2))) diff(diff(rightlegdif(:,1))) diff(diff(rightlegdif(:,2)))];

            balanceResponse_ML_atLHS_acc = XCOM_atLHS(3:end,3);
            [coeff_ML_atLHS_acc,coeff_int_ML_atLHS_acc,resid_ML_atLHS_acc,resid_int_ML_atLHS_acc,stats_ML_atLHS_acc] = regress(balanceResponse_ML_atLHS_acc, footfallbalancePred_acc_left);

            balanceResponse_AP_atLHS_acc = XCOM_atLHS(3:end,1);
            [coeff_AP_atLHS_acc,coeff_int_AP_atLHS_acc,resid_AP_atLHS_acc,resid_int_AP_atLHS_acc,stats_AP_atLHS_acc] = regress(balanceResponse_AP_atLHS_acc, footfallbalancePred_acc_left);

            %% filtered data regression lagging leg: step width and step length and their first and second difference - left leg
            balanceResponse_ML_tm_Y_v_atLHS_acc = XCOM_atLHS_tm_Y_v(3:end,3);
            [coeff_ML_tm_Y_v_atLHS_acc,coeff_int_ML_tm_Y_v_atLHS_acc,resid_ML_tm_Y_v_atLHS_acc,resid_int_ML_tm_Y_v_atLHS_acc,stats_ML_tm_Y_v_atLHS_acc] = regress(balanceResponse_ML_tm_Y_v_atLHS_acc, footfallbalancePred_acc_left);

            balanceResponse_AP_tm_Y_v_atLHS_acc = XCOM_atLHS_tm_Y_v(3:end,1);
            [coeff_AP_tm_Y_v_atLHS_acc,coeff_int_AP_tm_Y_v_atLHS_acc,resid_AP_tm_Y_v_atLHS_acc,resid_int_AP_tm_Y_v_atLHS_acc,stats_AP_tm_Y_v_atLHS_acc] = regress(balanceResponse_AP_tm_Y_v_atLHS_acc, footfallbalancePred_acc_left);

            %% regression leading leg: step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg
            footfallbalancePred_right = [ones(size(XCOM_atRHS(3:end,1))) leftlegdif(2:end-1,1) leftlegdif(2:end-1,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
                diff(leftlegdif(1:end-1,1)) diff(leftlegdif(1:end-1,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2))];

            balanceResponse_ML_atRHS = XCOM_atRHS(3:end,3);
            [coeff_ML_atRHS,coeff_int_ML_atRHS,resid_ML_atRHS,resid_int_ML_atRHS,stats_ML_atRHS] = regress(balanceResponse_ML_atRHS, footfallbalancePred_right);

            balanceResponse_AP_atRHS = XCOM_atRHS(3:end,1);
            [coeff_AP_atRHS,coeff_int_AP_atRHS,resid_AP_atRHS,resid_int_AP_atRHS,stats_AP_atRHS] = regress(balanceResponse_AP_atRHS, footfallbalancePred_right);

            %% filtered data regression leading leg: step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg
            balanceResponse_ML_tm_Y_v_atRHS = XCOM_atRHS_tm_Y_v(3:end,3);
            [coeff_ML_tm_Y_v_atRHS,coeff_int_ML_tm_Y_v_atRHS,resid_ML_tm_Y_v_atRHS,resid_int_ML_tm_Y_v_atRHS,stats_ML_tm_Y_v_atRHS] = regress(balanceResponse_ML_tm_Y_v_atRHS, footfallbalancePred_right);

            balanceResponse_AP_tm_Y_v_atRHS = XCOM_atRHS_tm_Y_v(3:end,1);
            [coeff_AP_tm_Y_v_atRHS,coeff_int_AP_tm_Y_v_atRHS,resid_AP_tm_Y_v_atRHS,resid_int_AP_tm_Y_v_atRHS,stats_AP_tm_Y_v_atRHS] = regress(balanceResponse_AP_tm_Y_v_atRHS, footfallbalancePred_right);

            %% regression leading leg: step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg
            footfallbalancePred_acc_right = [ones(size(XCOM_atRHS(4:end,1))) leftlegdif(3:end-1,1) leftlegdif(3:end-1,2) rightlegdif(4:end,1) rightlegdif(4:end,2) ...
                diff(leftlegdif(2:end-1,1)) diff(leftlegdif(2:end-1,2)) diff(rightlegdif(3:end,1)) diff(rightlegdif(3:end,2)) ...
                diff(diff(leftlegdif(1:end-1,1))) diff(diff(leftlegdif(1:end-1,2))) diff(diff(rightlegdif(2:end,1))) diff(diff(rightlegdif(2:end,2)))];

            balanceResponse_ML_atRHS_acc = XCOM_atRHS(4:end,3);
            [coeff_ML_atRHS_acc,coeff_int_ML_atRHS_acc,resid_ML_atRHS_acc,resid_int_ML_atRHS_acc,stats_ML_atRHS_acc] = regress(balanceResponse_ML_atRHS_acc, footfallbalancePred_acc_right);

            balanceResponse_AP_atRHS_acc = XCOM_atRHS(4:end,1);
            [coeff_AP_atRHS_acc,coeff_int_AP_atRHS_acc,resid_AP_atRHS_acc,resid_int_AP_atRHS_acc,stats_AP_atRHS_acc] = regress(balanceResponse_AP_atRHS_acc, footfallbalancePred_acc_right);

            %% filtered data regression leading leg: step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg
            balanceResponse_ML_tm_Y_v_atRHS_acc = XCOM_atRHS_tm_Y_v(4:end,3);
            [coeff_ML_tm_Y_v_atRHS_acc,coeff_int_ML_tm_Y_v_atRHS_acc,resid_ML_tm_Y_v_atRHS_acc,resid_int_ML_tm_Y_v_atRHS_acc,stats_ML_tm_Y_v_atRHS_acc] = regress(balanceResponse_ML_tm_Y_v_atRHS_acc, footfallbalancePred_acc_right);

            balanceResponse_AP_tm_Y_v_atRHS_acc = XCOM_atRHS_tm_Y_v(4:end,1);
            [coeff_AP_tm_Y_v_atRHS_acc,coeff_int_AP_tm_Y_v_atRHS_acc,resid_AP_tm_Y_v_atRHS_acc,resid_int_AP_tm_Y_v_atRHS_acc,stats_AP_tm_Y_v_atRHS_acc] = regress(balanceResponse_AP_tm_Y_v_atRHS_acc, footfallbalancePred_acc_right);

        end

        %% Store the Data
        % Storing results for Acc + filt_XCOM -> AP,ML at LHS and RHS

        % Stats
        PredictionResults.(Name).(condition{l}).AP_LHS.stats = stats_AP_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_RHS.stats = stats_AP_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_LHS.stats = stats_ML_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_RHS.stats = stats_ML_atRHS_acc;

        % Residuals
        PredictionResults.(Name).(condition{l}).AP_LHS.residuals = resid_AP_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_RHS.residuals = resid_AP_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_LHS.residuals = resid_ML_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_RHS.residuals = resid_ML_atRHS_acc;

        % Coefficient Estimates
        PredictionResults.(Name).(condition{l}).AP_LHS.coeffestimates = coeff_AP_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_RHS.coeffestimates = coeff_AP_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_LHS.coeffestimates = coeff_ML_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_RHS.coeffestimates = coeff_ML_atRHS_acc;

        % Coefficient Estimates - 95% Confid Intervals
        PredictionResults.(Name).(condition{l}).AP_LHS.confidintervals = coeff_int_AP_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_RHS.confidintervals = coeff_int_AP_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_LHS.confidintervals = coeff_int_ML_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_RHS.confidintervals = coeff_int_ML_atRHS_acc;

        % rintervals to diagnose outliers
        PredictionResults.(Name).(condition{l}).AP_LHS.rintervals = resid_int_AP_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_RHS.rintervals = resid_int_AP_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_LHS.rintervals = resid_int_ML_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_RHS.rintervals = resid_int_ML_atRHS_acc;

        %% Store the Data
        % Storing results for Acc + filt_XCOM -> AP,ML at LHS and RHS

        % Stats
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_LHS.stats = stats_AP_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_RHS.stats = stats_AP_tm_Y_v_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_LHS.stats = stats_ML_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_RHS.stats = stats_ML_tm_Y_v_atRHS_acc;

        % Residuals
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_LHS.residuals = resid_AP_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_RHS.residuals = resid_AP_tm_Y_v_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_LHS.residuals = resid_ML_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_RHS.residuals = resid_ML_tm_Y_v_atRHS_acc;

        % Coefficient Estimates
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_LHS.coeffestimates = coeff_AP_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_RHS.coeffestimates = coeff_AP_tm_Y_v_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_LHS.coeffestimates = coeff_ML_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_RHS.coeffestimates = coeff_ML_tm_Y_v_atRHS_acc;

        % Coefficient Estimates - 95% Confid Intervals
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_LHS.confidintervals = coeff_int_AP_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_RHS.confidintervals = coeff_int_AP_tm_Y_v_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_LHS.confidintervals = coeff_int_ML_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_RHS.confidintervals = coeff_int_ML_tm_Y_v_atRHS_acc;

        % rintervals to diagnose outliers
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_LHS.rintervals = resid_int_AP_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).AP_tm_Y_v_RHS.rintervals = resid_int_AP_tm_Y_v_atRHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_LHS.rintervals = resid_int_ML_tm_Y_v_atLHS_acc;
        PredictionResults.(Name).(condition{l}).ML_tm_Y_v_RHS.rintervals = resid_int_ML_tm_Y_v_atRHS_acc;

        clearvars -except pathCompSep TestPath1 destPath currentfolder ProcessedData_idx subjectsNames subjectloop temp_dir Vicon_idx...
            temp_dir_vicon DIR_HRXdata ParticpantName Sub filename Name condition allCoM_pos allCoM_vel Pendulumlength allMoS PredictionResults

    end
end

datasave= fullfile(destPath,'allMoS');
save(datasave,'allMoS','-v7.3');
save(fullfile([TestPath1,'Results',pathCompSep,'Gait'],'PredictionResults'),'PredictionResults','-v7.3');
