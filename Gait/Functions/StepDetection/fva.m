function [HSlocs, TOlocs,zfootVel,zheel, ztoe] = fva(zheel, ztoe, srate, varargin)

%% Preallocation
HSlocs   = [];
TOlocs   = [];
optargin = size(varargin, 2);
switch optargin
    case 0
        toprdfac  = 0.8;  % Factor for disgarding HS
        hsprdfac  = 0.08; % Factor for disgarding TO
        zrangefac = 0.35; % Heel marker z coordinate by the HS event should
        % be in the range
        % [min(z), min(z) + zrangefac*(max(z) - min(z))]
        forder    = 4;    % Order
        cutfreq   = 7;    % Cut-off frequency
    case 2
        forder      = varargin{1};
        cutfreq     = varargin{2};
    case 3
        toprdfac    = varargin{1};
        hsprdfac    = varargin{2};
        zrangefac   = varargin{3};
    case 5
        toprdfac    = varargin{1};
        hsprdfac    = varargin{2};
        zrangefac   = varargin{3};
        forder      = varargin{4};
        cutfreq     = varargin{5};
    otherwise
        error('Wrong input format.');
end

if length(zheel) < ceil(toprdfac * srate) + 1
    error(['Input singal is too short. Signal should at least ' ...
        num2str(toprdfac * srate + 1) ' samples long']);
    return;
end

%% Filtering of the signal: Butterworth filter with specified parameters
assert(all(not(isnan([zheel; ztoe]))));
[b,a] = butter(forder, cutfreq(2) / srate , "low");
% [b,a] = butter(forder, 4 / srate , "low");
% [b_toe,a_toe] = butter(2, [1.48 1.52]/ 500 , "stop");
zheel = filtfilt(b, a, zheel);
ztoe  = filtfilt(b, a, ztoe);

%% Estimated center of the foot and Velocity of Foot

 zCoordfootcentre = 1/2 * (zheel + ztoe);
% [b,a] = butter(5, 3/ 500 , "low");
zCoordfootcentre  = filtfilt(b, a, zCoordfootcentre  );
zfootVel = diff(zCoordfootcentre) ./ transpose(diff(1:length(zCoordfootcentre))); % Compute velocity of the foot
% zero_exist_idx = find(abs(zfootVel) > 6);

% if any(zero_exist_idx)
%
%     mean_zero_exist = (zfootVel(zero_exist_idx-10)+zfootVel(zero_exist_idx+10));
%     mean_zero_exist = mean_zero_exist/2;
%     zfootVel(zero_exist_idx) = mean_zero_exist;
%
% end
%% Determine TO events_Original

mpd = floor(toprdfac * srate);
[TOpks, TOlocs] = findpeaks(zfootVel,  'minpeakdistance', mpd);
TOlocs = TOlocs(TOpks > 0.5 & TOpks < 2);         % x = TOlocs
TOpks = zfootVel(TOlocs);             % y = TOpks
% figure; plot(zfootVel);title('TOlocs, TOpks plotted on zfootVel');hold on;
% plot(TOlocs,TOpks, 'or'); hold on;
% figure; plot(ztoe,'r'); title('TOlocs, TOpks plotted on ztoe'); hold on;
% plot(TOlocs,ztoe(TOlocs),'ob');

%% Determine HS events_Original
mpd = floor(hsprdfac * srate);
[HSpks, HSlocs] = findpeaks(-zfootVel, 'minpeakdistance', mpd); % the velocity values are multiplied by -1
HSpks = zfootVel(HSlocs);           % Re-multiply the values with -1
HSlocs = HSlocs(HSpks < -0.3);      % HS occurs at negative velocity
HSpks = zfootVel(HSlocs);           % y = HSpks x = HSlocs

thre = abs(min(zheel)+ (zrangefac * (abs(max(zheel)) - abs(min(zheel)))));
thre_centre =abs(min(zCoordfootcentre)+ (zrangefac * (abs(max(zCoordfootcentre)) - abs(min(zCoordfootcentre)))));
thre_Vel = -(min(zfootVel) +(zrangefac*max(zfootVel)-min(zfootVel)));% By HS z-component of the heel should be in the lower 20% of the range
indx = zheel(HSlocs) <= thre & zCoordfootcentre(HSlocs) <= thre_centre & zfootVel(HSlocs)  <= - thre_Vel;
HSlocs = HSlocs(indx);
HSpks = HSpks(indx);
% figure; plot(zfootVel);title('HSlocs, HSpks plotted on zfootVel');hold on;
% plot(HSlocs,HSpks, 'or'); hold on;
% figure; plot(zheel); title('HSlocs, HSpks plotted on zheel'); hold on;
% plot(HSlocs,zheel(HSlocs),'or');
% figure; plot(zCoordfootcentre); title('HSlocs, HSpks plotted on zCoordfootcentre'); hold on;
% plot(HSlocs,zCoordfootcentre(HSlocs),'or');

