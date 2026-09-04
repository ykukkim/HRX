function[PredictionResults] = MarginofStability(LTO3_Kin,LTO5_Kin,...
    LTO1_atLHS,LTO5_atLHS,LHEE_atLHS,XCOM_atLHS,...
    RTO3_Kin,RTO5_Kin,...
    RTO1_atRHS,RTO5_atRHS,RHEE_atRHS,XCOM_atRHS,...
    XCOM,Patientname,Currentcondition,LeftHSLocs,RightHSLocs,leftlegdif,rightlegdif)


%% Margin of Stability Calculation
% with corrected orientation
%           Column 1 is MedioLateral direction (x)
%           Column 2 is Anteroposterior direction (y)
%           Column 3 is Superior - Inferior direction (z)

stfr_X = 110; endfr_X = 250;
frdiff_X = endfr_X-stfr_X;
stfr_Y = 100; endfr_Y = 260;
frdiff_Y = endfr_Y-stfr_Y;
stfr_Z = 110; endfr_Z = 240;
frdiff_Z = endfr_Z-stfr_Z;


for i=1:length(LeftHSLocs)-2
    X_left(i) = LTO3_Kin(LeftHSLocs(i)+endfr_X,1)-LTO3_Kin(LeftHSLocs(i)+stfr_X,1);
    X_right(i) = RTO3_Kin(RightHSLocs(i)+endfr_X,1)-RTO3_Kin(RightHSLocs(i)+stfr_X,1);
    Y_left(i) = LTO5_Kin(LeftHSLocs(i)+endfr_Y,2)-LTO5_Kin(LeftHSLocs(i)+stfr_Y,2);
    Y_right(i) = RTO5_Kin(RightHSLocs(i)+endfr_Y,2)-RTO5_Kin(RightHSLocs(i)+stfr_Y,2);
    Z_left(i) = LTO3_Kin(LeftHSLocs(i)+endfr_Z,3)-LTO3_Kin(LeftHSLocs(i)+stfr_Z,3);
    Z_right(i) = RTO3_Kin(RightHSLocs(i)+endfr_Z,3)-RTO3_Kin(RightHSLocs(i)+stfr_Z,3);
    left_vector(i,1)=X_left(i); left_vector(i,2)=Y_left(i); left_vector(i,3)=Z_left(i);
    right_vector(i,1)=X_right(i); right_vector(i,2)=Y_right(i); right_vector(i,3)=Z_right(i);
end

X_left_mean = mean(X_left);
X_right_mean = mean(X_right);
Y_left_mean = mean(Y_left);
Y_right_mean = mean(Y_right);
Z_left_mean = mean(Z_left);
Z_right_mean = mean(Z_right);

vec1 = [(X_left_mean+X_right_mean)/2;(Y_left_mean+Y_right_mean)/2;(Z_left_mean+Z_right_mean)/2];
vec2 = [0;1;0];

[R_m] = getRotM(vec1,vec2);

% Margin of Stability Calculation
XCOM_atLHS_rot = R_m*XCOM_atLHS';
XCOM_atLHS_rot = XCOM_atLHS_rot';
LTO5_atLHS_rot = R_m*LTO5_atLHS';
LTO5_atLHS_rot = LTO5_atLHS_rot';
LTO1_atLHS_rot = R_m*LTO1_atLHS';
LTO1_atLHS_rot = LTO1_atLHS_rot';
LHEE_atLHS_rot = R_m*LHEE_atLHS';
LHEE_atLHS_rot = LHEE_atLHS_rot';

XCOM_atRHS_rot = R_m*XCOM_atRHS';
XCOM_atRHS_rot = XCOM_atRHS_rot';
RTO5_atRHS_rot = R_m*RTO5_atRHS';
RTO5_atRHS_rot = RTO5_atRHS_rot';
RTO1_atRHS_rot = R_m*RTO1_atRHS';
RTO1_atRHS_rot = RTO1_atRHS_rot';
RHEE_atRHS_rot = R_m*RHEE_atRHS';
RHEE_atRHS_rot = RHEE_atRHS_rot';

% Deepak
MOS_Left(:,1) = XCOM_atLHS(:,1) - LTO5_atLHS(:,1);
MOS_Left(:,2) = XCOM_atLHS(:,2) - LTO1_atLHS(:,2);
MOS_Left(:,3) = XCOM_atLHS(:,3) - LHEE_atLHS(:,3);

MOS_Right(:,1) = XCOM_atRHS(:,1) - RTO5_atRHS(:,1);
MOS_Right(:,2) = XCOM_atRHS(:,2) - RTO1_atRHS(:,2);
MOS_Right(:,3) = XCOM_atRHS(:,3) - RHEE_atRHS(:,3);

