function [HMall] = Linefit(AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,destPath,filename)
header = {'Subject','HMratio','H_r2','H_rmse','M_r2','M_rmse','Hmax','Mmax','StimHmax','Hat%Mmax','Bemg'};
HMall = header;
tmp_sub = filename(1:13);
h = AmplitudeHwave';
m = AmplitudeMwave';
stmI = x1'*10;
bemg = mean(AmplitudeBaseline');

for i = 1:length(h)
    if h(i) >= 0.7*(max(h))
        hweights(i) = 10;
    else
        hweights(i) = 1;
    end
end

[hfit, hgood] = fit(stmI,h,'gauss1','Weight',hweights);
[smoothH,IDofH] = max(feval(hfit,stmI));
QofH = [hgood.rsquare; hgood.rmse];

%% try fit sigmoid tp m
[mfit_tmp,mgood_tmp] = sigm_fit(stmI,m,[],[],0);
[m_r2_tmp,m_rmse_tmp] = rsquare(m,mgood_tmp.ypred);

while m_r2_tmp < 0.2
    if m_r2_tmp < 0.2
        stmI = stmI(2:end);
        m = m(2:end);
        [mfit_tmp,mgood_tmp] = sigm_fit(stmI,m,[],[],0);
        [m_r2_tmp,m_rmse_tmp] = rsquare(m,mgood_tmp.ypred);
    else
        m_r2_tmp = m_r2_tmp;
    end
end
mfit = mfit_tmp;
mgood = mgood_tmp;
m_r2 = m_r2_tmp;
m_rmse = m_rmse_tmp;

f = @(param,stmI)param(1)+(param(2)-param(1))./(1+10.^((param(3)-stmI)*param(4)));
QofM = [m_r2; m_rmse];
smoothM = max(f(mfit,stmI));

mx_vec = min(stmI):(max(stmI)-min(stmI))/(length(stmI)-1):max(stmI);
mMat = [mx_vec;f(mfit,mx_vec)]';

HMratio = (smoothH/smoothM)*100;
IatHmax = stmI(IDofH,1);
[~,IDofM] = max(find(mMat(:,2) < (smoothM*0.3)));
IDstm = mMat(IDofM,1);
HatM = feval(hfit,IDstm);

plotID = isempty(HatM);

% tmp_all = {tmp_file,tmp_sub,HMratio,QofH(1,1),QofH(2,1),QofM(1,1),QofM(2,1),smoothH,smoothM,IatHmax,HatM,bemg};
tmp_all = {tmp_sub,HMratio,QofH(1,1),QofH(2,1),QofM(1,1),QofM(2,1),smoothH,smoothM,IatHmax,HatM,bemg};
HMall = cat(1,HMall,tmp_all);

%% plot results
fig = figure(2);
hold on
%f = @(param,stmI)param(1)+(param(2)-param(1))./(1+10.^((param(3)-stmI)*param(4)))
plot(stmI,m,'ko')
plot(mx_vec,f(mfit,mx_vec),'k');
plot(hfit,stmI,h,'ro');
plot(IatHmax,min(ylim),'b*');
if plotID == 0
    plot(min(xlim),HatM,'b*');
else
end
xlabel('Stimulation Intensity [mA]');
ylabel('Reflex Amplitude [mV]');
title(filename,'Interpreter','none')
legend('M-Wave(Raw)','M-Wave','H-Wave(Raw)','H-Wave','IatMax/HatM','Location','northwest');
%% save plot
savePlot = fullfile(destPath,[filename,'.bmp']);
saveas(fig,savePlot);

clear h
clear m
clear stmI
clear hweights
clear NUM
clear TXT
clear RAW
end
