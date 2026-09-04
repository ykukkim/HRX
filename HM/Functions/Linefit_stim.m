function [HMall] = Linefit_stim(AmplitudeHwave,AmplitudeMwave,AmplitudeBaseline,x1,filename)
header = {'Subject','HMratio','H_mean','H_std','M_mean','M_std','Hmax','Mmax','StmI','Bemg_mean','Bemg_std'};
HMall = header;
tmp_sub = filename;
h = AmplitudeHwave';
m = AmplitudeMwave';
stmI = x1;
bemg = AmplitudeBaseline';

meanBemg = mean(bemg);
stdBemg = std(bemg);
meanStmI = mean(stmI);
meanH = mean(h);
stdH = std(h);
maxH = max(h);
meanM = mean(m);
stdM = std(m);
maxM = max(m);

HMratio = (maxH/maxM)*100;
tmp_all = {tmp_sub,HMratio,meanH,stdH,meanM,stdM,maxH,maxM,meanStmI,meanBemg,stdBemg};
HMall = cat(1,HMall,tmp_all);
end
