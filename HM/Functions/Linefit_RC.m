function [HMall] = Linefit_RC(AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,destPath,filename)
header = {'Subject','HMratio','H_r2','H_rmse','M_r2','M_rmse','Hmax','Mmax','70Hmax','StimHmax','Stim70Hmax','Bemg'};
HMall = header;
tmp_sub = filename;
h = AmplitudeHwave;
m = AmplitudeMwave;
stmI = x1*1000;
bemg = mean(AmplitudeBaseline');
mx_vec = min(stmI):(max(stmI)-min(stmI))/(length(stmI)-1):max(stmI);

for i = 1:length(h)
    if h(i) >= (mean(h)*1.1) && (h(i) <= 0.75*max(h))
        hweights(i) = 10;
    else
        hweights(i) = 1;
    end
end

[hfit, hgood] = fit(stmI,h,'gauss1','Weight',hweights);

h_wave = feval(hfit,stmI);
[smoothH,IDofH] = max(h_wave);

QofH = [hgood.rsquare; hgood.rmse];
hMat = [stmI'; h_wave']';

IatHmax = stmI(IDofH,1);
[~,IDof70Hmax] = find(hMat(1:IDofH,2) < (smoothH*0.75), 1, 'last' );
IDstm = hMat(IDof70Hmax,1);
HatM = feval(hfit,IDstm);

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
% mfit = [0.0549 0.76 95.3430 0.123];
mgood = mgood_tmp;
m_r2 = m_r2_tmp;
m_rmse = m_rmse_tmp;

f = @(param,stmI)param(1)+(param(2)-param(1))./(1+10.^((param(3)-stmI)*param(4)));
QofM = [m_r2; m_rmse];
smoothM = max(f(mfit,stmI));

mMat = [mx_vec;f(mfit,mx_vec)]';

HMratio = (smoothH/smoothM)*100;
IatHmax = stmI(IDofH,1);
% [~,IDofM] = max(find(mMat(:,2) < (smoothM*0.3)));
% IDstm = mMat(IDofM,1);

plotID = isempty(HatM);

tmp_all = {tmp_sub,HMratio,QofH(1,1),QofH(2,1),QofM(1,1),QofM(2,1),smoothH,smoothM,HatM,IatHmax,IDstm,bemg};
HMall = cat(1,HMall,tmp_all);

%% plot results
fig = figure;
hold on
plot(stmI,m,'ko');plot(mx_vec,f(mfit,mx_vec),'k');
plot(hfit,stmI,h,'ro');plot(IatHmax,smoothH,'b*');

if plotID == 0
    HatM = 0.9452;
    IDstm = 42;
    plot(IDstm,HatM,'g*');
else
end

xlabel('Stimulation Intensity [mA]'); ylabel('Reflex Amplitude [mV]');title(filename,'Interpreter','none')
legend('M-Wave(Raw)','M-Wave','H-Wave(Raw)','H-Wave','IatHMax','Iat70HMax','Location','northwest');

% %% save plot
% savePlot = fullfile(destPath,[filename,'.bmp']);
% saveas(fig,savePlot);
% close;
%
% clear h
% clear m
% clear stmI
% clear hweights
% clear NUM
% clear TXT
clear RAW
end
