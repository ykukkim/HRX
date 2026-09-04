function [ emgData_envelope ] = emgenvelope( data_input, samplingfreq )
%% Creates an envelope around the signal.
% First define neighbourhoodrad for findlocalmax.m function which finds localmax
% by looking at the neighbourhood of each point in the signal.
% The neighbourhood of point n is defined as the interval [n-NEIGHBOURHOODRAD; n+NEIGHBOURHOODRAD].
% the envelope is created on the moving average filter data...

neighbourhoodrad = 1000;

%% Data filtering : apply Hilbert filter + Sara's "envelope" function
emgData_hilbert=abs(hilbert(data_input));

for muscle= 1:size(emgData_hilbert,2)
    emgData_envelope(:,muscle)=envelope(emgData_hilbert(:,muscle),neighbourhoodrad);
end



end
