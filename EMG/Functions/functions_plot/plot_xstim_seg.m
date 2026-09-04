%% EMG activity concatenation of firing patterns of each condition for each participant
%% plots all the muscles in each condition from all participants
function [emgconcat] = plot_xstim_seg(emgconcat,LEG,leg,TestPath1,pathCompSep)

size_of_condition =  numel(fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg));
name_of_condition = fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg);

for conditionsize = 1:size_of_condition

    name_of_muscle = fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}));
    size_of_muscle = numel(fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1})));

    for musclessize = 1:size_of_muscle

        name_of_participants= fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}));
        size_of_participants = numel(fieldnames(emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1})));

        for participantsize = 1:size_of_participants
            temp_emg_2 =[];
            h1 = figure(participantsize);
            filename = (name_of_participants{participantsize,1});
            temp_emg = emgconcat.emgconcat.xstim.(LEG{leg}).muscles.seg.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename);
            if length(temp_emg) > 3000*0.7
                for i = 1:size(temp_emg,2)
                    temp_emg_2(1:(3000*0.7),i) = temp_emg(1:(3000*0.7),i);
                end
            end

            if exist('temp_emg_2','var') && (~isempty(temp_emg_2))
%                 spm1d.plot.plot_meanSD_seg(temp_emg_2,(name_of_muscle{musclessize,1}),'color',[0, 0.4470, 0.7410]);
                emgconcat.emgconcat.xstim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename) = temp_emg_2;
            elseif exist('temp_emg','var') && (~isempty(temp_emg))
%                 spm1d.plot.plot_meanSD_seg(temp_emg,(name_of_muscle{musclessize,1}),'color',[0, 0.4470, 0.7410]);
                emgconcat.emgconcat.xstim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename) = temp_emg;
            end

            %
%             title(sprintf('Name: %s Condition: %s Muscle: %s -- X STIM(FP)',(filename(1:end-3)),(name_of_condition{conditionsize}),(name_of_muscle{musclessize,1})))
%             titlename =  title(sprintf('%s - %s - %s -- X STIM(FP)',(filename(1:end-3)),(name_of_condition{conditionsize}),(name_of_muscle{musclessize,1})));
%             ylabel({'Amplitude [mV] '}); xlabel({'Gait Phase [%]'})
%             legend('Mean(EMG)','SD(EMG)','Location','northwest','Orientation','horizontal')
%
%             destPath = [TestPath1,pathCompSep,'Results',pathCompSep,'EMG',pathCompSep,(LEG{leg}),pathCompSep,'xstim',pathCompSep,'FiringPattern',pathCompSep,filename];
%
%             if ~exist(destPath,'dir')
%                 mkdir(destPath)
%             end
%             saveas(figure(participantsize), fullfile(destPath, titlename.String), 'jpg');
%             close(figure(participantsize));
            clearvars temp_emg temp_emg_2

        end
    end
end
