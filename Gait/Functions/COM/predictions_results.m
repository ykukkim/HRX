function [stats_AP_filt_atLHS_acc,stats_AP_filt_atRHS_acc,stats_ML_filt_atLHS_acc,stats_ML_filt_atRHS_acc,...
    resid_AP_filt_atLHS_acc,resid_AP_filt_atRHS_acc,resid_ML_filt_atLHS_acc,resid_ML_filt_atRHS_acc,...
    coeff_AP_filt_atLHS_acc,coeff_AP_filt_atRHS_acc,coeff_ML_filt_atLHS_acc,coeff_ML_filt_atRHS_acc,...
    coeff_int_AP_filt_atLHS_acc,coeff_int_AP_filt_atRHS_acc,coeff_int_ML_filt_atLHS_acc,coeff_int_ML_filt_atRHS_acc,...
    resid_int_AP_filt_atLHS_acc,resid_int_AP_filt_atRHS_acc,resid_int_ML_filt_atLHS_acc,resid_int_ML_filt_atRHS_acc] = predictions_results(XCOM,Patientname,Currentcondition,LeftHSLocs,RightHSLocs,leftlegdif,rightlegdif)
[b, a] = butter(4, (20/(500*0.5)));
XCOM_filt = filtfilt(b, a, XCOM);

% XCOM at Heel Strikes
XCOM_atLHS = XCOM(LeftHSLocs,:);
XCOM_atRHS = XCOM(RightHSLocs,:);

XCOM_filt_atLHS = XCOM_filt(LeftHSLocs,:);
XCOM_filt_atRHS = XCOM_filt(RightHSLocs,:);

minLength = min([length(XCOM_atRHS(:,1)), length(XCOM_atLHS(:,1)), length(leftlegdif(:,1)), length(rightlegdif(2:end,1))]);

XCOM_atRHS = XCOM_atRHS(1:minLength,:);
XCOM_filt_atRHS = XCOM_filt_atRHS(1:minLength,:);
rightlegdif = rightlegdif(1:minLength,:);

XCOM_atLHS = XCOM_atLHS(1:minLength,:);
XCOM_filt_atLHS = XCOM_filt_atLHS(1:minLength,:);
leftlegdif = leftlegdif(1:minLength,:);

% setup the sequence: determine the leading leg

[leadLeg, indleadLeg] = min([LeftHSLocs(1) RightHSLocs(1)]);

