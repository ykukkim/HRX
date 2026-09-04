function[LHEE_atLHS,LTO1_atLHS,LTO3_atLHS,LTO5_atLHS,L2MA_atLHS,...
    RHEE_atRHS,RTO1_atRHS,RTO3_atRHS,RTO5_atRHS,R2MA_atRHS,...
    CoM_atLHS,CoM_atRHS,VCoM_atLHS,VCoM_atRHS,...
    allCoM_pos,allCoM_vel,LeftHSLocs,RightHSLocs,LeftTOLocs,RightTOLocs,VD] = filter_markers(Data,Patientname,Currentcondition)

forder = 4;
cutfreq = 45;
sf = Data.(Patientname).(Currentcondition).KinematicData.SF;
[b,a] = butter(forder, cutfreq / (sf/2));

VD =  Data.(Patientname).(Currentcondition).KinematicData;
Markers = {'RTO1';'RTO3';'RTO5';'RHEE';'LTO1';'LTO3';'LTO5';'LHEE';...
    'RLMA';'RMMA';'LLMA';'LMMA';...
    'SACR';'RPSI';'RTMS';'RASI';'LASI';'LTMS';'LPSI'};

for j=1:length(Markers)

    Markername = Markers(j);
    Markername = cell2mat(Markername);
    Marker_v = filtfilt(b,a, VD.(Markername));
    comd = ['vel_added_data.', (Currentcondition), '.VD.(Markername) = Marker_v;'];
    eval(comd);
end

LeftHSLocs = Data.(Patientname).(Currentcondition).GaitEvents.HSleftlocs';
RightHSLocs = Data.(Patientname).(Currentcondition).GaitEvents.HSrightlocs';
LeftTOLocs = Data.(Patientname).(Currentcondition).GaitEvents.TOleftlocs';
RightTOLocs = Data.(Patientname).(Currentcondition).GaitEvents.TOrightlocs';

%% get treadmill velocity in Y-direction to add to the data
stfr = 100;
endfr = 260;
frdiff = endfr-stfr;
clear VD;
VD = vel_added_data.(Currentcondition).VD;

for i=1:length(LeftHSLocs)-2
    speed_l_Y(i) = (VD.LTO5(LeftHSLocs(i)+endfr,2)-VD.LTO5(LeftHSLocs(i)+stfr,2))/((1/sf)*frdiff);
    speed_r_Y(i) = (VD.RTO5(RightHSLocs(i)+endfr,2)-VD.RTO5(RightHSLocs(i)+stfr,2))/((1/sf)*frdiff);
end

treadmill_speed_left_Y = mean(speed_l_Y);
treadmill_speed_right_Y = mean(speed_r_Y);

tm_v_Y = (treadmill_speed_left_Y + treadmill_speed_right_Y)/2;

%% adding the velocity to the markers, in all 3 axes

for j=1:length(Markers)

    Markername = Markers(j);
    Markername = cell2mat(Markername);
    Marker = VD.(Markername);

    % adding to Y-axis, negative because have to add it in opposite direction
    for k=1:length(Marker)
        % milimeters/frame
        mmpf_Y = (1/sf)*tm_v_Y;
        Marker_v(k,2) = (Marker(k,2)-mmpf_Y*k)*-1;
        Marker_v(:,1) = Marker(:,1);
        Marker_v(:,3) = Marker(:,3);

    end
    comd = ['vel_added_data.', (Currentcondition), '.VD.(Markername) = Marker_v;'];
    eval(comd);
end

%% clear old data and prepare new

clear VD
VD = vel_added_data. (Currentcondition).VD;

%% Calculate CoM position and velocity

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

% velocity
for k=1:3
    for m=1:length(CoM)-1
        CoM_v(m,k) = (CoM(m+1,k)-CoM(m,k))./(1/sf);
    end
end

allCoM_pos.(Patientname).(Currentcondition).CoM = CoM;

allCoM_vel.(Patientname).(Currentcondition).CoM_v = CoM_v;


%% Heel Marker &  Toe Markers to get the outside margin &
% Malleoli Marker

for k=1:3
    for m=1:length(VD.LLMA)
        VD.L2MA(m,k) = mean([VD.LLMA(m,k),... % midpoint between the 2 malleoli marker
            VD.LMMA(m,k)]);
        VD.R2MA(m,k) = mean([VD.RLMA(m,k),... % midpoint between the 2 malleoli marker
            VD.RMMA(m,k)]);
    end
end

LHEE_atLHS = VD.LHEE(LeftHSLocs,:);
RHEE_atRHS = VD.RHEE(RightHSLocs,:);

LTO1_atLHS = VD.LTO1(LeftHSLocs,:);
RTO1_atRHS = VD.RTO1(RightHSLocs,:);

LTO3_atLHS = VD.LTO3(LeftHSLocs,:);
RTO3_atRHS = VD.RTO3(RightHSLocs,:);

LTO5_atLHS = VD.LTO5(LeftHSLocs,:);
RTO5_atRHS = VD.RTO5(RightHSLocs,:);

L2MA_atLHS = VD.L2MA(LeftHSLocs,:);
R2MA_atRHS = VD.R2MA(RightHSLocs,:);

CoM_atLHS = allCoM_pos.(Patientname).(Currentcondition).CoM(LeftHSLocs,:);
CoM_atRHS = allCoM_pos.(Patientname).(Currentcondition).CoM(RightHSLocs,:);

VCoM_atLHS = allCoM_vel.(Patientname).(Currentcondition).CoM_v(LeftHSLocs,:);
VCoM_atRHS = allCoM_vel.(Patientname).(Currentcondition).CoM_v(RightHSLocs,:);

end
