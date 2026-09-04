function [GaitEvents , interpolatedVD,error] = StepDetection(interpolatedVD, Name,Test)
error=false; % if for any reason the trial was invalid, a true value is assigned to this variable
GaitEvents=struct;
ctrialsfewEventsnames  = {};
cStepSkippedByFVAnames  = {};
ctrialsfewEvents      = 0;
cStepSkippedByFVA     = 0;

%% fva, find HS and TO
% Input parameters for the algorithm determined through approximate
% walking speed of the participant as well as via experience.
toprdfac  = 0.8;  % Factor for discarding TO more than 1 step per 60 - 70 frames
hsprdfac  = 0.08; % Factor for discarding HS
zrangefac = 0.4; % Heel marker z coordinate by the HS event should
% zrangefac = 0.15; % Heel marker z coordinate by the HS event should be in the range [min(z), min(z) + zrangefac*(max(z) - min(z))]
filterOrder = 4; % seems to provide the best results
cutfreqFilter = [0.01, 25]; % Not much happening in walking task above 25 Hz

try
    [HSleftlocs, TOleftlocs,zfootVelLeft,interpolatedVD.LHEE.Values.z_coord, interpolatedVD.LTO3.Values.z_coord]    = fva(double(interpolatedVD.LHEE.Values.z_coord),double(interpolatedVD.LTO3.Values.z_coord), ...
        interpolatedVD.SF, toprdfac, hsprdfac, zrangefac, filterOrder, cutfreqFilter);

    [HSrightlocs, TOrightlocs,zfootVelRight,interpolatedVD.RHEE.Values.z_coord,interpolatedVD.RTO3.Values.z_coord]  = fva(double(interpolatedVD.RHEE.Values.z_coord), double(interpolatedVD.RTO3.Values.z_coord), ...
        interpolatedVD.SF, toprdfac, hsprdfac, zrangefac, filterOrder, cutfreqFilter);

HSleft = interpolatedVD.LHEE.Values.z_coord(HSleftlocs);
TOleft = interpolatedVD.LTO3.Values.z_coord(TOleftlocs);
HSright = interpolatedVD.RHEE.Values.z_coord(HSrightlocs);
TOright = interpolatedVD.RTO3.Values.z_coord(TOrightlocs);

catch
    fprintf("Data is broken in %s %s\n", Name,Test);
end
%% check data on few events

fewEvents = length(HSleftlocs) < 2 || length(TOleftlocs) < 1 || length(HSrightlocs) < 2 || length(TOrightlocs) < 1;

if fewEvents
    ctrialsfewEvents = ctrialsfewEvents + 1;
    ctrialsfewEventsnames(ctrialsfewEvents, 1:2) = {Name, interpolatedVD};
    error=true;
    return;
end

%% Format the data. Start with first HS, end with HS or TO
[HSleft, HSleftlocs, TOleft, TOleftlocs, wrongRecogL] = formatdata(HSleft, HSleftlocs, TOleft, TOleftlocs);
[HSright, HSrightlocs, TOright, TOrightlocs, wrongRecogR] = formatdata(HSright, HSrightlocs, TOright, TOrightlocs);

if wrongRecogL || wrongRecogR
    cStepSkippedByFVA = cStepSkippedByFVA + 1;
    cStepSkippedByFVAnames(cStepSkippedByFVA, 1:2) = {Name, interpolatedVD};
    error=true;
    return;
end

fewEvents = length(HSleft) < 2 || length(TOleft) < 1 || length(HSright) < 2 || length(TOright) < 1;
if fewEvents
    ctrialsfewEvents = ctrialsfewEvents + 1;
    ctrialsfewEventsnames(ctrialsfewEvents, 1:2) = {Name, interpolatedVD};
    error=true;
    return;
end

%% Check if any steps skipped (HS not detected) by FVA

