% %% Concatenation
% %% Initializing the data folder
% clc; close all; clear;
%
% % ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');
% ifMac = 1;
% switch ifMac
%     case 0
% %         TestDIR= '/Volumes/Macintosh HD - Data/HRX/Results/TtC';
%         pathCompSep = '/';
%
%     case 1
%
%         TestDIR  = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\Results\TtC'; % change to the relevant Windows path.
%         destPath = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\Results\';
%         pathCompSep   = '\';
% end
%
% %% Directory Setting
%
% TestDIR = dir(TestDIR);
% TestDIR(strncmp({TestDIR.name}, '.', 1)) = [];
%
% for i = 1:size(TestDIR,1)
%     if strcmp(TestDIR(i).name(1:end-4), 'TtC') == 1
%         load([TestDIR(i).folder,pathCompSep,TestDIR(i).name]);
%         condition=fieldnames(TtC);
%     end
% end

% Loop through all the participants
for j=1:length(condition)

    Sub=fieldnames(TtC.(condition{j}));
    for l=1:length(Sub)
        TtC_AP.(condition{j}).CoM_a.(Sub{l})    = nanmedian(TtC.(condition{j}).(Sub{l}).TtC_CoM_APAP,2);
        TtC_AP.(condition{j}).Sw_a.(Sub{l})     = nanmedian(TtC.(condition{j}).(Sub{l}).TtC_Sw_APAP,2);
        TtC_AP.(condition{j}).dist_a.(Sub{l})   = TtC.(condition{j}).(Sub{l}).length;
    end
end

clear condition Sub l j

condition=fieldnames(TtC_AP);
for j=1:length(condition)
    SubCoM_a    = fieldnames(TtC_AP.(condition{j}).CoM_a);
    SubSw_a     = fieldnames(TtC_AP.(condition{j}).Sw_a);

    for l = 1:length(SubCoM_a)
        data_size_CoM_a(l) = length(TtC_AP.(condition{j}).CoM_a.(SubCoM_a{l}));
        data_size_Sw_a(l)  = length(TtC_AP.(condition{j}).Sw_a.(SubSw_a{l}));
    end

    max_size_CoM_a = max(data_size_CoM_a);
    max_size_Sw_a  = max(data_size_Sw_a);
    Y_total_CoM_a  = NaN(max_size_CoM_a,length(SubCoM_a));
    Y_total_Sw_a   = NaN(max_size_Sw_a,length(SubSw_a));

    for l=1:length(SubCoM_a)
        try
            length_total_a(l) = TtC_AP.(condition{j}).dist_a.(SubCoM_a{l});
            Y_CoM_a           = TtC_AP.(condition{j}).CoM_a.(SubCoM_a{l});
            Y_Sw_a            = TtC_AP.(condition{j}).Sw_a.(SubSw_a{l});
            Y_CoM_a           = Y_CoM_a';
            Y_Sw_a            = Y_Sw_a';
            [y_CoM_b,~]       = deal(nanmedian(Y_CoM_a),nanstd(Y_CoM_a));
            [y_Sw_b,~]        = deal(nanmedian(Y_Sw_a),nanstd(Y_Sw_a));
            Y_total_CoM_a(1:length(Y_CoM_a'),l)= Y_CoM_a(1:length(Y_CoM_a'))';
            Y_total_Sw_a(1:length(Y_Sw_a'),l)  = Y_Sw_a(1:length(Y_Sw_a'))';
        catch
            fprintf('%s doesn not exist\n',SubCoM_a{l});
        end
    end

    TtCCoM_a.(condition{j})    = Y_total_CoM_a;
    TtCSw_a.(condition{j})     = Y_total_Sw_a;
    TtClength_a.(condition{j}) = median(length_total_a);

end

condition=fieldnames(TtCCoM_a);
linS = {'-r','--m','--k','-.g','-b'};
legend_name = {'20-','40-', 'Normg', '20+','40+'};
legend_name_Kp = {'20-','40-','Normg','20+','40+'};

TtCF_P = figure;
HF_P   = figure;

for j=1:length(condition)
    %% TtC COM_ap
    figure(TtCF_P)
    x_CoM_a = nanmedian(TtCCoM_a.(condition{j}),2);
    idx_CoM_a = find(x_CoM_a <= 0);
    YourLength_CoM_a = length(x_CoM_a);
    data_length_CoM_a= linspace(0,round(YourLength_CoM_a/median(TtClength_a.(condition{j}))*100),YourLength_CoM_a);
    new_length_CoM_a=0:round(YourLength_CoM_a/median(TtClength_a.(condition{j}))*100);
    TtC_normed_CoM_a=spline(data_length_CoM_a,x_CoM_a,new_length_CoM_a);
    idx_CoM_a_zero = find(TtC_normed_CoM_a >= 0);
    ss(j) = plot(TtC_normed_CoM_a(1:length(idx_CoM_a_zero)),linS{j},'linewidth',1.2);
    hold on;

    %% TtC Sw_ap
    x_Sw_a = nanmedian(TtCSw_a.(condition{j}),2);
    idx_Sw_a = find(x_Sw_a <= 0);
    YourLength_Sw_a = length(x_Sw_a(1:idx_Sw_a(1)+3));
    data_length_Sw_a= linspace(0,round(YourLength_Sw_a/TtClength_a.(condition{j})*100),YourLength_Sw_a);
    new_length_Sw_a=0:round(YourLength_Sw_a/TtClength_a.(condition{j})*100);
    TtC_normed_Sw_a=spline(data_length_Sw_a,x_Sw_a(1:idx_Sw_a(1)+3),new_length_Sw_a);
    plot(TtC_normed_Sw_a,linS{j},'linewidth',1.2);

    %% Kp
    figure(HF_P)
    %     min_length = min(length(x_CoM_a(1:idx_CoM_a(1))),length(x_Sw_a(1:idx_Sw_a(1))));
    %     for sd = 1:min_length
    %         Kp(sd) = x_Sw_a(sd)/x_CoM_a(sd);
    %     end
    Kp = x_Sw_a/x_CoM_a;
    idx_kp = find(Kp(:,1) <= 0);
    YourLength_Kp  = length(Kp(1:idx_kp(1)));
    data_length_Kp = linspace(0,round(YourLength_Kp/TtClength_a.(condition{j})*100),YourLength_Kp);
    new_length_Kp  = 0:round(YourLength_Kp/TtClength_a.(condition{j})*100);
    TtC_normed_Kp  = spline(data_length_Kp,Kp(1:YourLength_Kp),new_length_Kp);

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
print(TtCF_P,'-dpdf','-r600'); print(HF_P,'-dpdf','-r600');
