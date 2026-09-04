function CoMplotting(VD,LTO5_Kin_2, RTO5_Kin_2,LeftHSLocs,RightHSLocs,Patientname,Currentcondition,startAna,endAna)

%% get treadmill velocity in Y-direction to add to the data

stfr = 100;
endfr = 260;
frdiff = endfr-stfr;
sf = VD.SF;

for i=1:length(LeftHSLocs)-2
    speed_l_Y(i) = (LTO5_Kin_2(LeftHSLocs(i)+endfr,2)-LTO5_Kin_2(LeftHSLocs(i)+stfr,2))/((1/sf)*frdiff);
    speed_r_Y(i) = (RTO5_Kin_2(RightHSLocs(i)+endfr,2)-RTO5_Kin_2(RightHSLocs(i)+stfr,2))/((1/sf)*frdiff);
end

treadmill_speed_left_Y = mean(speed_l_Y);
treadmill_speed_right_Y = mean(speed_r_Y);

tm_v_Y = (treadmill_speed_left_Y + treadmill_speed_right_Y)/2;

%% adding the velocity to the markers, in all 3 axes
Markers = {'RTO1';'RTO5';'RHEE';'LTO1';'LTO5';'LHEE';...
    'RLMA';'RMMA';'LLMA';'LMMA';...
    'SACR';'RPSI';'RTMS';'RASI';'LASI';'LTMS';'LPSI'};

for j=1:length(Markers)
    Markername = Markers(j);
    Markername = cell2mat(Markername);
    Marker = VD.(Markername);

    forder = 4;
    cutfreq = 4;
    [b,a] = butter(forder, cutfreq / (sf/2));
    Marker_v = filtfilt(b, a, Marker);

    % adding to Y-axis, negative because have to add it in opposite direction
    for k=1:length(Marker)
        % milimeters/frame
        mmpf_Y = (1/sf)*tm_v_Y;
        Marker_v(k,2) = Marker(k,2)-mmpf_Y*k;
    end
    comd = ['vel_added_data.', Currentcondition, '.VD.(Markername) = Marker_v;'];
    eval(comd);
end

%% clear old data and prepare new with velocity added on markers
VD_2 = vel_added_data.(Currentcondition).VD;

%% Calculate CoM position

SACR = VD_2.SACR;
LPSI = VD_2.LPSI;
RPSI = VD_2.RPSI;
LTMS = VD_2.LTMS;
RTMS = VD_2.RTMS;
LASI = VD_2.LASI;
RASI = VD_2.RASI;

% position
for k=1:3
    for m=1:length(SACR)
        CoM(m,k) = mean([SACR(m,k),...
            LPSI(m,k),...
            RPSI(m,k),...
            LTMS(m,k),...
            RTMS(m,k),...
            LASI(m,k),...
            RASI(m,k)]);
    end
end

allCoM_pos_2.(Patientname).(Currentcondition).CoM = CoM;

% velocity
for k=1:3
    for m=1:length(CoM)-1
        CoM_v(m,k) = (CoM(m+1,k)-CoM(m,k))./(1/sf);
    end
end

allCoM_vel_2.(Patientname).(Currentcondition).CoM_v = CoM_v;

%% Calculate XCoM

% Heel Marker
LHEE_Kin_2 = VD_2.LHEE(startAna:endAna,:);  % LHEE for Heel strike
RHEE_Kin_2 = VD_2.RHEE(startAna:endAna,:);

% Toe Markers to get the outside margin
LTO5_Kin_2 = VD_2.LTO5(startAna:endAna,:);  % LTO5 for ML
RTO5_Kin_2 = VD_2.RTO5(startAna:endAna,:);

LTO1_Kin_2 = VD_2.LTO1(startAna:endAna,:);  % LTO1 for AP
RTO1_Kin_2 = VD_2.RTO1(startAna:endAna,:);

