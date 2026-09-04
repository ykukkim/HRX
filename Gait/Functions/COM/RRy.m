function R = RRy(theta)
% ccw rotation in DEGREES with rotation axis out of the page
R = [cosd(theta) 0  sind(theta)
     0           1  0
     -sind(theta) 0  cosd(theta)];
end
