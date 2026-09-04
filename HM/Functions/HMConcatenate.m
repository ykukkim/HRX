function [HMall] = HMConcatenate(HStoMidST, MidSTtoHO,filename)

header = {'Subject','HMratio(HSMST)','H_mean(HSMST)','H_std(HSMST)','Hmax(HSMST)','M_mean(HSMST)','M_std(HSMST)','Mmax(HSMST)','StmI(HSMST)',...
    'Bemg_mean(HSMST)','Bemg_Std(HSMST)','Max_Bemg(HSMST)','Gait Phase Mean(%)(HSMST)','Std GP(HSMST)','Max_GP(HSMST)',...
    'HMratio(MSTHO)','H_mean','H_std(MSTHO)','Hmax(MSTHO)','M_mean(MSTHO)','M_std(MSTHO)','Mmax(MSTHO)','StmI(MSTHO)',...
    'Bemg_mean(MSTHO)','Bemg_Std(MSTHO)','Max_Bemg(MSTHO)','Gait Phase Mean(%)(MSTHO)','Std GP(MSTHO)','Max_GP(MSTHO)'};
HMall_Summary = header;

header = {'Subject','HMratio(HSMST)','HWave(mV P-P)(HSMST)','MWave(mv P-P)(HSMST)','StmI(HSMST)',...
    'Bemg(HSMST)','Gait Phase(%)(HSMST)','LocT(HSMST)','LocHS(HSMST)',...
    'HMratio(MSTHO)','HWave(mV P-P)(MSTHO)','MWave(mv P-P)(MSTHO)','StmI(MSTHO)',...
    'Bemg(MSTHO)','Gait Phase(%)(MSTHO)','LocT(MSTHO)','LocHS(MSTHO)'};

HMall_Raw = header;
tmp_sub = filename(1:13);

if isequal(MidSTtoHO,0)

h_HStoMidST = HStoMidST.HWave;
m_HStoMidST = HStoMidST.MWave;
stmI_HStoMidST = HStoMidST.StimInt;
bemg_HStoMidST = HStoMidST.Baseline;
locT_HStoMidST = HStoMidST.LocT;
locHS_HStoMidST = HStoMidST.LocHS;
GaitPhase_HStoMidST = HStoMidST.PerGait;

meanBemg_HStoMidST = mean(bemg_HStoMidST);
meanStmI_HStoMidST = mean(stmI_HStoMidST);
meanH_HStoMidST = mean(h_HStoMidST);
meanM_HStoMidST = mean(m_HStoMidST);
meanGP_HStoMidST = mean(GaitPhase_HStoMidST);

stdH_HStoMidST = std(h_HStoMidST);
stdM_HStoMidST = std(m_HStoMidST);
stdB_HStoMidST = std(bemg_HStoMidST);
stdGP_HStoMidST = std(GaitPhase_HStoMidST);

maxH_HStoMidST= max(h_HStoMidST);
maxM_HStoMidST = max(m_HStoMidST);
maxB_HStoMidST= max(bemg_HStoMidST);
maxGP_HStoMidST = max(GaitPhase_HStoMidST);

h_MidSTHO = 0;
m_MidSTHO = 0;
stmI_MidSTHO = 0;
bemg_MidSTHO = 0;
locT_MidSTHO = 0;
locHS_MidSTHO = 0;
GaitPhase_MidSTHO = 0;

meanBemg_MidSTHO = mean(bemg_MidSTHO);
meanStmI_MidSTHO = mean(stmI_MidSTHO);
meanH_MidSTHO = mean(h_MidSTHO);
meanM_MidSTHO = mean(m_MidSTHO);
meanGP_MidSTHO = mean(GaitPhase_MidSTHO);

stdH_MidSTHO = std(h_MidSTHO);
stdM_MidSTHO = std(m_MidSTHO);
stdB_MidSTHO = std(bemg_MidSTHO);
stdGP_MidSTHO = std(GaitPhase_MidSTHO);

maxB_MidSTHO = max(bemg_MidSTHO);
maxM_MidSTHO = max(m_MidSTHO);
maxH_MidSTHO = max(h_MidSTHO);
maxGP_MidSTHO = max(GaitPhase_MidSTHO);

HMratio_HStoMidST = (maxH_HStoMidST/maxM_HStoMidST)*100;
HMratio_MidSTHO = 0;

elseif isequal(HStoMidST,0)

h_MidSTHO = MidSTtoHO.HWave;
m_MidSTHO = MidSTtoHO.MWave;
stmI_MidSTHO = MidSTtoHO.StimInt;
bemg_MidSTHO = MidSTtoHO.Baseline;
locT_MidSTHO = MidSTtoHO.LocT;
locHS_MidSTHO = MidSTtoHO.LocHS;
GaitPhase_MidSTHO = MidSTtoHO.PerGait;

meanBemg_MidSTHO = mean(bemg_MidSTHO);
meanStmI_MidSTHO = mean(stmI_MidSTHO);
meanH_MidSTHO = mean(h_MidSTHO);
meanM_MidSTHO = mean(m_MidSTHO);
meanGP_MidSTHO = mean(GaitPhase_MidSTHO);

stdH_MidSTHO = std(h_MidSTHO);
stdM_MidSTHO = std(m_MidSTHO);
stdB_MidSTHO = std(bemg_MidSTHO);
stdGP_MidSTHO = std(GaitPhase_MidSTHO);