l = zeros(1, length(HSleftlocs));
r = zeros(1, length(HSrightlocs));
l(1:end) = 'L';     % left
r(1:end) = 'R';     % right
hs_matrix = [HSleftlocs HSrightlocs; l r];
hs_matrix = sortrows(hs_matrix', 1);

Duplicate = find((diff(hs_matrix(:,2))==0 |diff(hs_matrix(:,1))==0)==1);
Duplicate_size = length(Duplicate);

for a = Duplicate_size(1,1):-1:1
    hs_matrix(Duplicate(a,:),:) = [];
end

find_L_indx = find(diff(hs_matrix(:,1)) > interpolatedVD.SF/2 & ...
    (diff(hs_matrix(:,2))~=0 ));
find_L_indx = find(hs_matrix(find_L_indx,2) == 'L' == 1);
hs_matrix = hs_matrix(find_L_indx(1):end,:);

%% start with L
startLeft = hs_matrix(1, 2) == 'L' && hs_matrix(2, 2) == 'R';
while not(startLeft)
    hs_matrix = hs_matrix(2:end, :);

    wrongRecog = not(startLeft) && size(hs_matrix, 1) < 2;
    if wrongRecog, return; end

    startLeft = hs_matrix(1, 2) == 'L' && hs_matrix(2, 2) == 'R';
end

%% end with L
endLeft = hs_matrix(end, 2) == 'L' && hs_matrix(end-1, 2) == 'R';
while not(endLeft)
    hs_matrix = hs_matrix(1:end-1, :);

    wrongRecog = not(endLeft) && size(hs_matrix, 1) < 2;
    if wrongRecog, return; end

    endLeft = hs_matrix(end, 2) == 'L' && hs_matrix(end-1, 2) == 'R';
end

ltoe = zeros(1, length(TOleftlocs));
rtoe = zeros(1, length(TOrightlocs));
ltoe(1:end) = 'L';     % left
rtoe(1:end) = 'R';     % right
to_matrix = [TOleftlocs TOrightlocs; ltoe rtoe];
to_matrix = sortrows(to_matrix', 1);

Duplicate = find((diff(to_matrix(:,2))==0 |diff(to_matrix(:,1))==0)==1);
Duplicate_size = length(Duplicate);

for a = Duplicate_size(1,1):-1:1
    to_matrix(Duplicate(a,:),:) = [];
end

find_L_indx = find(diff(to_matrix(:,1)) > interpolatedVD.SF/2 &...
    (diff(to_matrix(:,2))~=0 ));
find_L_indx = to_matrix(:,1) > hs_matrix(1,1);
find_L_indx = find(to_matrix(find_L_indx,2) == 'L');
to_matrix = to_matrix(find_L_indx(1):end,:);

%% start with L
startLeft = to_matrix(1, 2) == 'L' && to_matrix(2, 2) == 'R';
while not(startLeft)
    to_matrix = to_matrix(2:end, :);

    wrongRecog = not(startLeft) && size(to_matrix, 1) < 2;
    if wrongRecog, return; end

    startLeft = to_matrix(1, 2) == 'L' && to_matrix(2, 2) == 'R';
end

%% end with L
endLeft = to_matrix(end, 2) == 'L' && to_matrix(end-1, 2) == 'R';
while not(endLeft)

    to_matrix = to_matrix(1:end-1, :);

    wrongRecog = not(endLeft) && size(to_matrix, 1) < 2;
    if wrongRecog, return; end

    endLeft = to_matrix(end, 2) == 'L' && to_matrix(end-1, 2) == 'R';
end

for j = 1:size(hs_matrix, 1)-1
    stepMissed = isequal(hs_matrix(j, 2), 'L') && isequal(hs_matrix(j+1, 2), 'L') || isequal(hs_matrix(j, 2), 'R') && isequal(hs_matrix(j+1, 2), 'R');
    if stepMissed
        break;
    end
end

if stepMissed
    cStepSkippedByFVA = cStepSkippedByFVA + 1;
    cStepSkippedByFVAnames(cStepSkippedByFVA, 1:2) = {Name, interpolatedVD};
    disp('stepMissed, end loop')
    error=true;
    return;
end

hs_leftlocs  = hs_matrix(:,2) == 'L';
hs_rightlocs = hs_matrix(:,2) == 'R';
HSleftlocs   = hs_matrix(hs_leftlocs,1)';
HSrightlocs  = hs_matrix(hs_rightlocs,1)';


to_leftlocs = to_matrix(:,2) == 'L';
to_rightlocs = to_matrix(:,2) == 'R';
TOleftlocs= to_matrix(to_leftlocs,1)';
TOrightlocs = to_matrix(to_rightlocs,1)';

HSleft = interpolatedVD.LHEE.Values.z_coord(HSleftlocs);
TOleft = interpolatedVD.LTO3.Values.z_coord(TOleftlocs);
HSright = interpolatedVD.RHEE.Values.z_coord(HSrightlocs);
TOright = interpolatedVD.RTO3.Values.z_coord(TOrightlocs);
HSleft = HSleft';
TOleft = TOleft';
HSright = HSright';
TOright = TOright';

%% create structure

GaitEvents.HSleft           = HSleft;
GaitEvents.HSleftlocs       = HSleftlocs;
GaitEvents.HSright          = HSright;
GaitEvents.HSrightlocs      = HSrightlocs;
GaitEvents.TOleft           = TOleft;
GaitEvents.TOleftlocs       = TOleftlocs;
GaitEvents.TOright          = TOright;
GaitEvents.TOrightlocs      = TOrightlocs;
GaitEvents.zfootVelRight    = zfootVelRight;
GaitEvents.zfootVelLeft     = zfootVelLeft;

%% Number of Gait events

nHSleft = length(HSleft);
nTOleft = length(TOleft);
nHSright = length(HSright);
nTOright = length(TOright);
GaitEvents.nHSleft=nHSleft;
GaitEvents.nHSright=nHSright;
GaitEvents.nTOleft=nTOleft;
GaitEvents.nTOright=nTOright;

end
