% This scripts produces two outcomes
% 1. Muscle acivitiy during WHOLE gait cycle(100%)
% 2. Muscle activity during firing pattern(between Onsets and Offsets)

function [Data_out] = emgCatergorise_mod(data,RHSlocs,RTOlocs,LHSlocs,LTOlocs,Name)

%% Channel info
SOLEUS            = 1;
TIBIAS_ANTERIOR   = 2;
GASTROCNEMIUS_L   = 3;
GASTROCNEMIUS_M   = 4;
Vastus_Medialis   = 5;
Vastus_Lateralis  = 6;
Biceps_Femori     = 7;

CHANNEL_INFO            = [SOLEUS TIBIAS_ANTERIOR GASTROCNEMIUS_L GASTROCNEMIUS_M Vastus_Medialis Vastus_Lateralis Biceps_Femori];
CHANNEL_INFO_str        = ["SOL" "TIA" "GAL" "GAM" "VAM" "VAL" "BIF"];
LEG                     = ["RIGHTData" "LEFTData"];

for leg = 1: length(LEG)

    if leg == 1
        for j = 1:length(RHSlocs)-1
            RHSdiff(1,j) = length(RHSlocs(1,j):RHSlocs(1,j+1));
        end
        [B,TF] = rmoutliers(RHSdiff);
        [y_HS,y_std]    = deal(nanmean(B',1), nanstd(B',1));
        hs_size = size(RHSlocs,2);
        HSlocs = RHSlocs*6;
        TOlocs = RTOlocs*6;
    else
        for j = 1:length(LHSlocs)-1
            LHSdiff(1,j) = length(LHSlocs(1,j):LHSlocs(1,j+1));
        end
        [B,TF] = rmoutliers(RHSdiff);
        [y_HS,y_std]    = deal(nanmean(B',1), nanstd(B',1));
        hs_size = size(LHSlocs,2);
        HSlocs = LHSlocs*6;
        TOlocs = LTOlocs*6;
    end

    if(~isempty(data.(LEG{leg}).filtered))
        outData      = [data.(LEG{leg}).filtered(:,CHANNEL_INFO(1))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(2))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(3))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(4))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(5))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(6))...
            data.(LEG{leg}).filtered(:,CHANNEL_INFO(7))];
    else
        outData    = [];
    end

    %% Process Muscle activity during stride
    % This is to see muscle activity through whole gait cycle
    % Heel strike to ToeOff
    try
        for i = 1:size(data.(LEG{leg}).filtered,2)
            for j = 1:length(HSlocs)-1
                StartPoint = HSlocs(1,j);
                EndPoint = HSlocs(1,j+1);
                if (StartPoint< size(data.(LEG{leg}).filtered,1)) && (EndPoint < size(data.(LEG{leg}).filtered,1))...
                        && (((y_HS - (y_std*2))*6) <= (EndPoint - StartPoint)) && ((EndPoint - StartPoint) <= ((y_HS + (y_std*2))*6))
                    gaitemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length(StartPoint:EndPoint),j) = outData((StartPoint:EndPoint),i);
                else
                    gaitemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length(StartPoint:(StartPoint+(3000*1.3))),j) = outData((StartPoint:(StartPoint+(3000*1.3))),i);
                end
            end
            indx = find((gaitemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1,:) == 0));
            gaitemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(:,indx) = [];
        end
    catch
        fprintf("Cannot get muscle acitivty in %s of %s leg in %s\n", CHANNEL_INFO_str(i),LEG{leg}(1:end-4),Name)
    end

    %% Process MUSCLE Speicfic firing pattern
    % THis is to look at firing pattern that has been acquired from event
    % onSets and offSets

    for i = 1:size(data.(LEG{leg}).filtered,2)
        try
            if(~isempty(data.(LEG{leg}).events(i).onSets_final)) && (~isempty(data.(LEG{leg}).events(i).offSets_final))
                data_size = min(size(data.(LEG{leg}).events(i).onSets_final,1),size(data.(LEG{leg}).events(i).offSets_final,1));
                StartPoint_FP = data.(LEG{leg}).events(i).onSets_final;
                EndPoint_FP = data.(LEG{leg}).events(i).offSets_final;
                for j = 1: data_size
                    if (StartPoint_FP(j) < size(data.(LEG{leg}).filtered,1)) && (EndPoint_FP(j) < size(data.(LEG{leg}).filtered,1))...
                            && ((EndPoint_FP(j)  - StartPoint_FP(j)) <= ((y_HS + (y_std*2))*6))

                        if  StartPoint_FP(1) < 200
                            firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length(StartPoint_FP(j):EndPoint_FP(j)),j) = ...
                                outData((StartPoint_FP(j):EndPoint_FP(j)),i);
                        else
                            firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length(StartPoint_FP(j)-200:EndPoint_FP(j)),j) = ...
                                outData((StartPoint_FP(j)-200:EndPoint_FP(j)),i);
                        end

                    elseif (StartPoint_FP(j) < size(data.(LEG{leg}).filtered,1)) && (EndPoint_FP(j) < size(data.(LEG{leg}).filtered,1))...
                            && ((EndPoint_FP(j) - StartPoint_FP(j)) > ((y_HS + (y_std*2))*6))...

                        if  StartPoint_FP(1) < 200
                            firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length(StartPoint_FP(j):(StartPoint_FP(j)+3000*0.7)),j) = ...
                                outData(StartPoint_FP(j):(StartPoint_FP(j)+(3000*0.7)),i);
                        else
                            firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1:length((StartPoint_FP(j)-200):(StartPoint_FP(j)+3000*0.7)),j) = ...
                                outData((StartPoint_FP(j)-200):(StartPoint_FP(j)+3000*0.7),i);
                        end

                    end
                end
                indx = find((firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(1,:) == 0));
                firingemg.(LEG{leg}).muscles.(CHANNEL_INFO_str(i))(:,indx) = [];
            else
                fprintf("%s leg of %s  does not have onSets&offSets in %s\n", LEG{leg}(1:end-4),Name,CHANNEL_INFO_str(i))
            end
        catch
            fprintf("%s leg of %s  does not have onSets&offSets in %s\n", LEG{leg}(1:end-4),Name,CHANNEL_INFO_str(i))
        end
    end

    if (exist('firingemg','var')) == 1
        checkvar = firingemg.(LEG{leg}).muscles;
        if(exist('checkvar','var')) == 1
            Data_out.(LEG{leg}).seg = firingemg.(LEG{leg}).muscles;
        end
    end
    Data_out.(LEG{leg}).gait = gaitemg.(LEG{leg}).muscles;
    Data_out.(LEG{leg}).HS = HSlocs;
    Data_out.(LEG{leg}).TO = TOlocs;
end
