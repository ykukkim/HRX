function [R_m] = getRotM(vec1,vec2)

% vec1 will be rotated to vec2
% so in my case vec2 should be the walking direction of interest e.g. [0;1;0]

th1 = atan2d(vec1(2),vec1(1));
M1z = RRz(-th1);
th2 = atan2d(vec2(2),vec2(1));
M2z = RRz(-th2);
v1 = M1z*vec1;
v2 = M2z*vec2;
b = atan2d(v2(1),v2(3));
a = atan2d(v1(1),v1(3));
My = RRy(b-a);
R_m = M2z'*My*M1z;


end