if indleadLeg == 1 % i.e. left leg is leading
    %% regression with step width and step length and their first difference for the lagging (right) leg

    footfallbalancePred_right = [ones(size(XCOM_atRHS(2:end,1))) leftlegdif(2:end,1) leftlegdif(2:end,2) rightlegdif(2:end,1) rightlegdif(2:end,2) ...
        diff(leftlegdif(:,1)) diff(leftlegdif(:,2)) diff(rightlegdif(:,1)) diff(rightlegdif(:,2))];
    balanceResponse_ML_atRHS = XCOM_atRHS(2:end,3);
    [coeff_ML_atRHS,coeff_int_ML_atRHS,resid_ML_atRHS,resid_int_ML_atRHS,stats_ML_atRHS] = regress(balanceResponse_ML_atRHS, footfallbalancePred_right);

    balanceResponse_AP_atRHS = XCOM_atRHS(2:end,1);
    [coeff_AP_atRHS,coeff_int_AP_atRHS,resid_AP_atRHS,resid_int_AP_atRHS,stats_AP_atRHS] = regress(balanceResponse_AP_atRHS, footfallbalancePred_right);

    %% regression with step width and step length and their first difference for the lagging (right) leg filtered data
    % filtered
    balanceResponse_ML_filt_atRHS = XCOM_filt_atRHS(2:end,3);
    [coeff_ML_filt_atRHS,coeff_int_ML_filt_atRHS,resid_ML_filt_atRHS,resid_int_ML_filt_atRHS,stats_ML_filt_atRHS] = regress(balanceResponse_ML_filt_atRHS, footfallbalancePred_right);

    balanceResponse_AP_filt_atRHS = XCOM_filt_atRHS(2:end,1);
    [coeff_AP_filt_atRHS,coeff_int_AP_filt_atRHS,resid_AP_filt_atRHS,resid_int_AP_filt_atRHS,stats_AP_filt_atRHS] = regress(balanceResponse_AP_filt_atRHS, footfallbalancePred_right);
    %% regression with step width and step length and their first and second difference for the lagging (right) leg

    footfallbalancePred_acc_right = [ones(size(XCOM_atRHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
        diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2)) ...
        diff(diff(leftlegdif(:,1))) diff(diff(leftlegdif(:,2))) diff(diff(rightlegdif(:,1))) diff(diff(rightlegdif(:,2)))];

    balanceResponse_ML_atRHS_acc = XCOM_atRHS(3:end,3);
    [coeff_ML_atRHS_acc,coeff_int_ML_atRHS_acc,resid_ML_atRHS_acc,resid_int_ML_atRHS_acc,stats_ML_atRHS_acc] = regress(balanceResponse_ML_atRHS_acc, footfallbalancePred_acc_right);

    balanceResponse_AP_atRHS_acc = XCOM_atRHS(3:end,1);
    [coeff_AP_atRHS_acc,coeff_int_AP_atRHS_acc,resid_AP_atRHS_acc,resid_int_AP_atRHS_acc,stats_AP_atRHS_acc] = regress(balanceResponse_AP_atRHS_acc, footfallbalancePred_acc_right);
    %% regression with step width and step length and their second difference for the lagging (right) leg: filtered data
    % filtered
    balanceResponse_ML_filt_atRHS_acc = XCOM_filt_atRHS(3:end,3);
    [coeff_ML_filt_atRHS_acc,coeff_int_ML_filt_atRHS_acc,resid_ML_filt_atRHS_acc,resid_int_ML_filt_atRHS_acc,stats_ML_filt_atRHS_acc] = regress(balanceResponse_ML_filt_atRHS_acc, footfallbalancePred_acc_right);

    balanceResponse_AP_filt_atRHS_acc = XCOM_filt_atRHS(3:end,1);
    [coeff_AP_filt_atRHS_acc,coeff_int_AP_filt_atRHS_acc,resid_AP_filt_atRHS_acc,resid_int_AP_filt_atRHS_acc,stats_AP_filt_atRHS_acc] = regress(balanceResponse_AP_filt_atRHS_acc, footfallbalancePred_acc_right);
    %% regression with step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg

    footfallbalancePred_left = [ones(size(XCOM_atLHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(2:end-1,1) rightlegdif(2:end-1,2) ...
        diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(1:end-1,1)) diff(rightlegdif(1:end-1,2))];

    balanceResponse_ML_atLHS = XCOM_atLHS(3:end,3);
    [coeff_ML_atLHS,coeff_int_ML_atLHS,resid_ML_atLHS,resid_int_ML_atLHS,stats_ML_atLHS] = regress(balanceResponse_ML_atLHS, footfallbalancePred_left);

    balanceResponse_AP_atLHS = XCOM_atLHS(3:end,1);
    [coeff_AP_atLHS,coeff_int_AP_atLHS,resid_AP_atLHS,resid_int_AP_atLHS,stats_AP_atLHS] = regress(balanceResponse_AP_atLHS, footfallbalancePred_left);

    %% regression with step width and step length and their first difference - filtered data: Shift the sequence at the start of the matrix for the leading leg
    % filtered
    balanceResponse_ML_filt_atLHS = XCOM_filt_atLHS(3:end,3);
    [coeff_ML_filt_atLHS,coeff_int_ML_filt_atLHS,resid_ML_filt_atLHS,resid_int_ML_filt_atLHS,stats_ML_filt_atLHS] = regress(balanceResponse_ML_filt_atLHS, footfallbalancePred_left);

    balanceResponse_AP_filt_atLHS = XCOM_filt_atLHS(3:end,1);
    [coeff_AP_filt_atLHS,coeff_int_AP_filt_atLHS,resid_AP_filt_atLHS,resid_int_AP_filt_atLHS,stats_AP_filt_atLHS] = regress(balanceResponse_AP_filt_atLHS, footfallbalancePred_left);

    %% regression with step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg

    footfallbalancePred_acc_left = [ones(size(XCOM_atLHS(4:end,1))) leftlegdif(4:end,1) leftlegdif(4:end,2) rightlegdif(3:end-1,1) rightlegdif(3:end-1,2) ...
        diff(leftlegdif(3:end,1)) diff(leftlegdif(3:end,2)) diff(rightlegdif(2:end-1,1)) diff(rightlegdif(2:end-1,2)) ...
        diff(diff(leftlegdif(2:end,1))) diff(diff(leftlegdif(2:end,2))) diff(diff(rightlegdif(1:end-1,1))) diff(diff(rightlegdif(1:end-1,2)))];

    balanceResponse_ML_atLHS_acc = XCOM_atLHS(4:end,3);
    [coeff_ML_atLHS_acc,coeff_int_ML_atLHS_acc,resid_ML_atLHS_acc,resid_int_ML_atLHS_acc,stats_ML_atLHS_acc] = regress(balanceResponse_ML_atLHS_acc, footfallbalancePred_acc_left);

    balanceResponse_AP_atLHS_acc = XCOM_atLHS(4:end,1);
    [coeff_AP_atLHS_acc,coeff_int_AP_atLHS_acc,resid_AP_atLHS_acc,resid_int_AP_atLHS_acc,stats_AP_atLHS_acc] = regress(balanceResponse_AP_atLHS_acc, footfallbalancePred_acc_left);

    %% filtered data: regression with step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg

    balanceResponse_ML_filt_atLHS_acc = XCOM_filt_atLHS(4:end,3);
    [coeff_ML_filt_atLHS_acc,coeff_int_ML_filt_atLHS_acc,resid_ML_filt_atLHS_acc,resid_int_ML_filt_atLHS_acc,stats_ML_filt_atLHS_acc] = regress(balanceResponse_ML_filt_atLHS_acc, footfallbalancePred_acc_left);

    balanceResponse_AP_filt_atLHS_acc = XCOM_filt_atLHS(4:end,1);
    [coeff_AP_filt_atLHS_acc,coeff_int_AP_filt_atLHS_acc,resid_AP_filt_atLHS_acc,resid_int_AP_filt_atLHS_acc,stats_AP_filt_atLHS_acc] = regress(balanceResponse_AP_filt_atLHS_acc, footfallbalancePred_acc_left);

elseif indleadLeg == 2 % i.e. right leg is leading
    %% regression lagging leg: step width and step length and their first difference - left leg
    footfallbalancePred_left = [ones(size(XCOM_atLHS(2:end,1))) leftlegdif(2:end,1) leftlegdif(2:end,2) rightlegdif(2:end,1) rightlegdif(2:end,2) ...
        diff(leftlegdif(:,1)) diff(leftlegdif(:,2)) diff(rightlegdif(:,1)) diff(rightlegdif(:,2))];

    balanceResponse_ML_atLHS = XCOM_atLHS(2:end,3);
    [coeff_ML_atLHS,coeff_int_ML_atLHS,resid_ML_atLHS,resid_int_ML_atLHS,stats_ML_atLHS] = regress(balanceResponse_ML_atLHS, footfallbalancePred_left);

    balanceResponse_AP_atLHS = XCOM_atLHS(2:end,1);
    [coeff_AP_atLHS,coeff_int_AP_atLHS,resid_AP_atLHS,resid_int_AP_atLHS,stats_AP_atLHS] = regress(balanceResponse_AP_atLHS, footfallbalancePred_left);

    %% filtered data regression lagging leg: step width and step length and their first difference - left leg
    balanceResponse_ML_filt_atLHS = XCOM_filt_atLHS(2:end,3);
    [coeff_ML_filt_atLHS,coeff_int_ML_filt_atLHS,resid_ML_filt_atLHS,resid_int_ML_filt_atLHS,stats_ML_filt_atLHS] = regress(balanceResponse_ML_filt_atLHS, footfallbalancePred_left);

    balanceResponse_AP_filt_atLHS = XCOM_filt_atLHS(2:end,1);
    [coeff_AP_filt_atLHS,coeff_int_AP_filt_atLHS,resid_AP_filt_atLHS,resid_int_AP_filt_atLHS,stats_AP_filt_atLHS] = regress(balanceResponse_AP_filt_atLHS, footfallbalancePred_left);

    %% regression lagging leg: step width and step length and their first and second difference - left leg
    footfallbalancePred_acc_left = [ones(size(XCOM_atLHS(3:end,1))) leftlegdif(3:end,1) leftlegdif(3:end,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
        diff(leftlegdif(2:end,1)) diff(leftlegdif(2:end,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2)) ...
        diff(diff(leftlegdif(:,1))) diff(diff(leftlegdif(:,2))) diff(diff(rightlegdif(:,1))) diff(diff(rightlegdif(:,2)))];

    balanceResponse_ML_atLHS_acc = XCOM_atLHS(3:end,3);
    [coeff_ML_atLHS_acc,coeff_int_ML_atLHS_acc,resid_ML_atLHS_acc,resid_int_ML_atLHS_acc,stats_ML_atLHS_acc] = regress(balanceResponse_ML_atLHS_acc, footfallbalancePred_acc_left);

    balanceResponse_AP_atLHS_acc = XCOM_atLHS(3:end,1);
    [coeff_AP_atLHS_acc,coeff_int_AP_atLHS_acc,resid_AP_atLHS_acc,resid_int_AP_atLHS_acc,stats_AP_atLHS_acc] = regress(balanceResponse_AP_atLHS_acc, footfallbalancePred_acc_left);

    %% filtered data regression lagging leg: step width and step length and their first and second difference - left leg
    balanceResponse_ML_filt_atLHS_acc = XCOM_filt_atLHS(3:end,3);
    [coeff_ML_filt_atLHS_acc,coeff_int_ML_filt_atLHS_acc,resid_ML_filt_atLHS_acc,resid_int_ML_filt_atLHS_acc,stats_ML_filt_atLHS_acc] = regress(balanceResponse_ML_filt_atLHS_acc, footfallbalancePred_acc_left);

    balanceResponse_AP_filt_atLHS_acc = XCOM_filt_atLHS(3:end,1);
    [coeff_AP_filt_atLHS_acc,coeff_int_AP_filt_atLHS_acc,resid_AP_filt_atLHS_acc,resid_int_AP_filt_atLHS_acc,stats_AP_filt_atLHS_acc] = regress(balanceResponse_AP_filt_atLHS_acc, footfallbalancePred_acc_left);

    %% regression leading leg: step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg
    footfallbalancePred_right = [ones(size(XCOM_atRHS(3:end,1))) leftlegdif(2:end-1,1) leftlegdif(2:end-1,2) rightlegdif(3:end,1) rightlegdif(3:end,2) ...
        diff(leftlegdif(1:end-1,1)) diff(leftlegdif(1:end-1,2)) diff(rightlegdif(2:end,1)) diff(rightlegdif(2:end,2))];

    balanceResponse_ML_atRHS = XCOM_atRHS(3:end,3);
    [coeff_ML_atRHS,coeff_int_ML_atRHS,resid_ML_atRHS,resid_int_ML_atRHS,stats_ML_atRHS] = regress(balanceResponse_ML_atRHS, footfallbalancePred_right);

    balanceResponse_AP_atRHS = XCOM_atRHS(3:end,1);
    [coeff_AP_atRHS,coeff_int_AP_atRHS,resid_AP_atRHS,resid_int_AP_atRHS,stats_AP_atRHS] = regress(balanceResponse_AP_atRHS, footfallbalancePred_right);

    %% filtered data regression leading leg: step width and step length and their first difference: Shift the sequence at the start of the matrix for the leading leg
    balanceResponse_ML_filt_atRHS = XCOM_filt_atRHS(3:end,3);
    [coeff_ML_filt_atRHS,coeff_int_ML_filt_atRHS,resid_ML_filt_atRHS,resid_int_ML_filt_atRHS,stats_ML_filt_atRHS] = regress(balanceResponse_ML_filt_atRHS, footfallbalancePred_right);

    balanceResponse_AP_filt_atRHS = XCOM_filt_atRHS(3:end,1);
    [coeff_AP_filt_atRHS,coeff_int_AP_filt_atRHS,resid_AP_filt_atRHS,resid_int_AP_filt_atRHS,stats_AP_filt_atRHS] = regress(balanceResponse_AP_filt_atRHS, footfallbalancePred_right);

    %% regression leading leg: step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg
    footfallbalancePred_acc_right = [ones(size(XCOM_atRHS(4:end,1))) leftlegdif(3:end-1,1) leftlegdif(3:end-1,2) rightlegdif(4:end,1) rightlegdif(4:end,2) ...
        diff(leftlegdif(2:end-1,1)) diff(leftlegdif(2:end-1,2)) diff(rightlegdif(3:end,1)) diff(rightlegdif(3:end,2)) ...
        diff(diff(leftlegdif(1:end-1,1))) diff(diff(leftlegdif(1:end-1,2))) diff(diff(rightlegdif(2:end,1))) diff(diff(rightlegdif(2:end,2)))];

    balanceResponse_ML_atRHS_acc = XCOM_atRHS(4:end,3);
    [coeff_ML_atRHS_acc,coeff_int_ML_atRHS_acc,resid_ML_atRHS_acc,resid_int_ML_atRHS_acc,stats_ML_atRHS_acc] = regress(balanceResponse_ML_atRHS_acc, footfallbalancePred_acc_right);

    balanceResponse_AP_atRHS_acc = XCOM_atRHS(4:end,1);
    [coeff_AP_atRHS_acc,coeff_int_AP_atRHS_acc,resid_AP_atRHS_acc,resid_int_AP_atRHS_acc,stats_AP_atRHS_acc] = regress(balanceResponse_AP_atRHS_acc, footfallbalancePred_acc_right);

    %% filtered data regression leading leg: step width and step length and their first and second difference: Shift the sequence at the start of the matrix for the leading leg
    balanceResponse_ML_filt_atRHS_acc = XCOM_filt_atRHS(4:end,3);
    [coeff_ML_filt_atRHS_acc,coeff_int_ML_filt_atRHS_acc,resid_ML_filt_atRHS_acc,resid_int_ML_filt_atRHS_acc,stats_ML_filt_atRHS_acc] = regress(balanceResponse_ML_filt_atRHS_acc, footfallbalancePred_acc_right);

    balanceResponse_AP_filt_atRHS_acc = XCOM_filt_atRHS(4:end,1);
    [coeff_AP_filt_atRHS_acc,coeff_int_AP_filt_atRHS_acc,resid_AP_filt_atRHS_acc,resid_int_AP_filt_atRHS_acc,stats_AP_filt_atRHS_acc] = regress(balanceResponse_AP_filt_atRHS_acc, footfallbalancePred_acc_right);
    %% Store the Data
    % Storing results for Acc + filt_XCOM -> AP,ML at LHS and RHS

end
