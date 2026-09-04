function [HStoMidST] = HSMidSTExtraction(T_locs,HSlocs,Stride,StimInt,EMG,ratio)

EMGinv = -1 * EMG;
T_RSloc = round(T_locs/ratio);

LocFF = round(0.01*Stride);    % HS
LocMidST = round(0.25*Stride); % Midstance

Intro = 300; % 100ms of Background EMG
Delay = 190; % 50ms of Delsys delay
MW=60;  % length of M-Window
HW=120; % length of H-Window
%
% Intro = 150; % Background EMG
% Delay = 180; % Delay from EMG sensor to Vicon (~46ms)
% MW=60;       % length of M-Window
% HW=120;      % length of H-Window
t=1;

for i = 1:length(T_RSloc)

    for m = 1:length(HSlocs)

        if (abs(T_RSloc(i)-HSlocs(m))>LocFF) && (abs(T_RSloc(i)-HSlocs(m))<LocMidST) == 1
            HS_MidST(t,1) = i;                      % the i'th trigger
            HS_MidST(t,2) = m;                      % the m'th heel strike
            HS_MidST(t,3) = T_locs(i);              % where the i'th trigger happens
            HS_MidST(t,4) = StimInt(T_locs(i));     % Stimulus Intensity
            HS_MidST(t,5) = HSlocs(m);              % where the m'th heel strike happens
            HS_MidST(t,6) = abs(T_RSloc(i)-HSlocs(m));   % frames between Trigger and HS
            t = t + 1;
        end
    end
end

k=1;
if exist('HS_MidST') == 1
    for i = 1:length(HS_MidST(:,1))

        % Baseline EMG
        [Pks_B_max,Locs_B_max] = findpeaks(EMG(((HS_MidST(i,5)*6)-Intro):((HS_MidST(i,5)*6)-1)),'SortStr','descend');
        [Pks_B_min,Locs_B_min] = findpeaks(EMGinv(((HS_MidST(i,5)*6)-Intro):((HS_MidST(i,5)*6)-1)),'SortStr','descend');
        %                 AmplitudeBaseline = Pks_B_max(1) - (-1*Pks_B_min(1)); % maximale Amplitude im Fenster

        % M Wave Extraction
        [Pks_M_max,Locs_M_max] = findpeaks(EMG((HS_MidST(i,3)+Delay):(HS_MidST(i,3)+MW+Delay)),'SortStr','descend');
        [Pks_M_min,Locs_M_min] = findpeaks(EMGinv((HS_MidST(i,3)+Delay):(HS_MidST(i,3)+MW+Delay)),'SortStr','descend');
        %                 AmplitudeMWave = Pks_M_max(1) - (-1*Pks_M_min(1)); % maximale Amplitude im Fenster

        % H Wave Extraction
        [Pks_H_max,Locs_H_max] = findpeaks(EMG((HS_MidST(i,3)+MW+Delay):(HS_MidST(i,3)+MW+HW+Delay)),'SortStr','descend');
        [Pks_H_min,Locs_H_min] = findpeaks(EMGinv((HS_MidST(i,3)+MW+Delay):(HS_MidST(i,3)+MW+HW+Delay)),'SortStr','descend');
        %                 AmplitudeHWave = Pks_H_max(1) - (-1*Pks_H_min(1)); % maximale Amplitude im Fenster

        if isempty(Pks_B_max) == 1 || isempty(Pks_B_min) == 1
            AmplitudeBaseline = HS_MidST(i-1,1);
        else
            AmplitudeBaseline = Pks_B_max(1) - (-1*Pks_B_min(1));
        end

        if isempty(Pks_M_max) == 1 || isempty(Pks_M_min) == 1
            AmplitudeMWave = FF_MidST_HO(i-1,2);
        else
            AmplitudeMWave = Pks_M_max(1) - (-1*Pks_M_min(1));
        end

        if isempty(Pks_H_max) == 1 || isempty(Pks_H_min) == 1
            AmplitudeHWave = HS_MidST(i-1,3);
        else
            AmplitudeHWave = Pks_H_max(1) - (-1*Pks_H_min(1));
        end

        % Summary
        HSMid_ST(i,1) = AmplitudeBaseline;
        HSMid_ST(i,2) = AmplitudeMWave;
        HSMid_ST(i,3) = AmplitudeHWave;
        HSMid_ST(i,4) = HS_MidST(i,4); % Stimulus Intensity
        HSMid_ST(i,5) = round(HS_MidST(i,3)/6); % where the i'th trigger happens
        HSMid_ST(i,6) = HS_MidST(i,5); % where the m'th heel strike happens
        HSMid_ST(i,7) = HS_MidST(i,6); % frames between Trigger and HS
        distance(i,1) = round((Locs_H_min(1)-Locs_H_max(1))/6);   % #frames between max and min

        if distance(i,1)<1 || distance(i,1)>4
            todelete(k) = i;
            k=k+1;
        end

        clearvars Pks_B_max Pks_B_min Pks_M_max Pks_M_min Pks_H_max Pks_H_min...
            Locs_B_max Locs_M_max Locs_M_max Locs_M_min Locs_H_max Locs_H_min...
            AmplitudeBaseline AmplitudeMWave AmplitudeHWave
    end

    if exist('todelete') == 1
        HSMid_ST(todelete,:) = [];
    end

    HStoMidST.Baseline = HSMid_ST(:,1);
    HStoMidST.MWave    = HSMid_ST(:,2);
    HStoMidST.HWave    = HSMid_ST(:,3);
    HStoMidST.StimInt  = HSMid_ST(:,4)*1000;         % Stimulus Intensity
    HStoMidST.LocT     = HSMid_ST(:,5);              % where the i'th trigger happens
    HStoMidST.LocHS    = HSMid_ST(:,6);              % where the i'th HS happens
    HStoMidST.PerGait  = (HSMid_ST(:,7)/Stride)*100; % Determination of Gait Cycle

else
    HStoMidST = 0;
end