% Malleoli Marker
LLMA_Kin_2 = VD_2.LLMA(startAna:endAna,:);
RLMA_Kin_2 = VD_2.RLMA(startAna:endAna,:);
LMMA_Kin_2 = VD_2.LMMA(startAna:endAna,:);
RMMA_Kin_2 = VD_2.RMMA(startAna:endAna,:);

for k=1:3
    for m=1:length(LLMA_Kin_2)
        L2MA_Kin_2(m,k) = mean([LLMA_Kin_2(m,k),... % midpoint between the 2 malleoli marker
            LMMA_Kin_2(m,k)]);
        R2MA_Kin_2(m,k) = mean([RLMA_Kin_2(m,k),... % midpoint between the 2 malleoli marker
            RMMA_Kin_2(m,k)]);
    end
end

L2MA_atLHS_2 = L2MA_Kin_2(LeftHSLocs,:);
R2MA_atRHS_2 = R2MA_Kin_2(RightHSLocs,:);

% COM Position
Current_COM_Data_2 = allCoM_pos_2.(Patientname).(Currentcondition).CoM(startAna:endAna,:);
Current_COM_Data_atLHS_2 = Current_COM_Data_2(LeftHSLocs,:);
Current_COM_Data_atRHS_2 = Current_COM_Data_2(RightHSLocs,:);

% COM Velocity Data
Current_COMVelocity_Data_2 = allCoM_vel_2.(Patientname).(Currentcondition).CoM_v(startAna:endAna,:);


[~, Average_PendLeng] = Pendulum_length(Current_COM_Data_atLHS_2,Current_COM_Data_atRHS_2,L2MA_atLHS_2,R2MA_atRHS_2);


for k=1:size(Current_COMVelocity_Data_2,2)
    XCOM(:,k) = Current_COM_Data_2(:,k) + (Current_COMVelocity_Data_2(:,k)./(sqrt((9.81*1000)/Average_PendLeng))); % in mm
end

XCOM_filt = filtfilt(b, a, XCOM);

LH = LHEE_Kin_2;
LH(:,1)=LH(:,1)-200;
LT1=LTO1_Kin_2;
LT1(:,1)=LT1(:,1)-200;
LT5=LTO5_Kin_2;
LT5(:,1)=LT5(:,1)-200;
RH = RHEE_Kin_2;
RH(:,1)=RH(:,1)-200;
RT1=RTO1_Kin_2;
RT1(:,1)=RT1(:,1)-200;
RT5=RTO5_Kin_2;
RT5(:,1)=RT5(:,1)-200;
XCOMnew=XCOM_filt;
XCOMnew(:,1)=XCOMnew(:,1)-200;
COMnew=Current_COM_Data_2;
COMnew(:,1)=COMnew(:,1)-200;

LH = LH/1000;
LT1 = LT1/1000;
LT5 = LT5/1000;
RH = RH/1000;
RT1 = RT1/1000;
RT5 = RT5/1000;
XCOMnew = XCOMnew/1000;
COMnew = COMnew/1000;

%% plot in forward direction

figure('units','normalized','outerposition',[0 0 1 1])
hold on
grid on
xlim([min(-LH(:,1)-50) max(-RH(:,1))+50])

start_frame = 10000;
end_frame = 15000;

plot(-XCOMnew(start_frame:end_frame,1),-XCOMnew(start_frame:end_frame,2),'g','LineWidth',1)
plot(-COMnew(start_frame:end_frame,1),-COMnew(start_frame:end_frame,2),'r','LineWidth',1)

for i = start_frame:end_frame
    for j=1:length(LeftHSLocs)
        if i == LeftHSLocs(j)
            leftfoot = line([-LH(LeftHSLocs(j),1) -LT1(LeftHSLocs(j),1)],...
                [-LH(LeftHSLocs(j),2) -LT1(LeftHSLocs(j),2)+0.06],'Color','b','LineWidth',2);
        end
    end
    for j=1:length(RightHSLocs)
        if i == RightHSLocs(j)
            rightfoot = line([-RH(RightHSLocs(j),1) -RT1(RightHSLocs(j),1)],...
                [-RH(RightHSLocs(j),2) -RT1(RightHSLocs(j),2)+0.06],'Color','m','LineWidth',2);
        end
    end
