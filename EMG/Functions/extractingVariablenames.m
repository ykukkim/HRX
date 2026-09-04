% firing parameters
emgcofiringVariableNames = emgcofiringMatrix.Properties.VariableNames;
cofiringMatrix.Properties.VariableNames = emgcofiringVariableNames;

for colnames = 5:length(emgcofiringVariableNames)
    cofiringMatrix.(emgcofiringVariableNames{colnames}) = ...
        str2double(cofiringMatrix.(emgcofiringVariableNames{colnames}));
end

% intermuscular emg
emgcohereVariableNames = interemgcoherenceMatrix.Properties.VariableNames;
emgcoherenceMatrix.Properties.VariableNames = emgcohereVariableNames;

for colnames = 5:length(emgcohereVariableNames)
    emgcoherenceMatrix.(emgcohereVariableNames{colnames}) = ...
        str2double(emgcoherenceMatrix.(emgcohereVariableNames{colnames}));
end


for colnames = 5:length(coherenceIntegralNames)
    coherenceIntegralMatrix.(coherenceIntegralNames{colnames}) = ...
        str2double(coherenceIntegralMatrix.(coherenceIntegralNames{colnames}));
end