% Milos
MOS_Left_rot(:,1) = XCOM_atLHS_rot(:,1) - LTO5_atLHS_rot(:,1);
MOS_Left_rot(:,2) = XCOM_atLHS_rot(:,2) - LTO1_atLHS_rot(:,2);
MOS_Left_rot(:,3) = XCOM_atLHS_rot(:,3) - LHEE_atLHS_rot(:,3);

MOS_Right_rot(:,1) = XCOM_atRHS_rot(:,1) - RTO5_atRHS_rot(:,1);
MOS_Right_rot(:,2) = XCOM_atRHS_rot(:,2) - RTO1_atRHS_rot(:,2);
MOS_Right_rot(:,3) = XCOM_atRHS_rot(:,3) - RHEE_atRHS_rot(:,3);

XCoM.(Patientname).(Currentcondition).XCoM = XCOM;
XCoM.(Patientname).(Currentcondition).XCoM_atLHS = XCOM_atLHS;
XCoM.(Patientname).(Currentcondition).XCoM_atRHS = XCOM_atRHS;
XCoM.(Patientname).(Currentcondition).MOS_Left = MOS_Left;
XCoM.(Patientname).(Currentcondition).MOS_Right = MOS_Right;
XCoM.(Patientname).(Currentcondition).MOS_Left_rot = MOS_Left_rot;
XCoM.(Patientname).(Currentcondition).MOS_Right_rot = MOS_Right_rot;

[stats_AP_filt_atLHS_acc,stats_AP_filt_atRHS_acc,stats_ML_filt_atLHS_acc,stats_ML_filt_atRHS_acc,...
    resid_AP_filt_atLHS_acc,resid_AP_filt_atRHS_acc,resid_ML_filt_atLHS_acc,resid_ML_filt_atRHS_acc,...
    coeff_AP_filt_atLHS_acc,coeff_AP_filt_atRHS_acc,coeff_ML_filt_atLHS_acc,coeff_ML_filt_atRHS_acc,...
    coeff_int_AP_filt_atLHS_acc,coeff_int_AP_filt_atRHS_acc,coeff_int_ML_filt_atLHS_acc,coeff_int_ML_filt_atRHS_acc,...
    resid_int_AP_filt_atLHS_acc,resid_int_AP_filt_atRHS_acc,resid_int_ML_filt_atLHS_acc,resid_int_ML_filt_atRHS_acc] = predictions_results(XCOM,Patientname,Currentcondition,LeftHSLocs,RightHSLocs,leftlegdif,rightlegdif);
% Stats
PredictionResults.AP_LHS.stats = stats_AP_filt_atLHS_acc;
PredictionResults.AP_RHS.stats = stats_AP_filt_atRHS_acc;
PredictionResults.ML_LHS.stats = stats_ML_filt_atLHS_acc;
PredictionResults.ML_RHS.stats = stats_ML_filt_atRHS_acc;

% Residuals
PredictionResults.AP_LHS.residuals = resid_AP_filt_atLHS_acc;
PredictionResults.AP_RHS.residuals = resid_AP_filt_atRHS_acc;
PredictionResults.ML_LHS.residuals = resid_ML_filt_atLHS_acc;
PredictionResults.ML_RHS.residuals = resid_ML_filt_atRHS_acc;

% Coefficient Estimates
PredictionResults.AP_LHS.coeffestimates = coeff_AP_filt_atLHS_acc;
PredictionResults.AP_RHS.coeffestimates = coeff_AP_filt_atRHS_acc;
PredictionResults.ML_LHS.coeffestimates = coeff_ML_filt_atLHS_acc;
PredictionResults.ML_RHS.coeffestimates = coeff_ML_filt_atRHS_acc;

% Coefficient Estimates - 95% Confid Intervals
PredictionResults.AP_LHS.confidintervals = coeff_int_AP_filt_atLHS_acc;
PredictionResults.AP_RHS.confidintervals = coeff_int_AP_filt_atRHS_acc;
PredictionResults.ML_LHS.confidintervals = coeff_int_ML_filt_atLHS_acc;
PredictionResults.ML_RHS.confidintervals = coeff_int_ML_filt_atRHS_acc;

% rintervals to diagnose outliers
PredictionResults.AP_LHS.rintervals = resid_int_AP_filt_atLHS_acc;
PredictionResults.AP_RHS.rintervals = resid_int_AP_filt_atRHS_acc;
PredictionResults.ML_LHS.rintervals = resid_int_ML_filt_atLHS_acc;
PredictionResults.ML_RHS.rintervals = resid_int_ML_filt_atRHS_acc;
