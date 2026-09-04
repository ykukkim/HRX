%% Concatenation
%% Initializing the data folder
clc; close all; clear;

% ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');
ifMac = 1;
switch ifMac
    case 0
        TestDIR= '/Volumes/Macintosh HD - Data/HRX/Results/TtC';
        pathCompSep = '/';

    case 1

        TestDIR  = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\Results\TtC'; % change to the relevant Windows path.
        destPath = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\Results\';
        pathCompSep   = '\';
end

%% Directory Setting

TestDIR = dir(TestDIR);
TestDIR(strncmp({TestDIR.name}, '.', 1)) = [];

for i = 1:size(TestDIR,1)
    if strcmp(TestDIR(i).name(1:end-4), 'TtC') == 1
        load([TestDIR(i).folder,pathCompSep,TestDIR(i).name]);
        condition=fieldnames(TtC);
    end
end

% Loop through all the participants
for j=1:length(condition)

    Sub=fieldnames(TtC.(condition{j}));
    for l=1:length(Sub)
        TtC_BP.(condition{j}).CoM_b.(Sub{l})    = nanmedian(TtC.(condition{j}).(Sub{l}).TtC_CoM_BPAP,2);
        TtC_BP.(condition{j}).Sw_b.(Sub{l})     = nanmedian(TtC.(condition{j}).(Sub{l}).TtC_Sw_BPAP,2);
        TtC_BP.(condition{j}).dist_b.(Sub{l})   = TtC.(condition{j}).(Sub{l}).length;
    end
end

clear condition Sub l j

condition=fieldnames(TtC_BP);
for j=1:length(condition)
    SubCoM_b  = fieldnames(TtC_BP.(condition{j}).CoM_b);
    SubSw_b   = fieldnames(TtC_BP.(condition{j}).Sw_b);

    for l = 1:length(SubCoM_b)
        data_size_CoM_b(l) = length(TtC_BP.(condition{j}).CoM_b.(SubCoM_b{l}));
        data_size_Sw_b(l)  = length(TtC_BP.(condition{j}).Sw_b.(SubSw_b{l}));
    end

    max_size_CoM_b = max(data_size_CoM_b);
    max_size_Sw_b  = max(data_size_Sw_b);
    Y_total_CoM_b  = NaN(max_size_CoM_b,length(SubCoM_b));
    Y_total_Sw_b  = NaN(max_size_Sw_b,length(SubSw_b));

    for l=1:length(SubCoM_b)
        try
            length_total_b(l) = TtC_BP.(condition{j}).dist_b.(SubCoM_b{l});
            Y_CoM_b           = TtC_BP.(condition{j}).CoM_b.(SubCoM_b{l});
            Y_Sw_b            = TtC_BP.(condition{j}).Sw_b.(SubSw_b{l});
            Y_CoM_b           = Y_CoM_b';
            Y_Sw_b            = Y_Sw_b';
            [y_CoM_b,~]       = deal(nanmedian(Y_CoM_b),nanstd(Y_CoM_b));
            [y_Sw_b,~]        = deal(nanmedian(Y_Sw_b),nanstd(Y_Sw_b));
            Y_total_CoM_b(1:length(Y_CoM_b'),l)= Y_CoM_b(1:length(Y_CoM_b'))';
            Y_total_Sw_b(1:length(Y_Sw_b'),l)  = Y_Sw_b(1:length(Y_Sw_b'))';
        catch
            fprintf('%s doesn not exist\n',SubCoM_b{l});
        end
    end

    TtCCoM_b.(condition{j})    = Y_total_CoM_b;
    TtCSw_b.(condition{j})     = Y_total_Sw_b;
    TtClength_b.(condition{j}) = median(length_total_b);

end

condition=fieldnames(TtCCoM_b);
linS = {'-r','--m','--k','-.g','-b'};
legend_name = {'20-','40-', 'Normg', '20+','40+'};
legend_name_Kp = {'20-','40-','Normg','20+','40+'};

