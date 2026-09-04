%% Filter Procedures
% 1. Filters the power hum using spectrum Interpolation @ 50Hz.
% 2. Filters using moving average mean.
% This is to segment firing pattern during stride for each muscle.
% This scripts has two stages to extract On/offsets with corresponding to
% steps.
function [OutPut] = filterEMG(data, baselinelength,RHSlocs,LHSlocs,filename, to_frequencyfilt,vis)
LEG             = ["RIGHTData" "LEFTData"];

for leg = 1: length(LEG)
    if to_frequencyfilt == 1
        F_power = 50; % Power noise Frequency
%         temp.ChannelData = data.(LEG{leg}).ChannelData;
        %     %% Notch Filter
        %     BW = 120; % Bandwidth
        %     Apass = 1; % Bandwidth Attenuation
        %     [c, d] = iirnotch (F_power/ (data.sf/2), BW/Wn, Apass);
        %     filter
        %     Hd1 = dfilt.df2 (c, d);
        %     data.ChannelData_digfiltered_notch = filter(Hd1,data.ChannelData_digfiltered);
        data.(LEG{leg}).ChannelData_si = ft_preproc_dftfilter(data.(LEG{leg}).ChannelData, data.(LEG{leg}).sf,F_power)'; % Spectrum Interpolation
    end
    data.(LEG{leg}).ChannelData_rectified = abs(detrend(data.(LEG{leg}).ChannelData_si));
    Out = movmean(data.(LEG{leg}).ChannelData_rectified, baselinelength, 'Endpoints', 'discard');
    Out = double(Out);
    Out = round(Out, 10);
    OutPut.(LEG{leg}).events = data.(LEG{leg}).events;
    OutPut.(LEG{leg}).filtered = Out;
    clearvars temp F_power cutoff Wn b a Out

    % Finds the Heel strike for each leg
    % Removes any outliers
    if leg == 1
        for j = 1:length(RHSlocs)-1
            RHSdiff(1,j) = length(RHSlocs(1,j):RHSlocs(1,j+1));
        end
        [B,~] = rmoutliers(RHSdiff);
        [y_HS,y_std]    = deal(nanmean(B',1), nanstd(B',1));
        hs_size = size(RHSlocs,2);
        HSlocs = RHSlocs*6;
    else
        for j = 1:length(LHSlocs)-1
            LHSdiff(1,j) = length(LHSlocs(1,j):LHSlocs(1,j+1));
        end
        [B,~] = rmoutliers(RHSdiff);
        [y_HS,y_std]    = deal(nanmean(B',1), nanstd(B',1));
        hs_size = size(LHSlocs,2);
        HSlocs = LHSlocs*6;
    end

    for i = 1:size(data.(LEG{leg}).events,2)

        onset_event_size = size(OutPut.(LEG{leg}).events(i).onSets,1);
        offset_event_size = size(OutPut.(LEG{leg}).events(i).onSets,1);

        % looks for the minimum size for matrix dimension
        data_size = min(onset_event_size,hs_size);
        data_size = min(data_size,offset_event_size);

        try
            %% First filter
            % Find onsets between HS(x) and HS(x+1), then stores in temp
            % variable for the further use

            % onSets_temp
            for t = 1:data_size-1
                for k = 1:data_size
                    if ((y_HS - (y_std*2)) <= (HSlocs(1,t+1) - HSlocs(1,t)) <= (y_HS + (y_std*2)))
                        if (HSlocs(1,t) <= OutPut.(LEG{leg}).events(i).onSets(k)) && (OutPut.(LEG{leg}).events(i).onSets(k) <= HSlocs(1,t+1))
                            OutPut.(LEG{leg}).events(i).onSets_temp(k,1) = OutPut.(LEG{leg}).events(i).onSets(k);
                        end
                    else
                        OutPut.(LEG{leg}).events(i).onSets_temp(k,1) = 0;
                    end
                end
            end

            if ~isempty(OutPut.(LEG{leg}).events(i).onSets_temp)
                OutPut.(LEG{leg}).events(i).onSets_temp((OutPut.(LEG{leg}).events(i).onSets_temp(:,1) == 0)) = [];
            end

            % offSets_temp
            % Find offsets bigger than HS(x) && onSets(x)
            for t = 1:length(OutPut.(LEG{leg}).events(i).onSets_temp)-1
                for k = 1:length(OutPut.(LEG{leg}).events(i).onSets_temp)
                    if ((y_HS - (y_std*2)) <= (HSlocs(1,t+1) - HSlocs(1,t)) <= (y_HS + (y_std*2)))
                        if HSlocs(1,t) <= OutPut.(LEG{leg}).events(i).offSets(k) && OutPut.(LEG{leg}).events(i).onSets_temp(t) < OutPut.(LEG{leg}).events(i).offSets(k)
                            OutPut.(LEG{leg}).events(i).offSets_temp(k,1) = OutPut.(LEG{leg}).events(i).offSets(k);
                        end
                    end
                end
            end

            if  ~isempty(OutPut.(LEG{leg}).events(i).offSets_temp)
                OutPut.(LEG{leg}).events(i).offSets_temp((OutPut.(LEG{leg}).events(i).offSets_temp(:,1) == 0)) = [];
            end

            data_size = min(length(OutPut.(LEG{leg}).events(i).onSets_temp),length(OutPut.(LEG{leg}).events(i).offSets_temp));

            %% Second filter - matches onSets and offSets according to stride.

            for p = 1:data_size
                for j = 1:data_size-1
                    if ((y_HS - (y_std*2)) <= (HSlocs(1,t+1) - HSlocs(1,t)) <= (y_HS + (y_std*2)))

                        if (OutPut.(LEG{leg}).events(i).onSets_temp(j) <= OutPut.(LEG{leg}).events(i).offSets_temp(p))...
                                && ((y_HS - (y_std*3)) <=(OutPut.(LEG{leg}).events(i).offSets_temp(p)) -OutPut.(LEG{leg}).events(i).onSets_temp(p)) <= (y_HS + (y_std*3))
                            OutPut.(LEG{leg}).events(i).onSets_final(j,1) = OutPut.(LEG{leg}).events(i).onSets_temp(j);
                        end
                    end
                end
            end

            if ~isempty(OutPut.(LEG{leg}).events(i).onSets_final)
                OutPut.(LEG{leg}).events(i).onSets_final((OutPut.(LEG{leg}).events(i).onSets_final(:,1) == 0)) = [];
            end

            data_size = min(length(OutPut.(LEG{leg}).events(i).onSets_final),length(OutPut.(LEG{leg}).events(i).offSets_temp));

            for p = 1:data_size
                for j = 1:data_size-1
                    if ((y_HS - (y_std*2)) <= (HSlocs(1,t+1) - HSlocs(1,t)) <= (y_HS + (y_std*2)))

                        if (OutPut.(LEG{leg}).events(i).onSets_final(p) <= OutPut.(LEG{leg}).events(i).offSets_temp(j)) && (OutPut.(LEG{leg}).events(i).offSets_temp(j) <= OutPut.(LEG{leg}).events(i).onSets_final(p+1)) && ...
                                ((y_HS - (y_std *2)) <= OutPut.(LEG{leg}).events(i).offSets_temp(j) - OutPut.(LEG{leg}).events(i).onSets_final(p)  <= (y_HS + (y_std *2)))
                            OutPut.(LEG{leg}).events(i).offSets_final(j,1) = OutPut.(LEG{leg}).events(i).offSets_temp(j);
                        end
                    end
                end
            end

            if ~isempty(OutPut.(LEG{leg}).events(i).offSets_final)
                OutPut.(LEG{leg}).events(i).offSets_final((OutPut.(LEG{leg}).events(i).offSets_final(:,1) == 0)) = [];
            end

        catch
            fprintf("%s Leg %s does not have firing parttern in %d\n",  LEG{leg}(1:end-4), filename, i)
            continue;
        end
    end
