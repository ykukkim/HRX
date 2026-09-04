%% Plotting the comparison of firing pattern of each
function plot_ave_gait_stim_total(emgconcat,LEG,leg,TestPath1,pathCompSep)

destPath = [TestPath1,pathCompSep,'Results',pathCompSep,'EMG',pathCompSep,(LEG{leg}),pathCompSep,'stim',pathCompSep,'average',pathCompSep,'Wholegait'];

if ~exist(destPath,'dir')
    mkdir(destPath)
end

condition_name = {'20-','40-','00','20+','40+'};
legend_name = {'20- Mean', '20- SD', '40- Mean', '40- SD','00  Mean', '00 SD','20+ Mean', '20+ SD', '40+ Mean', '40+ SD'};
legend_name_2 = {'20- Mean', '40- Mean','00  Mean', '20+ Mean',  '40+ Mean'};

colours = {[0,0.5,0.5],	[0,0,1],[0,0,0],...
    [0.5,0.5,0],[0.5,0,0]};
size_of_muscle =  numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait));
name_of_muscle = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait);

for musclesize = 1:size_of_muscle

    name_of_condition = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1}));
    size_of_condition = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1})));

    h=figure;
    titlename = strcat((LEG{leg})," - ",(name_of_muscle{musclesize,1}),"Condition Comparison - ", "-stim");
    title(titlename)
    ylabel({'Amplitude [mV] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    xlabel({'Gait Phase [%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    hold on;

    for conditionsize = 1: size_of_condition

        y  = emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1}).(name_of_condition{conditionsize,1})';
        spm1d.plot.plot_meanSD(y','LineWidth',2,'color',colours{conditionsize});
        hold on;

        [y_mean_temp,~]    = deal(nanmean(y),nanstd(y));
        y_mean(:,conditionsize) = y_mean_temp;

    end

    legend(legend_name,'Location','northeast','Orientation','vertical')
    h_line = findobj(gcf, 'type', 'line');
    h_patch = findobj(gcf, 'type', 'Patch');
    set(h_line(3),'LineStyle','--')
    delete(h_patch(3))
    saveas(h, fullfile(destPath, titlename), 'pdf');

    delete(h_patch)
    legend(legend_name_2,'Location','northeast','Orientation','vertical')
    titlename = strcat((LEG{leg})," - ",(name_of_muscle{musclesize,1}),"Condition Comparison - 2 ", "-stim");
    title(titlename)
    saveas(h, fullfile(destPath, titlename), 'pdf');

    close(h);

end
