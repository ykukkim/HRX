% function [ AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1, h,i,destPath] = Calculation( EMG,Trig,Stimulus, critvalue,i,destPath)
function [ AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,i,destPath] = Calculation( EMG,Trig,Stimulus, critvalue,i,destPath)

[m,n] = size (EMG);
x = zeros(1,n);
EMGinv = -1*EMG;
intro = 150;
% delay =160;
delay = 180;
% delay = 5;
MW=60; % length of M-Window
HW=120; % length of H-Window
time = linspace(0,998,500);

k = 1;
% x(1,k) = find(Trig(:,k) >= 2 ,1,'first'); % Search the First Trigger
x(1,k) = find(Stimulus(:,1)>= 1 ,1,'first'); % Search the First Trigger Point
x1(1,k) = Trig(x(1,k),k);                % Amplitude of the Trigger Signal
stimulus = x1(1,k) * 10;

if x1(1,k) >= critvalue
    del(1,:) = find(EMG(300:400,k) > 0.9);
    if del(1,1)+300 - x(1,k) < 90
        delay = 85;
    end
end
    %% Baseline EMG
    [Maxima,MaxIdx] = findpeaks(EMG(((x(1,k)-intro):(x(1,k)-1)),k),'SortStr','descend');
    maxB(1,k) = Maxima(1,1); % Maximum im Fenster in Intro bis Ankunft von Trigger
    maxBIdx (1,k) = MaxIdx(1,1);
    [Minima,MinIdx] = findpeaks(EMGinv(((x(1,k)-intro):(x(1,k)-1)),k),'SortStr','descend'); % Minimum im Fenster in Intro bis Ankunft von Trigger
    minB(1,k) = -1*Minima(1,1);
    minBIdx (1,k) = MinIdx(1,1);
    AmplitudeBaseline(1,k) = maxB(1,k) - minB(1,k); % maximale Amplitude im Fenster

    %% M-Wave
    [Maxima,MaxIdx] = findpeaks(EMG(x(1,k)+delay:(x(1,k)+MW+delay),k),'SortStr','descend');
    maxM(1,k) = Maxima(1,1); % Maximum im Fenster von Ankunft Trigger bis 45Frames sp�ter (15ms)
    maxMIdx (1,k) = MaxIdx(1,1);
    [Minima,MinIdx] = findpeaks(EMGinv(x(1,k)+delay:(x(1,k)+delay+MW),k),'SortStr','descend'); %Minimum im Fenster von Ankunft Trigger bis 45Frames sp�ter(15ms)
    minM(1,k) = -1*Minima(1,1);
    minMIdx (1,k) = MinIdx(1,1);
    AmplitudeMwave(1,k) = maxM(1,k) - minM(1,k); % maximale Amplitude im Fenster

    %% H-Reflex
    [Maxima,MaxIdx] = findpeaks(EMG((x(1,k)+(MW+delay)):(x(1,k)+MW+HW+delay),k),'SortStr','descend');
    maxH(1,k) = Maxima(1,1);
    maxHIdx (1,k) = MaxIdx(1,1);
    [Minima,MinIdx] = findpeaks(EMGinv((x(1,k)+MW+delay):(x(1,k)+MW+HW+delay),k),'SortStr','descend');
    minH(1,k) = -1*Minima(1,1);
    minHIdx (1,k) = MinIdx(1,1);
    AmplitudeHwave(1,k) = maxH(1,k) - minH(1,k);

end
