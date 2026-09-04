%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 11);

% Specify column names and types
opts.VariableNames = ["Participant", "Condition", "H_wave(mV P-P)", "M_wave(mV P-P)", "BEmg(mv P-P)", "Stim(mA)", "Location of Trigger", "Location of HS", "Gait Phase(%)"];
opts.VariableTypes = ["categorical", "categorical", "double", "double", "double", "double", "double", "double", "double"];

% Specify sheet and range
opts.Sheet = "Raw_WGP";
opts.DataRange = "B2:J2105";

% Specify variable properties
opts = setvaropts(opts, ["Participant", "Condition", "Location of Trigger"], "EmptyFieldRule", "auto");

% Import the data
HrefData = readtable("C:\Users\ykuk0\Desktop\HRX\Stats\HMdata_Final_yk.xlsx", Sheet="Raw_WGP", VariableNamingRule='preserve');

%%
clear opts

%%
%% Bin it mate!

yy = table2array(HrefData(:,8));  % taking the second column
zz = HrefData;  % according to the diagram

% binning
edges = 0:15000:180000;
[N, ~, hbin] = histcounts(yy,edges);


% match the values of zz to the bins that elements
% of yy went into.

%%

[href, hrefid] = findgroups(hbin);
Tcref = splitapply(@(varargin) varargin, HrefData, href);
% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables_href = cell(size(Tcref, 1), 1);
% Create sub tables for participants and conditions
hrefPC_all = [];
for i = 1:size(Tcref, 1)
    if i == 1 || i == 12 || i== 13
        continue
    else
        subTables_href{i} = table(Tcref{i, :}, 'VariableNames', ...
            HrefData.Properties.VariableNames);
        subgroupTables_href{i} = table(subTables_href{i}.Participant, subTables_href{i}.Condition, ...
            'VariableNames', HrefData.Properties.VariableNames(1:2));
        colsTouse = [3, 4, 5, 6, 9];
        suboutcomesTables{i} = subTables_href{i}(:,colsTouse);
        [hPC{i}, hPCidI{i}] = findgroups(subgroupTables_href{i});
        for outcomes = 1:size(suboutcomesTables{i}, 2)
            mean_hPC{i}(:, outcomes) = splitapply(@mean, suboutcomesTables{i}(:, outcomes), hPC{i});
            std_hPC{i}(:, outcomes) = splitapply(@std, suboutcomesTables{i}(:, outcomes), hPC{i});
        end
        addsegmentVecth{i} = i*ones(size(mean_hPC{i}, 1), 1);
    end
end

hPCID = cat(1, hPCidI{:});
hPCmean = cat(1, mean_hPC{:});
hPCstd = cat(1, std_hPC{:});
addsegmentID = cat(1, addsegmentVecth{:});
hPC_allParams = [hPCID, table(addsegmentID), table(hPCmean), table(hPCstd)];

filename = 'Hrefsummary.xlsx';
writetable(hPC_allParams,filename,'Sheet',1,'Range','A1')

% Create sub tables for conditions
subTables_cond_href = cell(size(Tcref, 1), 1);

for j = 1:size(Tcref, 1)
    if j == 1 || j == 12 || j == 13
        continue
    else
        subTables_cond_href{j} = table(Tcref{j, :}, 'VariableNames', ...
            HrefData.Properties.VariableNames);
        subgroupTables_cond_href{j} = table(subTables_href{j}.Condition, ...
            'VariableNames', HrefData.Properties.VariableNames(2));
        colsTouse = [3, 4, 5, 6, 9];
        suboutcomesTables_cond_href{j} = subTables_cond_href{j}(:,colsTouse);
        [hPC_cond{j}, hPCidI_cond{j}] = findgroups(subgroupTables_cond_href{j});
        for outcomes_c = 1:size(suboutcomesTables_cond_href{j}, 2)
            mean_hPC_cond{j}(:,outcomes_c) = splitapply(@mean, suboutcomesTables_cond_href{j}(:,outcomes_c), hPC_cond{j});
            std_hPC_cond{j}(:,outcomes_c) = splitapply(@std, suboutcomesTables_cond_href{j}(:,outcomes_c), hPC_cond{j});

        end
    end
end
legend_no = [];


for outtoPlot = 1:5
    for section = 1:size(unique(href),1)
        if section == 1 || section == 12 || section == 13
            continue;
        else

            figure(outtoPlot);
            subplot(2, 1, 1)
            plot(mean_hPC_cond{1,section}(:,outtoPlot))
            hold on
            subplot(2, 1, 2)
            plot(std_hPC_cond{1,section}(:,outtoPlot))
            hold on
            legend_no = [legend_no; section];

        end
    end
    legend(num2str(legend_no));
    hold off;

end

close all
clearvars -except hPC_allParams HrefData

%% Set up the Import Options and import the data
opts = spreadsheetImportOptions("NumVariables", 13);

