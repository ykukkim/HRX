function [MidStancetoHO] = MidSTHOExtraction(T_locs,HSlocs,Stride,StimInt,EMG,ratio)

EMGinv = -1 * EMG;
T_RSloc = round(T_locs/ratio);

MidSTLoc = round(0.25*Stride); % Midstance
HoLoc = round(0.55*Stride);     % Heel Off

Intro = 300; % 100ms of Background EMG
Delay = 190; % 50ms of Delsys delay
MW=60;  % length of M-Window
HW=120; % length of H-Window

t = 1;
for i = 1:length(T_RSloc)
    for m = 1:length(HSlocs)
        if (abs(T_RSloc(i)-HSlocs(m))>=MidSTLoc) && (abs(T_RSloc(i)-HSlocs(m))<HoLoc) == 1
            MidST_HO(t,1) = i;                 % the i'th trigger
            MidST_HO(t,2) = m;                 % the m'th heel strike
            MidST_HO(t,3) = T_locs(i);          % where the i'th trigger happens
            MidST_HO(t,4) = StimInt(T_locs(i)); % Stimulus Intensity
            MidST_HO(t,5) = HSlocs(m);         % where the m'th heel strike happens
            MidST_HO(t,6) = abs(T_RSloc(i)-HSlocs(m)); % frames between
            t = t + 1;
        end
    end
end

k=1;
if exist('MidST_HO') == 1

    for i = 1:length(MidST_HO(:,1))

        % Baseline EMG
        [Pks_B_max,Locs_B_max] = findpeaks(EMG(((MidST_HO(i,5)*6)-Intro):(((MidST_HO(i,5)*6)-1))),'SortStr','descend');
        [Pks_B_min,Locs_B_min] = findpeaks(EMGinv(((MidST_HO(i,5)*6)-Intro):(((MidST_HO(i,5)*6)-1))),'SortStr','descend');

        % M Wave Extraction
        [Pks_M_max,Locs_M_max] = findpeaks(EMG((MidST_HO(i,3)+Delay):(MidST_HO(i,3)+MW+Delay)),'SortStr','descend');
        [Pks_M_min,Locs_M_min] = findpeaks(EMGinv((MidST_HO(i,3)+Delay):(MidST_HO(i,3)+MW+Delay)),'SortStr','descend');

        % H Wave Extraction
        [Pks_H_max,Locs_H_max] = findpeaks(EMG((MidST_HO(i,3)+MW+Delay):(MidST_HO(i,3)+MW+HW+Delay)),'SortStr','descend');
        [Pks_H_min,Locs_H_min] = findpeaks(EMGinv((MidST_HO(i,3)+MW+Delay):(MidST_HO(i,3)+MW+HW+Delay)),'SortStr','descend');

        if isempty(Pks_B_max) == 1 || isempty(Pks_B_min) == 1
            AmplitudeBaseline = Mid_ST_HO(i-1,1);
        else
            AmplitudeBaseline = Pks_B_max(1) - (-1*Pks_B_min(1));
        end
        if isempty(Pks_M_max) == 1 || isempty(Pks_M_min) == 1
            AmplitudeMWave = Mid_ST_HO(i-1,2);
        else
            AmplitudeMWave = Pks_M_max(1) - (-1*Pks_M_min(1));
        end
        if isempty(Pks_H_max) == 1 || isempty(Pks_H_min) == 1
            AmplitudeHWave = Mid_ST_HO(i-1,3);
        else
            AmplitudeHWave = Pks_H_max(1) - (-1*Pks_H_min(1));
        end

        % Summary
        Mid_ST_HO(i,1) = AmplitudeBaseline;
        Mid_ST_HO(i,2) = AmplitudeMWave;
        Mid_ST_HO(i,3) = AmplitudeHWave;
        Mid_ST_HO(i,4) = MidST_HO(i,4);
        Mid_ST_HO(i,5) = round(MidST_HO(i,3)/6); % where the i'th trigger happens
        Mid_ST_HO(i,6) = MidST_HO(i,5); % where the m'th heel strike happens
        Mid_ST_HO(i,7) = MidST_HO(i,6); % frames between Trigger and HS
        distance(i,1) = round((Locs_H_min(1)-Locs_H_max(1))/6);

        if distance(i,1)<1 || distance(i,1)>4
            todelete(k) = i;
            k=k+1;
        end

        clearvars Pks_B_max Pks_B_min Pks_M_max Pks_M_min Pks_H_max Pks_H_min...
            Locs_B_max Locs_M_max Locs_M_max Locs_M_min Locs_H_max Locs_H_min...
            AmplitudeBaseline AmplitudeMWave AmplitudeHWave
    end

    MidStancetoHO.Baseline = Mid_ST_HO(:,1);
    MidStancetoHO.MWave    = Mid_ST_HO(:,2);
    MidStancetoHO.HWave    = Mid_ST_HO(:,3);
    MidStancetoHO.StimInt  = Mid_ST_HO(:,4)*1000;
    MidStancetoHO.LocT     = Mid_ST_HO(:,5);
    MidStancetoHO.LocHS    = Mid_ST_HO(:,6);
    MidStancetoHO.PerGait  = (Mid_ST_HO(:,7)/Stride)*100;

    if exist('todelete') == 1
        Mid_ST_HO(todelete,:) = [];
    end

else
    MidStancetoHO = 0;
end