maxB_MidSTHO = max(bemg_MidSTHO);
maxM_MidSTHO = max(m_MidSTHO);
maxH_MidSTHO = max(h_MidSTHO);
maxGP_MidSTHO = max(GaitPhase_MidSTHO);

h_HStoMidST = 0;
m_HStoMidST =  0;
stmI_HStoMidST =  0;
bemg_HStoMidST =  0;
locT_HStoMidST =  0;
locHS_HStoMidST =  0;
GaitPhase_HStoMidST =  0;

meanBemg_HStoMidST = mean(bemg_HStoMidST);
meanStmI_HStoMidST = mean(stmI_HStoMidST);
meanH_HStoMidST = mean(h_HStoMidST);
meanM_HStoMidST = mean(m_HStoMidST);
meanGP_HStoMidST = mean(GaitPhase_HStoMidST);

stdH_HStoMidST = std(h_HStoMidST);
stdM_HStoMidST = std(m_HStoMidST);
stdB_HStoMidST = std(bemg_HStoMidST);
stdGP_HStoMidST = std(GaitPhase_HStoMidST);

maxH_HStoMidST= max(h_HStoMidST);
maxM_HStoMidST = max(m_HStoMidST);
maxB_HStoMidST= max(bemg_HStoMidST);
maxGP_HStoMidST = max(GaitPhase_HStoMidST);

HMratio_HStoMidST = 0;
HMratio_MidSTHO = (maxH_MidSTHO/maxM_MidSTHO)*100;

else

h_HStoMidST = HStoMidST.HWave;
m_HStoMidST = HStoMidST.MWave;
stmI_HStoMidST = HStoMidST.StimInt;
bemg_HStoMidST = HStoMidST.Baseline;
locT_HStoMidST = HStoMidST.LocT;
locHS_HStoMidST = HStoMidST.LocHS;
GaitPhase_HStoMidST = HStoMidST.PerGait;

meanBemg_HStoMidST = mean(bemg_HStoMidST);
meanStmI_HStoMidST = mean(stmI_HStoMidST);
meanH_HStoMidST = mean(h_HStoMidST);
meanM_HStoMidST = mean(m_HStoMidST);
meanGP_HStoMidST = mean(GaitPhase_HStoMidST);

stdH_HStoMidST = std(h_HStoMidST);
stdM_HStoMidST = std(m_HStoMidST);
stdB_HStoMidST = std(bemg_HStoMidST);
stdGP_HStoMidST = std(GaitPhase_HStoMidST);

maxH_HStoMidST= max(h_HStoMidST);
maxM_HStoMidST = max(m_HStoMidST);
maxB_HStoMidST= max(bemg_HStoMidST);
maxGP_HStoMidST = max(GaitPhase_HStoMidST);

h_MidSTHO = MidSTtoHO.HWave;
m_MidSTHO = MidSTtoHO.MWave;
stmI_MidSTHO = MidSTtoHO.StimInt;
bemg_MidSTHO = MidSTtoHO.Baseline;
locT_MidSTHO = MidSTtoHO.LocT;
locHS_MidSTHO = MidSTtoHO.LocHS;
GaitPhase_MidSTHO = MidSTtoHO.PerGait;

meanBemg_MidSTHO = mean(bemg_MidSTHO);
meanStmI_MidSTHO = mean(stmI_MidSTHO);
meanH_MidSTHO = mean(h_MidSTHO);
meanM_MidSTHO = mean(m_MidSTHO);
meanGP_MidSTHO = mean(GaitPhase_MidSTHO);

stdH_MidSTHO = std(h_MidSTHO);
stdM_MidSTHO = std(m_MidSTHO);
stdB_MidSTHO = std(bemg_MidSTHO);
stdGP_MidSTHO = std(GaitPhase_MidSTHO);

maxB_MidSTHO = max(bemg_MidSTHO);
maxM_MidSTHO = max(m_MidSTHO);
maxH_MidSTHO = max(h_MidSTHO);
maxGP_MidSTHO = max(GaitPhase_MidSTHO);

HMratio_HStoMidST = (maxH_HStoMidST/maxM_HStoMidST)*100;
HMratio_MidSTHO = (maxH_MidSTHO/maxM_MidSTHO)*100;
end


tmp_all = {tmp_sub,HMratio_HStoMidST,meanH_HStoMidST,stdH_HStoMidST,maxH_HStoMidST,meanM_HStoMidST,stdM_HStoMidST,maxM_HStoMidST,meanStmI_HStoMidST,...
    meanBemg_HStoMidST,stdB_HStoMidST,maxB_HStoMidST,meanGP_HStoMidST,stdGP_HStoMidST,maxGP_HStoMidST,...
    HMratio_MidSTHO,meanH_MidSTHO,stdH_MidSTHO,maxH_MidSTHO,meanM_MidSTHO,stdM_MidSTHO,maxM_MidSTHO,meanStmI_MidSTHO,...
    meanBemg_MidSTHO,stdB_MidSTHO,maxB_MidSTHO,meanGP_MidSTHO,stdGP_MidSTHO,maxGP_MidSTHO};

HMall = cat(1,HMall_Summary,tmp_all);

end
