function R = RRz(theta)
% ccw rotation in DEGREES with rotation axis out of the page
R =  [cosd(theta) -sind(theta) 0
      sind(theta)  cosd(theta) 0
      0            0           1];
end
