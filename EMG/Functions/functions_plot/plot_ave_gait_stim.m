%% Plotting the comparison of firing pattern of each
function plot_ave_gait_stim(emgconcat,LEG,leg,TestPath1,pathCompSep)

destPath = [TestPath1,pathCompSep,'Results',pathCompSep,'EMG',pathCompSep,(LEG{leg}),pathCompSep,'stim',pathCompSep,'average',pathCompSep,'Wholegait'];

if ~exist(destPath,'dir')
    mkdir(destPath)
end

size_of_muscle =  numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait));
name_of_muscle = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait);
y_mean = NaN(3600,5);
for musclesize = 1:size_of_muscle

    name_of_condition = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1}));
    size_of_condition = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1})));


    for conditionsize = 1: size_of_condition

        y  = emgconcat.emgconcat.stim.(LEG{leg}).average.gait.(name_of_muscle{musclesize,1}).(name_of_condition{conditionsize,1})';
        figure(conditionsize);
        spm1d.plot.plot_meanSD(y','color',[0, 0.4470, 0.7410]);
        titlename = strcat("Average - ","WG"," - ",(LEG{leg})," - ",(name_of_muscle{musclesize,1}),"-", (name_of_condition{conditionsize,1}),"- stim");
        title(titlename)
        ylabel({'Amplitude [mV] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
        xlabel({'Gait Phase [%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
        legend('Mean(EMG)','SD(EMG)','Location','northwest','Orientation','horizontal')
        saveas(figure(conditionsize), fullfile(destPath, titlename), 'jpg');
        close(figure(conditionsize));

        [y_mean_temp,~]    = deal(nanmean(y),nanstd(y));
        y_mean(:,conditionsize) = y_mean_temp;

        LEGEND{conditionsize} = (name_of_condition{conditionsize});

    end
    figure(musclesize);
    t  = 100/(length(y_mean)-1);
    x  = 0:t:100;
    plot(x,y_mean);
    hold on;
    titlename = strcat((LEG{leg})," - ",(name_of_muscle{musclesize,1}),"Condition Compariosn - ", "-stim");
    title(titlename)
    ylabel({'Amplitude [mV] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    xlabel({'Gait Phase [%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    legend(LEGEND,'Location','northeast','Orientation','vertical')
    saveas(figure(musclesize), fullfile(destPath, titlename), 'jpg');
    close();
end