if isempty(TOpks), return; end

% It is possible that up to this point multiple HS events are found between TO events.
% This problem is settled below. The signal is considered as periodical with period from one TO up the
% next TO. In every period there should be not more then one HS event.
%% Only one HS between two TO
HSpkstmp = [];
HSlocstmp = [];
for j = 1:length(TOlocs)-1              % min two TOlocs required
    indx = TOlocs(j) < HSlocs & HSlocs <  TOlocs(j+1); % Wahrheitspr?fung
    HSpksPrd         = HSpks(indx);
    HSlocsPrd        = HSlocs(indx);
    [HSpksPrd, indx] = min(HSpksPrd);   % smaller peak is chosen
    HSlocsPrd        = HSlocsPrd(indx);
    HSpkstmp         = [HSpkstmp HSpksPrd];                 %#ok<AGROW>
    HSlocstmp        = [HSlocstmp HSlocsPrd];               %#ok<AGROW>
end

%% First HS before all TO
indx                 = HSlocs < TOlocs(1);
HSpksPrd             = HSpks(indx);
HSlocsPrd            = HSlocs(indx);
[HSpksPrd, indx]     = min(HSpksPrd);
HSlocsPrd            = HSlocsPrd(indx);
HSpkstmp             = [HSpkstmp HSpksPrd];
HSlocstmp            = [HSlocstmp HSlocsPrd];

%% Last HS after all TO
indx                 =  TOlocs(end) < HSlocs;
HSpksPrd             = HSpks(indx);
HSlocsPrd            = HSlocs(indx);
[HSpksPrd, indx]     = min(HSpksPrd);
HSlocsPrd            = HSlocsPrd(indx);
HSpkstmp             = [HSpkstmp HSpksPrd];
HSlocstmp            = [HSlocstmp HSlocsPrd];

HSpks       = sort(HSpkstmp);
HSlocs      = sort(HSlocstmp);

d = size(TOlocs);
if d(1)>d(2), TOlocs = transpose(TOlocs); end
d = size(HSlocs);
if d(1)>d(2), HSlocs = transpose(HSlocs); end

% %% Plots for manuscript
 figure
plot(zfootVel, 'black')
title ('Foot velocity of virtual foot centre', 'FontSize', 14)
hold on
xlabel('Data Points'); ylabel('Velocity (m/s)');
% Plot Heel Strike with a custom label for the legend
hs = plot(HSlocs, zfootVel(HSlocs), 'or', 'DisplayName', 'Heel Strike');
hold on

% Plot Toe Off with a custom label for the legend
to = plot(TOlocs, zfootVel(TOlocs), 'sg', 'DisplayName', 'Toe Off');

% Create the legend using the custom labels
legend([hs, to]);

% Increase the font size of the axes
ax = gca;
ax.FontSize = 12;

figure;

% First subplot: Heel strike on vertical heel marker
subplot(2, 1, 1);
plot(15000:18000,zheel(15000:18000));
title('Heel strike on vertical heel marker');
hold on;
hs_locs_in_range = HSlocs(HSlocs>=15000 & HSlocs<=18000);

hs = plot(hs_locs_in_range, zheel(hs_locs_in_range), 'or', 'MarkerFaceColor', 'r', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Heel Strike');
hold off;
legend(hs);
set(gca, 'xtick', [], 'ytick', []); % Remove ticks

% Second subplot: Toe off of vertical toe marker
subplot(2, 1, 2);
plot(15000:18000,ztoe(15000:18000));
title('Toe off of vertical toe marker');
hold on;
to_locs_in_range = TOlocs(TOlocs>=15000 & TOlocs<=18000);
to = plot(to_locs_in_range, ztoe(to_locs_in_range), 'sg', 'MarkerFaceColor', 'g', 'MarkerSize', 8, 'LineWidth', 2, 'DisplayName', 'Toe Off');
hold off;
legend(to);
set(gca, 'xtick', [], 'ytick', []); % Remove ticks
return;
end