end

legend('XCoM','CoM')

%% plot in sideway direction

figure('units','normalized','outerposition',[0 0 1 1])
hold on
grid on
ylim([min(-LH(:,1)-0.05) max(-RH(:,1))+0.05])

start_frame = 10000;
end_frame = 15000;

plot(-XCOMnew(start_frame:end_frame,2),-XCOMnew(start_frame:end_frame,1),'g','LineWidth',1)
plot(-COMnew(start_frame:end_frame,2),-COMnew(start_frame:end_frame,1),'r','LineWidth',1)

for i = start_frame:end_frame
    for j=1:length(LeftHSLocs)
        if i == LeftHSLocs(j)
            leftfoot = line([-LH(LeftHSLocs(j),2) -LT1(LeftHSLocs(j),2)+0.06],...
                [-LH(LeftHSLocs(j),1) -LH(LeftHSLocs(j),1)],'Color','b','LineWidth',8);
        end
    end
    for j=1:length(RightHSLocs)
        if i == RightHSLocs(j)
            rightfoot = line([-RH(RightHSLocs(j),2) -RT1(RightHSLocs(j),2)+0.06],...
                [-RH(RightHSLocs(j),1) -RH(RightHSLocs(j),1)],'Color','m','LineWidth',8);
        end
    end
end

legend('XCoM','CoM')

%% plot sideway with actual foot size

figure('units','normalized','outerposition',[0 0 1 1])
hold on
grid on
ylim([min(-LH(:,1)-0.05) max(-RH(:,1))+0.05])

start_frame = 10000;
end_frame = 15000;

plot(-XCOMnew(start_frame:end_frame,2),-XCOMnew(start_frame:end_frame,1),'g','LineWidth',1)
plot(-COMnew(start_frame:end_frame,2),-COMnew(start_frame:end_frame,1),'r','LineWidth',1)

for i = start_frame:end_frame
    for j=1:length(LeftHSLocs)
        if i == LeftHSLocs(j)
            line([-LH(LeftHSLocs(j),2) -LT1(LeftHSLocs(j),2)],...
                [-LH(LeftHSLocs(j),1) -LT1(LeftHSLocs(j),1)],'Color','b');
            line([-LT1(LeftHSLocs(j),2) -LT5(LeftHSLocs(j),2)],...
                [-LT1(LeftHSLocs(j),1) -LT5(LeftHSLocs(j),1)],'Color','b');
            line([-LT5(LeftHSLocs(j),2) -LH(LeftHSLocs(j),2)],...
                [-LT5(LeftHSLocs(j),1) -LH(LeftHSLocs(j),1)],'Color','b');
        end
    end
    for j=1:length(RightHSLocs)
        if i == RightHSLocs(j)
            line([-RH(RightHSLocs(j),2) -RT1(RightHSLocs(j),2)],...
                [-RH(RightHSLocs(j),1) -RT1(RightHSLocs(j),1)],'Color','m');
            line([-RT1(RightHSLocs(j),2) -RT5(RightHSLocs(j),2)],...
                [-RT1(RightHSLocs(j),1) -RT5(RightHSLocs(j),1)],'Color','m');
            line([-RT5(RightHSLocs(j),2) -RH(RightHSLocs(j),2)],...
                [-RT5(RightHSLocs(j),1) -RH(RightHSLocs(j),1)],'Color','m');
        end
    end
end

legend('XCoM','CoM')
xlabel('Length [m]')
ylabel('Width [m]')

%% plot forward with actual foot size

figure('units','normalized','outerposition',[0 0 1 1])
hold on
grid on
xlim([min(-LH(:,1)-1) max(-RH(:,1))+1])

start_frame = 10000;
end_frame = 15000;

