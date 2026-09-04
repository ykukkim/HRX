% EMG activity through seg cycle of each condition
function [emgconcat] = emg_stim_seg_concat(emgconcat,LEG,leg)

size_of_condition =  numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew));
name_of_condition = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew);

for conditionsize = 1:size_of_condition

    name_of_muscle = fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}));
    size_of_muscle = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1})));

    for musclessize = 1:size_of_muscle

        name_of_participants= fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}));
        size_of_participants = numel(fieldnames(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1})));

        %% Calculating average of each muscle in the condition of participants
        % e.g. average value of Soleus in normg condition across all
        % participants
        for t = 1:size_of_participants
            data_size(t) = length(emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(name_of_participants{t}));

        end
        t = 0;
        max_size = max(data_size);
        Y_total = NaN(max_size,length(name_of_participants));
        try
            for t = 1:length(name_of_participants)

                Y = emgconcat.emgconcat.stim.(LEG{leg}).muscles.segnew.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(name_of_participants{t});
                Y = Y';
                [y,~]    = deal(nanmean(Y),nanstd(Y));
                Y_total(1:length(y'),t)= y';
            end
        catch
            fprintf("%s does not have data in %s muscle in %s condition\n",name_of_participants{t},(name_of_muscle{musclessize,1}),(name_of_condition{conditionsize}))
            continue;
        end
        emgconcat.emgconcat.stim.(LEG{leg}).average.seg.((name_of_muscle{musclessize,1})).(name_of_condition{conditionsize})= Y_total;
    end
end