end

%% To see the difference of the filter effects
if vis == 1

    figure(1);
    hold on;
    xf  = linspace(0,3000,length(data.(LEG{leg}).ChannelData(:,1)));
    notch_fft = abs(fft(data.(LEG{leg}).ChannelData_digfiltered_notch));
    raw_fft = abs(fft(data.(LEG{leg}).ChannelData_digfiltered));
    si_fft = abs(fft(data.ChannelData_digfiltered_si));
    ax1 = plot(xf,raw_fft);
    ax2 = plot(xf,notch_fft);
    ax3 = plot(xf,si_fft);
    title("frequency Spectrum"); xlabel({'Frequency(Hz)'})
    legend([ax1 ax2 ax3], {'raw','notch','Spectrum'},'Location','northeast','Orientation','vertical');

    figure(2);
    hold on;
    notch = data.ChannelData_digfiltered_notch;
    raw = data.ChannelData_digfiltered;
    si = data.ChannelData_digfiltered_si;
    ax4 = plot(raw);
    ax5 = plot(notch);
    ax6 = plot(si);
    title("Time Spectrum"); xlabel({'sample points'})
    legend([ax4 ax5 ax6], {'raw','notch','Spectrum'},'Location','northeast','Orientation','vertical');

    raw_rectified = abs(detrend(raw));
    notch_rectified = abs(detrend(notch));
    si_rectified = abs(detrend(si));

    Out = movmean(raw_rectified, baselinelength, 'Endpoints', 'discard');
    Out_notch = movmean(notch_rectified, baselinelength, 'Endpoints', 'discard');
    Out_si = movmean(si_rectified, baselinelength, 'Endpoints', 'discard');
    Out = double(Out);
    Out = round(Out, 10);
    Out_notch = double(Out_notch);
    Out_notch = round(Out_notch, 10);
    Out_si = double(Out_si);
    Out_si = round(Out_si,10);

    figure(3)
    hold on;
    ax7 = plot(Out);
    ax8 = plot(Out_notch);
    ax9 = plot(Out_si);
    title("Moving Average"); xlabel({'sample points'})
    legend([ax7 ax8 ax9], {'raw','notch','Spectrum'},'Location','northeast','Orientation','vertical');
end
