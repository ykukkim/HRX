%% Concatenation
%% Setting Directory for data
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac or Junk\n');

switch ifMac

    case 0
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

%% Interested Markers

Markers = {'RTO1';'RTO3';'RTO5';'RHEE';'LTO1';'LTO3';'LTO5';'LHEE';...
    'RLMA';'RMMA';'LLMA';'LMMA';...
    'SACR';'RPSI';'RTMS';'RASI';'LASI';'LTMS';'LPSI'};

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
    Sub = load([DIR_HRXdata,pathCompSep,ParticpantName.name]);
    filename = ParticpantName(1).name(1:end-4);  % remove the file extensions
    Name = filename(1:7);
    condition = fieldnames(Sub.(Name));

    for l= 1:length(condition)
        if (condition{l} ~= "recru_1") && (strcmp(filename,'RENI_11_har20_1') == 0)...
                && (strcmp(filename,'GASA_84_normg_1') == 0)

            % Data Assignments
            sf   = Sub.(Name).(condition{l}).KinematicData.SF;
            VD = Sub.(Name).(condition{l}).KinematicData;

            % get treadmill velocity in Y-direction to add to the data
            [VD_tmvy] = f_approxVelocity_treadmill(Sub.(Name).(condition{l}).KinematicData,Markers);

            comd = [Name,'.',condition{l},' = Sub.(Name).(condition{l});'];
            eval(comd);

            comd = [Name,'.',condition{l},'.KinematicData_tm_Y_v = VD_tmvy;'];
            eval(comd);

            % Calculate CoM position and velocity
            % position
            for k=1:3
                for m=1:length(VD.SACR)
                    CoM(m,k) = mean([VD.SACR(m,k),...
                        VD.LPSI(m,k),...
                        VD.RPSI(m,k),...
                        VD.LTMS(m,k),...
                        VD.RTMS(m,k),...
                        VD.LASI(m,k),...
                        VD.RASI(m,k)]);
                end
            end
            allCoM_pos.(Name).(condition{l}).CoM = CoM;

            % position
            for k=1:3
                for m=1:length(VD_tmvy.SACR)
                    CoM_treadmill(m,k) = mean([VD_tmvy.SACR(m,k),...
                        VD_tmvy.LPSI(m,k),...
                        VD_tmvy.RPSI(m,k),...
                        VD_tmvy.LTMS(m,k),...
                        VD_tmvy.RTMS(m,k),...
                        VD_tmvy.LASI(m,k),...
                        VD_tmvy.RASI(m,k)]);
                end
            end
            allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y = CoM_treadmill;

            % velocity
            for k=1:3
                for m=1:length(allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y)-1
                    CoM_v(m,k) = (allCoM_pos.(Name).(condition{l}).CoM(m+1,k)-allCoM_pos.(Name).(condition{l}).CoM(m,k))./(1/sf);
                end
            end

            allCoM_vel.(Name).(condition{l}).CoM_v = CoM_v;


            % velocity
            for k=1:3
                for m=1:length(allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y)-1
                    CoM_v_treadmill(m,k) = (allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y(m+1,k)-allCoM_pos.(Name).(condition{l}).CoM_tm_v_Y(m,k))./(1/sf);
                end
            end

            allCoM_vel.(Name).(condition{l}).CoM_v_tm_v_Y = CoM_v_treadmill;

            clear VD_tmvy m CoM_treadmill CoM_v_treadmill CoM CoM_v
        end
    end

    datasave= fullfile(DIR_HRXdata,Name);
    save(datasave,Name,'-v7.3');
end

destPath= [TestPath1,pathCompSep,'Results',pathCompSep,'CoM'];

if ~exist(destPath,'dir')
    mkdir(destPath)
end

datasave_CoM= fullfile(destPath,'AllCoM');
datasave_CoM_vel= fullfile(destPath,'AllCoM_velocity');
save(datasave_CoM,'allCoM_pos','-v7.3');
save(datasave_CoM_vel,'allCoM_vel','-v7.3');
