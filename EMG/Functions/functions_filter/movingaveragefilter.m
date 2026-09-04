function [ emgData_movavFilt] = movingaveragefilter( data_input, samplerate, overlap_string)
%% moving average filter initailse

a = 1;
EmgData = abs(data_input);                                   % Absolute value of the signal

Nwin = (0.08*samplerate);                                   % 25% of sample frequency window
if ~(isempty(strmatch(overlap_string, 'overlap')))
    Novlp = 0.1* Nwin;                                      % 10% overlap
elseif ~(isempty(strmatch(overlap_string, 'nooverlap')))
    Novlp = 0;
elseif ~(isempty(strmatch(overlap_string, 'both')))
    Novlp = 0.1* Nwin;                                      % Needs to be corrected.
end

Noffset = Nwin-Novlp;

%% MAV filter
%(1/windowSize)*((y(n)+y(n-1)+..+y(n-(windowSize-1))).
win = (1/(Nwin))*ones(Nwin,1);  % compute the numerator and denominator coefficients for the rational transfer function.
y = filter(win,a,EmgData);
emgData_movavFilt = y(Nwin:Noffset:end, :);

end