plot(-XCOMnew(start_frame:end_frame,1),-XCOMnew(start_frame:end_frame,2),'g','LineWidth',1)
plot(-COMnew(start_frame:end_frame,1),-COMnew(start_frame:end_frame,2),'r','LineWidth',1)

for i = start_frame:end_frame
    for j=1:length(LeftHSLocs)
        if i == LeftHSLocs(j)
            line([-LH(LeftHSLocs(j),1) -LT1(LeftHSLocs(j),1)],...
                [-LH(LeftHSLocs(j),2) -LT1(LeftHSLocs(j),2)],'Color','b');
            line([-LT1(LeftHSLocs(j),1) -LT5(LeftHSLocs(j),1)],...
                [-LT1(LeftHSLocs(j),2) -LT5(LeftHSLocs(j),2)],'Color','b');
            line([-LT5(LeftHSLocs(j),1) -LH(LeftHSLocs(j),1)],...
                [-LT5(LeftHSLocs(j),2) -LH(LeftHSLocs(j),2)],'Color','b');
        end
    end
    for j=1:length(RightHSLocs)
        if i == RightHSLocs(j)
            line([-RH(RightHSLocs(j),1) -RT1(RightHSLocs(j),1)],...
                [-RH(RightHSLocs(j),2) -RT1(RightHSLocs(j),2)],'Color','m');
            line([-RT1(RightHSLocs(j),1) -RT5(RightHSLocs(j),1)],...
                [-RT1(RightHSLocs(j),2) -RT5(RightHSLocs(j),2)],'Color','m');
            line([-RT5(RightHSLocs(j),1) -RH(RightHSLocs(j),1)],...
                [-RT5(RightHSLocs(j),2) -RH(RightHSLocs(j),2)],'Color','m');
        end
    end
end

legend('XCoM','CoM')
xlabel('Width [m]')
ylabel('Length [m]')
end
% %% plotting the pelvis and CoM
%
% figure('units','normalized','outerposition',[0 0 1 1])
% hold on
% grid on
% dist_X = mean((-RTMS(:,1))-(-LTMS(:,1)))/5;
% xlim([min(-LTMS(:,1))-dist_X max(-RTMS(:,1))+dist_X])
%
% for i=95000:1000000
%
%     p1 = plot(-CoM(i,1),-CoM(i,2),'*r');
%     p2 = plot([-LPSI(i,1) -SACR(i,1)],[-LPSI(i,2) -SACR(i,2)],'b');
%     p3 = plot([-SACR(i,1) -RPSI(i,1)],[-SACR(i,2) -RPSI(i,2)],'b');
%     p4 = plot([-RPSI(i,1) -RTMS(i,1)],[-RPSI(i,2) -RTMS(i,2)],'b');
%     p5 = plot([-RTMS(i,1) -RASI(i,1)],[-RTMS(i,2) -RASI(i,2)],'b');
%     p6 = plot([-RASI(i,1) -LASI(i,1)],[-RASI(i,2) -LASI(i,2)],'b');
%     p7 = plot([-LASI(i,1) -LTMS(i,1)],[-LASI(i,2) -LTMS(i,2)],'b');
%     p8 = plot([-LTMS(i,1) -LPSI(i,1)],[-LTMS(i,2) -LPSI(i,2)],'b');
%
%     ylim([-CoM(i,2)-(tm_v_Y*.16) -CoM(i,2)+(tm_v_Y*.16)])
%     text_1=text(min(-LTMS(:,1)),-CoM(i,2)+(tm_v_Y*0.15),strcat('t=',num2str(i/sf),' s'));
%
%     pause(0.000000001)
%     set(text_1,'visible','off')
%
%     delete(p1);delete(p2);delete(p3);delete(p4);
%     delete(p5);delete(p6);delete(p7);delete(p8);
%
% end
%
% text_1=text(min(-XCOM_filt(:,1))+5,-CoM(i,2)+(tm_v_Y*0.15),strcat('t=',num2str(i/sf),' s'));