TtCF_P = figure;
HF_P   = figure;

for j=1:length(condition)
    %% TtC COM_Bp
    figure(TtCF_P)
    x_CoM_b = nanmedian(TtCCoM_b.(condition{j}),2);
    idx_CoM_b = find(x_CoM_b <= 0);
    YourLength_CoM_b = length(x_CoM_b(1:idx_CoM_b(1)));
    data_length_CoM_b= linspace(0,round(YourLength_CoM_b/TtClength_b.(condition{j})*100),YourLength_CoM_b);
    new_length_CoM_b=0:round(YourLength_CoM_b/TtClength_b.(condition{j})*100);
    TtC_normed_CoM_b=spline(data_length_CoM_b,x_CoM_b(1:idx_CoM_b(1)),new_length_CoM_b);
    idx_CoM_b_zero = find(TtC_normed_CoM_b >= 0);
    ss(j) = plot(TtC_normed_CoM_b(1:length(idx_CoM_b_zero)),linS{j},'linewidth',1.2);
    hold on;

    %% TtC Sw_Bp
    x_Sw_b = nanmedian(TtCSw_b.(condition{j}),2);
    idx_Sw_b = find(x_Sw_b <= 0);
    YourLength_Sw_b = length(x_Sw_b(1:idx_Sw_b(1)+3));
    data_length_Sw_b= linspace(0,round(YourLength_Sw_b/TtClength_b.(condition{j})*100),YourLength_Sw_b);
    new_length_Sw_b=0:round(YourLength_Sw_b/TtClength_b.(condition{j})*100);
    TtC_normed_Sw_b=spline(data_length_Sw_b,x_Sw_b(1:idx_Sw_b(1)+3),new_length_Sw_b);
    plot(TtC_normed_Sw_b,linS{j},'linewidth',1.2);

    %% Kp
    figure(HF_P)
    %     min_length = min(length(x_CoM_b(1:idx_CoM_b(1))),length(x_Sw_b(1:idx_Sw_b(1))));
    %     for sd = 1:min_length
    %         Kp(sd) = x_Sw_b(sd)/x_CoM_b(sd);
    %     end
    Kp = x_Sw_b/x_CoM_b;
    idx_kp = find(Kp(:,1) <= 0);
    YourLength_Kp  = length(Kp(1:idx_kp(1)));
    data_length_Kp = linspace(0,round(YourLength_Kp/TtClength_b.(condition{j})*100),YourLength_Kp);
    new_length_Kp  = 0:round(YourLength_Kp/TtClength_b.(condition{j})*100);
    TtC_normed_Kp  = spline(data_length_Kp,Kp(1:idx_kp(1)),new_length_Kp);
    dd(j) = plot(TtC_normed_Kp,linS{j},'linewidth',1.2);hold on;

end

figure(TtCF_P);
legend([ss(2),ss(1),ss(3),ss(4),ss(5)],legend_name{2},legend_name{1},legend_name{3},legend_name{4},legend_name{5},'Location','northeast','Orientation','vertical')
ylabel({'TtC [S] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
xlabel({'Swing Phase[To - HS%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
ylim([0 0.8]);
str = 'SwingFoot TtC';
dim = [.2 .5 .3 .3];
annotation('textbox',dim,'String',str,'FitBoxToText','on');
str = 'CoM TtC';
dim = [.14 .14 .1 .1];
annotation('textbox',dim,'String',str,'FitBoxToText','on');
figure(HF_P);
legend([dd(2),dd(1),dd(3),dd(4),dd(5)],legend_name{2},legend_name{1},legend_name{3},legend_name{4},legend_name{5},'Location','northeast','Orientation','vertical')
ylabel({'Coupling Ratio '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
xlabel({'Swing Phase[To - HS%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);xlim([0 90])
% print(TtCF_P,'-dpdf','-r600'); print(HF_P,'-dpdf','-r600');
