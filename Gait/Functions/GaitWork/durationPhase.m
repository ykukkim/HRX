function [durationGaitCycleL, durationGaitCycleR, durationStancePhL, durationStancePhR,...
    durationSwingPhL, durationSwingPhR, dlsL, dlsR, ndlsL, ndlsR]=durationPhase(HSleft, HSright, TOleft, TOright, ...
    HSleftlocs,HSrightlocs, TOleftlocs, TOrightlocs,...
    samplingRate)
%calculates durationGaitCycle, durationStancePh, durationSwingPh and dls

%set parameters
nHSleft = length(HSleft);
nTOleft = length(TOleft);
nHSright = length(HSright);
nTOright = length(TOright);

%% Duration of gait cycle (s)
durationGaitCycleL = nan(1, nHSleft-1);
for j=1:nHSleft-1
    durationGaitCycleL(j) = (HSleftlocs(j+1) - HSleftlocs(j)) / samplingRate;
end

durationGaitCycleR = nan(1, nHSright-1);
for j=1:nHSright-1
    durationGaitCycleR(j) = (HSrightlocs(j+1) - HSrightlocs(j)) / samplingRate;
end

%% Duration of the stance phase (s)
durationStancePhL = nan(1, min(nHSleft, nTOleft));
for j=1:min(nHSleft, nTOleft)
    durationStancePhL(j) = (TOleftlocs(j) - HSleftlocs(j))/samplingRate;
end
durationStancePhR = nan(1, min(nHSright, nTOright));
for j=1:min(nHSright, nTOright)
    durationStancePhR(j) = (TOrightlocs(j) - HSrightlocs(j))/samplingRate;
end

%     % Convert to (% of cycle)
%     mnl = min(length(durationStancePhL), length(durationGaitCycleL));
%     durationStancePhL = 100*durationStancePhL(1:mnl) ./ durationGaitCycleL(1:mnl);
%     mnl = min(length(durationStancePhR), length(durationGaitCycleR));
%     durationStancePhR = 100*durationStancePhR(1:mnl) ./ durationGaitCycleR(1:mnl);

%% Duration of the swing phase (s)
durationSwingPhL = nan(1, min(nHSleft-1, nTOleft));
for j=1:min(nHSleft-1, nTOleft)
    durationSwingPhL(j) = ...
        (HSleftlocs(j+1) - TOleftlocs(j))/samplingRate;
end

durationSwingPhR = nan(1, min(nHSright-1, nTOright));
for j=1:min(nHSright-1, nTOright)
    durationSwingPhR(j) = ...
        (HSrightlocs(j+1) - TOrightlocs(j))/samplingRate;
end
%     % Convert to (% of cycle)
%     mnl = min(length(durationSwingPhL), length(durationGaitCycleL));
%     durationSwingPhL = 100*durationSwingPhL(1:mnl) ./ durationGaitCycleL(1:mnl);
%     mnl = min(length(durationSwingPhR), length(durationGaitCycleR));
%     durationSwingPhR = 100*durationSwingPhR(1:mnl) ./ durationGaitCycleR(1:mnl);

%% Duration of double limb support (s)
dlsL = [];
for j=1:min(nHSleft, nTOleft)
    indx = find(HSleftlocs(j) <= HSrightlocs & HSrightlocs <= TOleftlocs(j)); %#ok<EFIND>
    if any(indx >= 1)
        value = (TOleftlocs(j) - HSrightlocs(indx(1))) / samplingRate;
        %             % Convert to (% of cycle)
        %             value = 100*value/ durationGaitCycleL(j);
        dlsL = [dlsL value]; %#ok<AGROW>
    end
end
if isempty(dlsL), dlsL = NaN; end
dlsR = [];
for j=1:min(nHSright, nTOright)
    indx = find(HSrightlocs(j) <= HSleftlocs & HSleftlocs <= TOrightlocs(j)); %#ok<EFIND>
    if any(indx >= 1)
        value = (TOrightlocs(j) - HSleftlocs(indx(1))) / samplingRate;
        %             % Convert to (% of cycle)
        %             value = 100*value/ durationGaitCycleR(j);
        dlsR = [dlsR value]; %#ok<AGROW>
    end
end
if isempty(dlsR), dlsR = NaN; end

%% normalized double limb support (%)
ndlsL=[];
ndlsR=[];
for k=1:min(length(dlsL), length(durationGaitCycleL))
    valL=100*(dlsL(k)/durationGaitCycleL(k));
    ndlsL=[ndlsL valL];
end

for m=1:min(length(dlsR), length(durationGaitCycleR))
    valR=100*(dlsR(m)/durationGaitCycleR(m));
    ndlsR=[ndlsR valR];
end

return
end
