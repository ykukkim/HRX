% [midStCand, midStCandlocs] = findlocalmax(d, round(mpd/2), 'min');
% signal = d;
% round(mpd/2)=17 with SF=100Hz
% neighbourhoodrad=17;
% option='min';
function [pks, locs] = findlocalmax(signal, neighbourhoodrad, option)
%FINDLOCALMAX computes the local extrema (maxima or minima).
%   [PKS, LOCS] = FINDLOCALMAX(SIGNAL, NEIGHBOURHOODRAD, OPTION) computes
%   the local extrema with values PKS and locations LOCS for the vector
%   SIGNAL by looking at the neighbourhood of each point point in
%   the signal. The neighbourhood of point n is defined as the interval
%   [n-NEIGHBOURHOODRAD; n+NEIGHBOURHOODRAD].
%   No point from the first or last neighbourhoodrad-many frames can be an
%   extrema. Parameter OPTION specifies whether to find maxima or minima
%   and takes the values 'min' or 'max'.
%
% Written on 2011-07-18
% Last modified on 2011-07-18

% find local maxima or minima?
switch option
    case 'min'
        signal = -signal; % step width
        sign = -1;
    case 'max'
        sign = 1;
    otherwise
        error('MATLAB:findlocalmax:wrongOption', ...
            'Option must have a value ''min'' or ''max''');
end

r = neighbourhoodrad; % 17
d = length(signal);
islocalmaximum = false(1, d);
% for the neighbourhood of each frame
% checks whether the value around the neigbourhoodradius is a min or max
% (according to option chosen)
for n = r+1:d-r % 18:273 if d=290
    islocalmaximum(n) = all(signal([n-r:n-1 n+1:n+r]) < signal(n));
    % example: islocalmaximum(18) = all(signal([18-17:18-1 18+1:18+17]) < signal(18));
    % example: islocalmaximum(18) = all(signal([1:17 19:35]) < signal(18));
end

locs = find(islocalmaximum);
pks = signal(locs);

% sign correction
pks = sign * pks;

return;
end