% Specify column names and types
opts.VariableNames = ["Participant", "Condition", "dls", "StrideTime", "Stance Phase", "Step length", "Step Width", "Stride Length", "Swing Phase", "MoS_Medial","MoS_AP","Locations"];
opts.VariableTypes = ["categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify sheet and range
opts.Sheet = "GaitData_Right";
opts.DataRange = "A2:L27565";

% Specify variable properties
opts = setvaropts(opts, ["Participant", "Condition", "Locations"], "EmptyFieldRule", "auto");

% Import the data
GaitData = readtable("C:\Users\ykuk0\Desktop\HRX\Stats\HMdata_Final_yk.xlsx", Sheet="GaitData_Right", VariableNamingRule='preserve');

%% Clear temporary variables
clear opts

%% Bin it mate!

yy = table2array(GaitData(:,10));  % taking the second column
zz = GaitData;  % according to the diagram

% binning
edges = 0:15000:180000;
[N, ~, gbin] = histcounts(yy,edges);


% match the values of zz to the bins that elements
% of yy went into.

%% Work on the bins mate!

[g, gid] = findgroups(gbin);
Tc = splitapply(@(varargin) varargin, GaitData, g);
% Allocate empty cell array fo sizxe equal to number of rows in T_Split
subTables = cell(size(Tc, 1), 1);
% Create sub tables for participants and conditions
gPC_all = [];
for i = 1:size(Tc, 1)
    if i == 1 || i == 12 || i == 13  % removing the first and the last segments
        continue
    else
        subTables{i} = table(Tc{i, :}, 'VariableNames', ...
            GaitData.Properties.VariableNames);
        subgroupTables{i} = table(subTables{i}.Participant, subTables{i}.Condition, ...
            'VariableNames', GaitData.Properties.VariableNames(1:2));
        suboutcomesTables{i} = subTables{i}(:,3:end-1);
        [gPC{i}, gPCidI{i}] = findgroups(subgroupTables{i});
        for outcomes = 1:size(suboutcomesTables{i}, 2)
            mean_gPC{i}(:, outcomes) = splitapply(@mean, suboutcomesTables{i}(:, outcomes), gPC{i});
            std_gPC{i}(:, outcomes) = splitapply(@std, suboutcomesTables{i}(:, outcomes), gPC{i});
        end
        addsegmentVect{i} = i*ones(size(mean_gPC{i}, 1), 1);
    end
end

gPCID = cat(1, gPCidI{:});
gPCmean = cat(1, mean_gPC{:});
gPCstd = cat(1, std_gPC{:});
addsegmentID = cat(1, addsegmentVect{:});
gPC_allParams = [gPCID, table(addsegmentID), table(gPCmean), table(gPCstd)];

filename = 'Gaitsummary.xlsx';
writetable(gPC_allParams,filename,'Sheet',1,'Range','D1')

% Create sub tables for conditions
subTables_cond = cell(size(Tc, 1), 1);

for j = 1:size(Tc, 1)
    if j == 1 || j == 12 || j == 13
        continue
    else
        subTables_cond{j} = table(Tc{j, :}, 'VariableNames', ...
            GaitData.Properties.VariableNames);
        subgroupTables_cond{j} = table(subTables{j}.Condition, ...
            'VariableNames', GaitData.Properties.VariableNames(2));
        suboutcomesTables_cond{j} = subTables_cond{j}(:,3:end-1);
        [gPC_cond{j}, gPCidI_cond{j}] = findgroups(subgroupTables_cond{j});
        for outcomes_c = 1:size(suboutcomesTables_cond{j}, 2)
            mean_gPC_cond{j}(:,outcomes_c) = splitapply(@mean, suboutcomesTables_cond{j}(:,outcomes_c), gPC_cond{j});
            std_gPC_cond{j}(:,outcomes_c) = splitapply(@std, suboutcomesTables_cond{j}(:,outcomes_c), gPC_cond{j});

        end
    end
end
legend_no = [];
for outtoPlot = 1:7
    for section = 1:size(unique(g),1)
        if section == 1 || section == 12 || section == 13
            continue;
        else
            figure(outtoPlot);
            subplot(2,1,1)
            plot(mean_gPC_cond{1,section}(:,outtoPlot))
            hold on
            subplot(2,1,2)
            plot(std_gPC_cond{1,section}(:,outtoPlot))
            hold on
            legend_no = [legend_no; section];
        end
    end
    legend(num2str(legend_no));
    hold off;

end

close all
clearvars -except hPC_allParams gPC_allParams HrefData GaitData

hgPC_allParams = outerjoin(hPC_allParams,gPC_allParams,'MergeKeys',true);
hgPC_allParams_woNan = rmmissing(hgPC_allParams);

filename = 'Gait_Href_summary.xlsx';
writetable(hgPC_allParams_woNan,filename,'Sheet',1,'Range','A1')
