function [ AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,i,destPath] = Calculation(EMG,Trig,Stimulus, critvalue,i,destPath)

[m,n] = size (EMG);
x = zeros(1,n);
EMGinv = -1*EMG;

% Adjust depending on the system sampling frequency
% 1/fs(EMG)Hz = 0.33ms
% Intro = 100ms
% The delay of the delsys is between 45ms to 60ms
% Mwave  = 5~15ms
% Hwave  = 30~45ms

intro = 300; % 100ms of Background EMG
delay = 190; % 50ms of Delsys delay
MW=60;  % length of M-Window
HW=120; % length of H-Window

time = linspace(0,998,500);

k = 1;
x(1,k) = find(Trig(:,1)>= 1 ,1,'first'); % Search the First Trigger Point
x1(1,k) = Stimulus(x(1,k),k);            % Amplitude of the Trigger Signal
stimulus_temp = x1(1,k)*1000;            % Ampere to mA

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
[Minima,MinIdx] = findpeaks(EMGinv(x(1,k)+delay:(x(1,k)+MW+delay),k),'SortStr','descend'); %Minimum im Fenster von Ankunft Trigger bis 45Frames sp�ter(15ms)
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

h = figure('units','normalized','outerposition',[0 0 0.65 1]); % plot of EMG Signal with Windows and Amplitudes
plot(EMG(x(1,k)-intro:m,k),'LineWidth',1);
hold on

%% Baseline EMG
plot(maxBIdx(1,k),maxB(1,k),'Marker','*','Color','red');
hold on
plot(minBIdx(1,k),minB(1,k),'Marker','*','Color','red');
hold on
rectangle('Position',[0 0 intro (AmplitudeBaseline(1,k)*2)],'EdgeColor','b','LineWidth',1);

%% M-Wave
plot(maxMIdx(1,k)+intro+delay,maxM(1,k),'Marker','*','Color','red');
hold on
plot(minMIdx(1,k)+intro+delay,minM(1,k),'Marker','*','Color','red');
hold on
rectangle('Position',[intro+delay abs(minM(1,k))*(-2) MW (AmplitudeMwave(1,k)*2)],'EdgeColor','r','LineWidth',1);

%% H-reflex
hold on
plot(maxHIdx(1,k)+intro+MW+delay , maxH(1,k),'Marker','*','Color','red');
hold on
plot(minHIdx(1,k)+intro+MW+delay , minH(1,k),'Marker','*','Color','red');
hold on
rectangle('Position',[intro + MW + delay abs(minH(1,k))*(-2) HW (AmplitudeHwave(1,k)*2)],'EdgeColor','r','LineWidth',1);

%% Beschriftung Baseline
strmin = ['Minimum =', num2str(minB(1,k))];
text(minBIdx(1,k),minB(1,k),strmin,'HorizontalAlignment','right');
strmax = ['Maximum =', num2str(maxB(1,k))];
text(maxBIdx(1,k),maxB(1,k),strmax,'HorizontalAlignment','left');
text(0,maxB(1,k)+0.11,'Baseline EMG - Window')

%% Beschriftung M-Wave
strmin = ['Minimum =', num2str(minM(1,k))];
text(minMIdx(1,k) + intro + delay,minM(1,k),strmin,'HorizontalAlignment','right');
strmax = ['Maximum =', num2str(maxM(1,k))];
text(maxMIdx(1,k) + intro + delay,maxM(1,k),strmax,'HorizontalAlignment','left');
text(intro + delay,maxM(1,k)+0.11,'M-Wave-Window')

%% Beschriftung H-Wave
strmin = ['Minimum =', num2str(minH(1,k))];
text(minHIdx(1,k) + intro + MW + delay,minH(1,k),strmin,'HorizontalAlignment','right');
strmax = ['Maximum =', num2str(maxH(1,k))];
text(maxHIdx(1,k) + intro + MW + delay,maxH(1,k),strmax,'HorizontalAlignment','left');
text(intro + delay+ MW,maxH(1,k)+0.11,'H-Wave-Window')

if stimulus_temp > critvalue
    title (['Soleus EMG Mmax vs Stimulus Intensity=', num2str(stimulus_temp),'mA'])
else
    title(['Soleus EMG H-Reflex vs Stimulus Intensity =', num2str(stimulus_temp),'mA'])
end

xlabel('\fontsize{14} Data Points');
ylabel('\fontsize{14} EMG Amplitude [V]');

%% Figure Save
savename = sprintf('Figure %d',i);
savefig(h, fullfile(destPath, savename), 'compact');
clear Maxima
clear n
close(h)
end
