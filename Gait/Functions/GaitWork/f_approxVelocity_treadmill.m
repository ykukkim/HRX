function [VD]=f_approxVelocity_treadmill(Data,Markers)
% Speed of treadmill
% Ymid_right = Data.RTO3.Values.y_coord;
% Ymid_left  = Data.LTO3.Values.y_coord;
Ymid_right = Data.RTO3(:,2);
Ymid_left  = Data.LTO3(:,2);
SF = Data.SF;

%Calculates velocity per track
mpd = 0.8 * SF;
[~, loc_max_right] = findpeaks(Ymid_right, 'minpeakdistance', mpd);
[~, loc_min_right] = findpeaks(-Ymid_right,'minpeakdistance', mpd);
[~,  loc_max_left]  = findpeaks(Ymid_left,  'minpeakdistance', mpd);
[~,  loc_min_left]  = findpeaks(-Ymid_left, 'minpeakdistance', mpd);

start_min_point = find(loc_min_right> loc_max_right(1));
loc_min_right = loc_min_right(start_min_point(1):end);
start_min_point = find(loc_min_left> loc_max_left(1));
loc_min_left = loc_min_left(start_min_point(1):end);

min_right = min(length(loc_max_right),length(loc_min_right));
min_left = min(length(loc_max_left),length(loc_min_left));

for i=1:min(min_right,min_left)-1
    idx     = find(loc_max_right > loc_min_right(i));
    speed_r_Y(i) = ((Ymid_right(floor(loc_max_right(idx(1))-0.*SF)) - (Ymid_right(floor(loc_min_right(i)+0.15*SF))))...
        /(floor(loc_max_right(idx(1))-0.15*SF)-floor(loc_min_right(i)+0.15*SF)))*SF;
    idx     = find(loc_max_left > loc_min_left(i));
    speed_l_Y(i) = ((Ymid_left(floor(loc_max_left(idx(1))-0.*SF)) - (Ymid_left(floor(loc_min_left(i)+0.15*SF))))...
        /(floor(loc_max_left(idx(1))-0.15*SF)-floor(loc_min_left(i)+0.15*SF)))*SF;
end

speed_l_Y = rmoutliers(speed_l_Y);
speed_r_Y = rmoutliers(speed_r_Y);

tm_v_Y    = (mean(speed_l_Y) + mean(speed_r_Y))/2;

for h=1:length(Markers)

    Markername = Markers(h);
    Markername = cell2mat(Markername);
    Marker = Data.(Markername);

    % adding to Y-axis, negative because have to add it in opposite direction
    %     for k=1:length(Marker.Values.y_coord)
    for k = 1:length(Marker)
        % milimeters/frame
        mmpf_Y = (1/SF)*tm_v_Y;
        %         Marker_v(k) = Marker.Values.y_coord(k)-((mmpf_Y*k)*-1);
        Marker_v(k) = Marker(k,2)-((mmpf_Y*k)*-1);

    end
    %     VD.(Markername) = [Marker.Values.x_coord Marker_v' Marker.Values.z_coord];
    VD.(Markername) = [Marker(:,1) Marker_v' Marker(:,3)];

end

% dimSpeed = walkingSpeed/sqrt(accGra*meanlegLength/1000);

end
