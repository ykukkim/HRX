function [ baselineMean, baselineStd, movingAverage,emgData_bandpassFilt,emgData_bandpassFilt_Rect,emgData_envelop,normalizedContraction]...
    = estimateBaseline_EMGanalysis(inputSignal, baselineLength, baselineRank)

bpfr = [10 300]; % Cutoff frequency
[b, a] = butter(4, (bpfr/(3000*0.5)));
emgData_bandpassFilt = filtfilt(b, a, inputSignal.ChannelData);

meanSubtract = (mean(emgData_bandpassFilt, 1).' * (ones(size(emgData_bandpassFilt, 1), 1)).').';
emgData_bandpassFilt = emgData_bandpassFilt - meanSubtract;
emgData_bandpassFilt_Rect = abs(emgData_bandpassFilt);

movingAverage = movmean(emgData_bandpassFilt_Rect, baselineLength, 'Endpoints', 'discard');
movingAverage = double(movingAverage);
movingAverage = round(movingAverage, 10);
lengthDifference(:,:) = length(inputSignal.ChannelData(:,:)) - length(movingAverage(:,:));
emgData_envelop = emgenvelope(movingAverage,3000);


for i = 1:size(movingAverage,2)
    [~, IA, ~] = uniquetol(movingAverage(:,i));
    IA(:,i) = IA;
    if baselineRank > length(IA(:,i))
        startSampleNo(:,i) = IA(end,i);
        startSampleNo(:,i) = startSampleNo;
    else
        startSampleNo(:,i) = IA((baselineRank),i) + lengthDifference/2;
    end

    % Select the interval of the baseline segment from the input signal
    baselineInterval(:,i) = startSampleNo(:,i) - floor(baselineLength/2) + 1 : startSampleNo(:,i) + floor(baselineLength/2);

    % In case of interval problems, return 0, 0
    try
        % Compute baseline mean and standard deviation
        baselineSegment(:,i)         = inputSignal.ChannelData(baselineInterval(:,i));
        baselineMean(:,i)            = mean(abs(baselineSegment(:,i)));
        baselineStd(:,i)             = std(abs(baselineSegment(:,i)));
    catch
        baselineMean(:,i)            = 0;
        baselineStd(:,i)             = 0;
    end
    size_max(i) = max(size(inputSignal.events(i).onSets));
end


referenceContraction = NaN(max(size_max),size(movingAverage,2));
for j = 1:size(movingAverage,2)
    for i = 1:size(inputSignal.events(j).onSets,1)
        referenceContraction(i,j) = trapz(movingAverage((inputSignal.events(j).onSets(i):inputSignal.events(j).offSets(i))<size(movingAverage,1),1));
    end
end

referenceContraction_isnan = referenceContraction(~isnan(referenceContraction));

    for j = 1:size(movingAverage,2)
        normalizedContraction(:,j) = trapz(movingAverage(:,j)./max(referenceContraction(:,j)));
    end
end
