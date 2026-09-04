%% Plotting the comparison of firing pattern of each
function plot_ave_stim(emgconcat,LEG,leg,TestPath1,pathCompSep)

destPath = [TestPath1,pathCompSep,'stim',pathCompSep,'Aveage',pathCompSep,'FiringPattern'];

if ~exist(destPath,'dir')
    mkdir(destPath)
end

  size_of_muscle =  numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average));
  name_of_muscle = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average);

for musclesize = 1:size_of_muscle

    name_of_condition = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.(name_of_muscle{musclesize,1}));
    size_of_condition = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).average.(name_of_muscle{musclesize,1})));

    figure(musclesize);

    for conditionsize = 1: size_of_condition

        y  = emgconcat.emgconcat.stim.(LEG{leg}).average.(name_of_muscle{musclesize,1}).(name_of_condition{conditionsize,1})';
        figure(conditionsize);
        spm1d.plot.plot_meanSD_seg(y',(name_of_muscle{musclesize,1}),'color',[0, 0.4470, 0.7410]);
        titlename = strcat("Average - ",(LEG{leg})," - ",(name_of_muscle{musclesize,1}),"- stim");
        title(titlename)
        ylabel({'Amplitude [mV] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
        xlabel({'Gait Phase [%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
        legend('Mean(EMG)','SD(EMG)','Location','northwest','Orientation','horizontal')
        saveas(figure(conditionsize), fullfile(destPath, titlename), 'jpg');
        close();

        [y_mean,~]    = deal(nanmean(y),nanstd(y));


        if (name_of_muscle{musclesize,1}) == 'SOL'
            t  = 45/(length(y_mean)-1);
            x  = 5:t:50;

        elseif (name_of_muscle{musclesize,1}) == 'TIA'
            t  = 15/(length(y_mean)-1);
            x  = 0:t:15;

        elseif (name_of_muscle{musclesize,1}) == 'GAL'
            t  = 40/(length(y_mean)-1);
            x  = 20:t:60;

        elseif (name_of_muscle{musclesize,1}) == 'GAM'
            t  = 40/(length(y_mean)-1);
            x  = 20:t:60;

        elseif (name_of_muscle{musclesize,1}) == 'VAM'
            t  = 15/(length(y_mean)-1);
            x  = 0:t:15;

        elseif (name_of_muscle{musclesize,1})== 'VAL'
            t  = 25/(length(y_mean)-1);
            x  = 0:t:25;

        elseif (name_of_muscle{musclesize,1}) == 'BIF'
            t  = 40/(length(y_mean)-1);
            x  = 60:t:100;
        end

        plot(x,y_mean);
        hold on;
        LEGEND{conditionsize} = (name_of_condition{conditionsize});

    end
    titlename = strcat((LEG{leg})," - ",(name_of_muscle{musclesize,1}),"Condition Compariosn - ", "-stim");
    title(titlename)
    ylabel({'Amplitude [mV] '},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    xlabel({'Gait Phase [%]'},'LineWidth',0.1,'FontName','Times New Roman','FontSize',10);
    legend(LEGEND,'Location','northeast','Orientation','vertical')
    saveas(figure(musclesize), fullfile(destPath, titlename), 'jpg');
    close();
end
