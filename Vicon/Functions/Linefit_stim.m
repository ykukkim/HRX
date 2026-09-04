function [HMall] = Linefit_stim(AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,filename)
header = {'Subject','HMratio','H_mean','H_std','M_mean','M_std','Hmax','Mmax','StmI','Bemg'};
HMall = header;
tmp_sub = filename(1:13);
h = AmplitudeHwave';
m = AmplitudeMwave';
stmI = x1*10';
bemg = AmplitudeBaseline';

meanBemg = mean(bemg);
meanStmI = mean(stmI);
meanH = mean(h);
stdH = std(h);
maxH = max(h);
meanM = mean(m);
stdM = mean(m);
maxM = max(m);

HMratio = (maxH/maxM)*100;
tmp_all = {tmp_sub,HMratio,meanH,stdH,meanM,stdM,maxH,maxM,meanStmI,meanBemg};
HMall = cat(1,HMall,tmp_all);
end
