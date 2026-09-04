
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
            figure(participantsize)
            temp_emg = emgconcat.emgconcat.stim.(LEG{leg}).muscles.gait.(name_of_condition{conditionsize,1}).(name_of_muscle{musclessize,1}).(filename);
            plot(temp_emg);
        end
    end
end
