function[PendLeng, Average_PendLeng] = Pendulum_length(Current_COM_Data_atLHS,Current_COM_Data_atRHS,L2MA_atLHS,R2MA_atRHS)
%% Pendulum Length from Malleolus
PendLeng_Left_M = sqrt((Current_COM_Data_atLHS(:,1) - L2MA_atLHS(:,1)).^2+...
    (Current_COM_Data_atLHS(:,2) - L2MA_atLHS(:,2)).^2+...
    (Current_COM_Data_atLHS(:,3) - L2MA_atLHS(:,3)).^2);

PendLeng_Right_M = sqrt((Current_COM_Data_atRHS(:,1) - R2MA_atRHS(:,1)).^2+...
    (Current_COM_Data_atRHS(:,2) - R2MA_atRHS(:,2)).^2+...
    (Current_COM_Data_atRHS(:,3) - R2MA_atRHS(:,3)).^2);

Average_PendLeng_Left =  mean(PendLeng_Left_M);
Average_PendLeng_Right =  mean(PendLeng_Right_M);

%% Calculate XCOM in the medio-lateral direction
PendLeng = [Average_PendLeng_Left, Average_PendLeng_Right];
Average_PendLeng = mean(PendLeng);
