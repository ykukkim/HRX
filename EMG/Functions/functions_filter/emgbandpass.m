function [ emgData_bandpassFilt_Rect,emgData_bandpassFilt] = emgbandpass( sf, data_input)
%%Bandpassfiltering
%
% bpfr = [10 300]; % Cutoff frequency
%
% %% Butterworth filter at 4th order
% [b, a] = butter(4, (bpfr/(sf*0.5)));
% emgData_bandpassFilt = filtfilt(b, a, data_input);
%
% %% Centering or Demeaning Left
% meanSubtract = (mean(emgData_bandpassFilt, 1).' * (ones(size(emgData_bandpassFilt, 1), 1)).').';
% emgData_bandpassFilt = emgData_bandpassFilt - meanSubtract;
%
%
% %%  Full wave rectification
% emgData_bandpassFilt_Rect = abs(emgData_bandpassFilt);

%% Yong
data_input.Power_removed = ft_preproc_dftfilter(data_input,sf,50)';
fileData.EMG.detrend = detrend(data_input.Power_removed);


% Take the moving average of the signal
movingAverage = movmean(abs(data_input), 100, 'Endpoints', 'discard');

% Create a rank order of the moving averages
% Make sure moving average is a double
movingAverage = double(movingAverage);
% Round the moving average to 10 decimal places
movingAverage = round(movingAverage, 10);


end
