function [ emgData_firing, threshold, referenceContraction] = firingpattern(filename, sf, data_input )
%% This code finds the activation pattern.

% Chose the threshold (calculated from the corresponding subject's mean and
% standard deviation from its noise/standing-normal file) :
n=2; % Here threshold=mean+2sd
% n=3; % Here threshold=mean+3sd
% n=4; % Here threshold=mean+4sd
% n=5; % Here threshold=mean+5sd

%% calulate noiseMean and NoiseSTD
% mean + 1.75SD corresponds to 96%-ile of data
% mean + 2SD is 98%-ile of data and so on
% calculating threshold ?? Here noiseMean plus NoiseSTD should be used!

[emgData_noise_mean, emgData_noise_std, referenceContraction] = getnoise(filename);
threshold = emgData_noise_mean + n*emgData_noise_std;
lengthofenv = size(data_input, 1);

%% Getting the filtered firing patterns
% Choose the neighborhood for the "medfil1"
% firing rate is calculated on moving average filtered data with a
% if the size of moving average EMG data is 150 frames window,
% the resulting 4 points on the average
% lead to 0.5 seconds of EMG signal, while 8 to 1 sec and so on...
q=25;

for muscle = 1:size(data_input,2)
    emgData_firing(:,muscle) = medfilt1(double(data_input(:,muscle) >=  threshold(1,muscle)),q);
end

end
