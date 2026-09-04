%% EMG activity concatenation through gait cycle of each condition for each participant
% plots all the muscles in each condition from all participants
function [emgconcat] = plot_stim_gait(emgconcat,LEG,leg,TestPath1,pathCompSep)

size_of_condition =  numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait));
name_of_condition = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait);

for conditionsize = 1:size_of_condition

    name_of_muscle = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}));
    size_of_muscle = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1})));

    for musclessize = 1:size_of_muscle

        name_of_participants= fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}));
        size_of_participants = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1})));

        for participantsize = 1:size_of_participants
            filename = (name_of_participants{participantsize,1});
            temp_emg = emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename);
            temp_HS = emgconcat.emgconcat.stim.(LEG{leg}).gaitparameters.(name_of_condition{conditionsize,1}).(filename).HS;
            for j = 1:length(temp_HS)-1
                temp_diff(1,j) = length(temp_HS(1,j):temp_HS(1,j+1));
            end
            [y_HS,y_std]    = deal(nanmean(temp_diff',1), nanstd(temp_diff',1));

            for i = 1:size(temp_emg,2)
                remove_outliers =  find(temp_emg(:,i) == 0);
                if (~isempty(remove_outliers))
                    if remove_outliers(1) > ((y_HS*6)+(y_std*3))
                        temp_indx(i) = i;
                    end
                end
            end
            if exist('temp_indx','var')
                temp_indx(temp_indx == 0) = [];
                temp_emg(:,temp_indx) = [];
            end

            if length(temp_emg) > 3000*1.2
                for i = 1:size(temp_emg,2)
                    temp_emg_2(1:(3000*1.2),i) = temp_emg(1:(3000*1.2),i);
                end
            end
            emgconcat.emgconcat.stim.(LEG{leg}).muscles.gaitnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename) = temp_emg;
            if exist('temp_emg_2','var') && (~isempty(temp_emg_2))
                emgconcat.emgconcat.stim.(LEG{leg}).muscles.gaitnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename) = temp_emg_2;
            elseif exist('temp_emg','var') && (~isempty(temp_emg))
                emgconcat.emgconcat.stim.(LEG{leg}).muscles.gaitnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename) = temp_emg;
            end

%             h(1) = figure(participantsize);
%             spm1d.plot.plot_meanSD(temp_emg,'color',[0, 0.4470, 0.7410]);
%             title(sprintf('%s - %s - %s -- X STIM(WG)',(filename(1:end-3)),(name_of_condition{conditionsize}),(name_of_muscle{musclessize,1})))
%             titlename =  title(sprintf('%s - %s - %s -- X STIM(WG)',(filename(1:end-3)),(name_of_condition{conditionsize}),(name_of_muscle{musclessize,1})));
%             ylabel({'Amplitude [mV] '}); xlabel({'Gait Phase [%]'})
%             legend('Mean(EMG)','SD(EMG)','Location','northwest','Orientation','horizontal')
%
%             destPath = [TestPath1,pathCompSep,'Results',pathCompSep,'EMG',pathCompSep,(LEG{leg}),pathCompSep,'stim',pathCompSep,'GeneralPattern',pathCompSep,filename];
%             if ~exist(destPath,'dir')
%                 mkdir(destPath)
%             end
%
%             saveas(figure(participantsize), fullfile(destPath, titlename.String), 'jpg');
%             close(figure(participantsize));
%             clearvars temp_indx temp_emg temp_HS y_HS y_std remove_outliers
        end
    end
end
