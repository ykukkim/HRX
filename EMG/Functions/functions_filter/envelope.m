function [envel_max, envel_min]=envelope(data, neighbourhoodrad)
%% Envelope function to determine on-off-times
[pks, max_locs]=findlocalmax(data, neighbourhoodrad,'max');
max_locs=[1 max_locs length(data)];
x=max_locs;
y=data(max_locs);
xq=1:length(data);
envel_max = interp1(x,y,xq);

[pks, min_locs]=findlocalmax(data, neighbourhoodrad,'min');
min_locs=[1 min_locs length(data)];
x=min_locs;
y=data(min_locs);
xq=1:length(data);
envel_min = interp1(x,y,xq);
