clear; close; clc;
%% Setting Directory for data
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Non Mac\n');

switch ifMac

    case 0
        TestPath1 = '/Volumes/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_HRX_Walking/project_only/01_Data';
        pathCompSep = '/';

    case 1
        %         TestPath1    = 'C:\Users\ykuk0\Desktop\HRX\';
        TestPath1 = '\\hest.nas.ethz.ch\green_groups_lmb_public\Projects\NCM\NCM_EXP\NCM_STM\NCM_HRX_Walking\project_only\01_Data\';
        pathCompSep  = '\';
end

destPath = [TestPath1,'Results',pathCompSep,'Gait'];

%% Loading data
matFiles = dir(fullfile([TestPath1,'Results',pathCompSep,'Gait'],'*.mat')) ;
for matfiles_load = 1:length(matFiles)
    load(fullfile(matFiles(matfiles_load).folder, matFiles(matfiles_load).name));
end

%% Allocating data
Final_VariableNames = {'Subject','LoR','dls','Stride Time','Stance Phase','Step length','Step Width','Stride Length','Swing Phase','MoS_Medial','MoS_AP','Locations'};
RAWDATA.dls = dls;
RAWDATA.durationGaitCycle = durationGaitCycle;
RAWDATA.stancePhase       = stancePhase;
RAWDATA.steplength        = steplength;
RAWDATA.stepwidth         = stepwidth;
RAWDATA.stridelength      = stridelength;
RAWDATA.swingPhase        = swingPhase;
RAWDATA.MoS               = MoS;
RAWDATA.HSlocs            = HSloc;
parameter_list            = fieldnames(RAWDATA);
participants_list         = fieldnames(RAWDATA.(parameter_list{1}));

%% Finding the appropriate size to match all the parameters in the same length
for j = 1:length(participants_list)
    for i = 1:length(parameter_list)
        condition = fieldnames(RAWDATA.(parameter_list{i}).(participants_list{j}));
        for k = 1:length(condition)
            length_or_time  = fieldnames(RAWDATA.(parameter_list{i}).(participants_list{j}).(condition{k}).left);
            temp_left_temp  = (RAWDATA.(parameter_list{i}).(participants_list{j}).(condition{k}).left.(length_or_time{1}));
            temp_right_temp = (RAWDATA.(parameter_list{i}).(participants_list{j}).(condition{k}).right.(length_or_time{1}));
            size_parameters_temp.(participants_list{j}).(condition{k}).(parameter_list{i})=  min(length(temp_right_temp), length(temp_left_temp));
        end
    end
    for k = 1:length(condition)
        size_parameters.(participants_list{j}).(condition{k})=  min(cell2mat(struct2cell(size_parameters_temp.(participants_list{j}).(condition{k}))));
    end
end

clearvars -except ...
    RAWDATA Final_VariableNames size_parameters parameter_list participants_list TesPath1 pathCompSep destPath TestPath1...
    cadence dls durationGaitCycle stancePhase steplength stepwidth stridelength swingPhase MoS HSloc

%% ============================= Concatenate to one variable for each  condition ================================ %%
% Writing to excel in the end
% Merging left and right foot together

fnames = fieldnames(stridelength);
mean_std_cv = {'mean','std','CV'};
% creating table for excel
for table_indx = 1:length(parameter_list)-1
    for msc = 1:length(mean_std_cv)
        if strcmp(parameter_list{table_indx},"MoS")
            T_temp.([(parameter_list{table_indx}),'_medial','_',(mean_std_cv{msc})])  = table;
            T_temp.([(parameter_list{table_indx}),'_AP','_',(mean_std_cv{msc})])      = table;
        else
            T_temp.([(parameter_list{table_indx}),'_',(mean_std_cv{msc})])  = table;
        end
    end
end

t = 1;
for i = 1:length(fnames)
    condition = fieldnames(stridelength.(fnames{i}));
    for j = 1:length(condition)
        if i == 1
            results.dls.time_left.(string(condition{j})) = [];
            results.dls.time_right.(string(condition{j})) = [];
            results.durationGaitCycle.time_left.(string(condition{j})) = [];
            results.durationGaitCycle.time_right.(string(condition{j})) = [];
            results.stepwidth.length_left.(string(condition{j})) = [];
            results.stepwidth.length_right.(string(condition{j})) = [];
            results.stridelength.length_left.(string(condition{j})) = [];
            results.stridelength.length_right.(string(condition{j})) = [];
            results.steplength.length_left.(string(condition{j})) = [];
            results.steplength.length_right.(string(condition{j})) = [];
            results.swingPhase.time_left.(string(condition{j})) = [];
            results.swingPhase.time_right.(string(condition{j})) = [];
            results.stancePhase.time_left.(string(condition{j})) = [];
            results.stancePhase.time_right.(string(condition{j})) = [];
            results.MoS.length_left.(string(condition{j})) = [];
            results.MoS.length_right.(string(condition{j})) = [];
            results.cadence.length.(string(condition{j})) = [];
        end
        %% Double limb support time
        results.dls.time_left.(string(condition{j}))     = [results.dls.time_left.(string(condition{j})) dls.(fnames{i}).(condition{j}).left.time];
        results.dls.time_right.(string(condition{j}))    = [results.dls.time_right.(string(condition{j})) dls.(fnames{i}).(condition{j}).right.time];
        results.dls.mean.(string(condition{j}))(t,1)     = dls.(fnames{i}).(condition{j}).left.mean;
        results.dls.mean.(string(condition{j}))(t+1,1)   = dls.(fnames{i}).(condition{j}).right.mean;
        results.dls.std.(string(condition{j}))(t,1)      = dls.(fnames{i}).(condition{j}).left.std;
        results.dls.std.(string(condition{j}))(t+1,1)    = dls.(fnames{i}).(condition{j}).right.std;
        results.dls.CV.(string(condition{j}))(t,1)       = (dls.(fnames{i}).(condition{j}).left.std/dls.(fnames{i}).(condition{j}).left.mean);
        results.dls.CV.(string(condition{j}))(t+1,1)     = (dls.(fnames{i}).(condition{j}).right.std/dls.(fnames{i}).(condition{j}).right.mean);

        results.dls.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.dls.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.dls.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Gait Cycle Duration
        results.durationGaitCycle.time_left.(string(condition{j}))     = [results.durationGaitCycle.time_left.(string(condition{j})) durationGaitCycle.(fnames{i}).(condition{j}).left.time];
        results.durationGaitCycle.time_right.(string(condition{j}))    = [results.durationGaitCycle.time_right.(string(condition{j})) durationGaitCycle.(fnames{i}).(condition{j}).right.time];
        results.durationGaitCycle.mean.(string(condition{j}))(t,1)     = durationGaitCycle.(fnames{i}).(condition{j}).left.mean;
        results.durationGaitCycle.mean.(string(condition{j}))(t+1,1)   = durationGaitCycle.(fnames{i}).(condition{j}).right.mean;
        results.durationGaitCycle.std.(string(condition{j}))(t,1)      = durationGaitCycle.(fnames{i}).(condition{j}).left.std;
        results.durationGaitCycle.std.(string(condition{j}))(t+1,1)    = durationGaitCycle.(fnames{i}).(condition{j}).right.std;
        results.durationGaitCycle.CV.(string(condition{j}))(t,1)       = (durationGaitCycle.(fnames{i}).(condition{j}).left.std/durationGaitCycle.(fnames{i}).(condition{j}).left.mean);
        results.durationGaitCycle.CV.(string(condition{j}))(t+1,1)     = (durationGaitCycle.(fnames{i}).(condition{j}).right.std/durationGaitCycle.(fnames{i}).(condition{j}).right.mean);

        results.durationGaitCycle.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.durationGaitCycle.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.durationGaitCycle.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Step Width
        results.stepwidth.length_left.(string(condition{j}))   = [results.stepwidth.length_left.(string(condition{j})) stepwidth.(fnames{i}).(condition{j}).left.length];
        results.stepwidth.length_right.(string(condition{j}))  = [results.stepwidth.length_right.(string(condition{j})) stepwidth.(fnames{i}).(condition{j}).right.length];
        results.stepwidth.mean.(string(condition{j}))(t,1)     = stepwidth.(fnames{i}).(condition{j}).left.mean;
        results.stepwidth.mean.(string(condition{j}))(t+1,1)   = stepwidth.(fnames{i}).(condition{j}).right.mean;
        results.stepwidth.std.(string(condition{j}))(t,1)      = stepwidth.(fnames{i}).(condition{j}).left.std;
        results.stepwidth.std.(string(condition{j}))(t+1,1)    = stepwidth.(fnames{i}).(condition{j}).right.std;
        results.stepwidth.CV.(string(condition{j}))(t,1)       = (stepwidth.(fnames{i}).(condition{j}).left.std/stepwidth.(fnames{i}).(condition{j}).left.mean);
        results.stepwidth.CV.(string(condition{j}))(t+1,1)     = (stepwidth.(fnames{i}).(condition{j}).right.std/stepwidth.(fnames{i}).(condition{j}).right.mean);

        results.stepwidth.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.stepwidth.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.stepwidth.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Stride length
        results.stridelength.length_left.(string(condition{j}))   = [results.stridelength.length_left.(string(condition{j})) stridelength.(fnames{i}).(condition{j}).left.length];
        results.stridelength.length_right.(string(condition{j}))  = [results.stridelength.length_right.(string(condition{j})) stridelength.(fnames{i}).(condition{j}).right.length];
        results.stridelength.mean.(string(condition{j}))(t,1)     = stridelength.(fnames{i}).(condition{j}).left.mean;
        results.stridelength.mean.(string(condition{j}))(t+1,1)   = stridelength.(fnames{i}).(condition{j}).right.mean;
        results.stridelength.std.(string(condition{j}))(t,1)      = stridelength.(fnames{i}).(condition{j}).left.std;
        results.stridelength.std.(string(condition{j}))(t+1,1)    = stridelength.(fnames{i}).(condition{j}).right.std;
        results.stridelength.CV.(string(condition{j}))(t,1)       = (stridelength.(fnames{i}).(condition{j}).left.std/stridelength.(fnames{i}).(condition{j}).left.mean);
        results.stridelength.CV.(string(condition{j}))(t+1,1)     = (stridelength.(fnames{i}).(condition{j}).right.std/stridelength.(fnames{i}).(condition{j}).right.mean);

        results.stridelength.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.stridelength.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.stridelength.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Step Length
        results.steplength.length_left.(string(condition{j}))   = [results.steplength.length_left.(string(condition{j})) steplength.(fnames{i}).(condition{j}).left.length];
        results.steplength.length_right.(string(condition{j}))  = [results.steplength.length_right.(string(condition{j})) steplength.(fnames{i}).(condition{j}).right.length];
        results.steplength.mean.(string(condition{j}))(t,1)     = steplength.(fnames{i}).(condition{j}).left.mean;
        results.steplength.mean.(string(condition{j}))(t+1,1)   = steplength.(fnames{i}).(condition{j}).right.mean;
        results.steplength.std.(string(condition{j}))(t,1)      = steplength.(fnames{i}).(condition{j}).left.std;
        results.steplength.std.(string(condition{j}))(t+1,1)    = steplength.(fnames{i}).(condition{j}).right.std;
        results.steplength.CV.(string(condition{j}))(t,1)       = (steplength.(fnames{i}).(condition{j}).left.std/steplength.(fnames{i}).(condition{j}).left.mean);
        results.steplength.CV.(string(condition{j}))(t+1,1)     = (steplength.(fnames{i}).(condition{j}).right.std/steplength.(fnames{i}).(condition{j}).right.mean);

        results.steplength.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.steplength.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.steplength.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Swing Phase
        results.swingPhase.time_left.(string(condition{j}))     = [results.swingPhase.time_left.(string(condition{j})) swingPhase.(fnames{i}).(condition{j}).left.time];
        results.swingPhase.time_right.(string(condition{j}))    = [results.swingPhase.time_right.(string(condition{j})) swingPhase.(fnames{i}).(condition{j}).right.time];
        results.swingPhase.mean.(string(condition{j}))(t,1)     = swingPhase.(fnames{i}).(condition{j}).left.mean;
        results.swingPhase.mean.(string(condition{j}))(t+1,1)   = swingPhase.(fnames{i}).(condition{j}).right.mean;
        results.swingPhase.std.(string(condition{j}))(t,1)      = swingPhase.(fnames{i}).(condition{j}).left.std;
        results.swingPhase.std.(string(condition{j}))(t+1,1)    = swingPhase.(fnames{i}).(condition{j}).right.std;
        results.swingPhase.CV.(string(condition{j}))(t,1)       = (swingPhase.(fnames{i}).(condition{j}).left.std/swingPhase.(fnames{i}).(condition{j}).left.mean);
        results.swingPhase.CV.(string(condition{j}))(t+1,1)     = (swingPhase.(fnames{i}).(condition{j}).right.std/swingPhase.(fnames{i}).(condition{j}).right.mean);

        results.swingPhase.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.swingPhase.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.swingPhase.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% Stance Phase
        results.stancePhase.time_left.(string(condition{j}))     = [results.stancePhase.time_left.(string(condition{j})) stancePhase.(fnames{i}).(condition{j}).left.time];
        results.stancePhase.time_right.(string(condition{j}))    = [results.stancePhase.time_right.(string(condition{j})) stancePhase.(fnames{i}).(condition{j}).right.time];
        results.stancePhase.mean.(string(condition{j}))(t,1)     = stancePhase.(fnames{i}).(condition{j}).left.mean;
        results.stancePhase.mean.(string(condition{j}))(t+1,1)   = stancePhase.(fnames{i}).(condition{j}).right.mean;
        results.stancePhase.std.(string(condition{j}))(t,1)      = stancePhase.(fnames{i}).(condition{j}).left.std;
        results.stancePhase.std.(string(condition{j}))(t+1,1)    = stancePhase.(fnames{i}).(condition{j}).right.std;
        results.stancePhase.CV.(string(condition{j}))(t,1)       = (stancePhase.(fnames{i}).(condition{j}).left.std/stancePhase.(fnames{i}).(condition{j}).left.mean);
        results.stancePhase.CV.(string(condition{j}))(t+1,1)     = (stancePhase.(fnames{i}).(condition{j}).right.std/stancePhase.(fnames{i}).(condition{j}).right.mean);

        results.stancePhase.mean.(string(condition{j}))(t:t+1,2) = [1;2];
        results.stancePhase.std.(string(condition{j}))(t:t+1,2)  = [1;2];
        results.stancePhase.CV.(string(condition{j}))(t:t+1,2)   = [1;2];

        %% MoS
        results.MoS.length_left.(string(condition{j}))  =  [results.MoS.length_left.(string(condition{j})); MoS.(fnames{i}).(condition{j}).left.length];
        results.MoS.length_right.(string(condition{j})) =  [results.MoS.length_right.(string(condition{j})); MoS.(fnames{i}).(condition{j}).right.length];

        results.MoS.mean.(string(condition{j}))(t,1)   =  mean(abs(MoS.(fnames{i}).(condition{j}).left.length(:,1))); % ML
        results.MoS.mean.(string(condition{j}))(t+1,1) =  mean(abs(MoS.(fnames{i}).(condition{j}).right.length(:,1))); % ML
        results.MoS.mean.(string(condition{j}))(t,2)   =  mean(MoS.(fnames{i}).(condition{j}).left.length(:,2)); % AP
        results.MoS.mean.(string(condition{j}))(t+1,2) =  mean(MoS.(fnames{i}).(condition{j}).right.length(:,2)); % AP
        results.MoS.std.(string(condition{j}))(t,1)    =  MoS.(fnames{i}).(condition{j}).left.std(:,1);
        results.MoS.std.(string(condition{j}))(t+1,1)  =  MoS.(fnames{i}).(condition{j}).right.std(:,1);
        results.MoS.std.(string(condition{j}))(t,2)    =  MoS.(fnames{i}).(condition{j}).left.std(:,2);
        results.MoS.std.(string(condition{j}))(t+1,2)  =  MoS.(fnames{i}).(condition{j}).right.std(:,1);
        results.MoS.CV.(string(condition{j}))(t,1)     =  results.MoS.std.(string(condition{j}))(t,1)/results.MoS.mean.(string(condition{j}))(t,1);
        results.MoS.CV.(string(condition{j}))(t+1,1)   =  results.MoS.std.(string(condition{j}))(t,2)/results.MoS.mean.(string(condition{j}))(t,2);
        results.MoS.CV.(string(condition{j}))(t,2)     =  results.MoS.std.(string(condition{j}))(t+1,1)/results.MoS.mean.(string(condition{j}))(t+1,1);
        results.MoS.CV.(string(condition{j}))(t+1,2)   =  results.MoS.std.(string(condition{j}))(t+1,2)/results.MoS.mean.(string(condition{j}))(t+1,2);

        results.MoS.mean.(string(condition{j}))(t:t+1,3) = [1;2];
        results.MoS.std.(string(condition{j}))(t:t+1,3) = [1;2];
        results.MoS.CV.(string(condition{j}))(t:t+1,3) = [1;2];

        %% Cadence
        results.cadence.length.(string(condition{j}))    = [results.cadence.length.(string(condition{j})) cadence.(fnames{i}).(condition{j}).length];
        results.cadence.mean.(string(condition{j}))(i,1) = cadence.(fnames{i}).(condition{j}).mean;

        %% Table
        for p = 1:(length(parameter_list)-1)
            for msc = 1:length(mean_std_cv)
                if i == 1 && j == 1
                    if contains(parameter_list{p},'MoS') == 1

                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]) = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,1), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,3));];
                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]).Properties.VariableNames{1} = 'Participant';
                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]).Properties.VariableNames{2} =([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]);
                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]).Properties.VariableNames{3} = 'Condition';
                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]).Properties.VariableNames{4} = 'LorR';

                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]) = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,2), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,3));];
                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]).Properties.VariableNames{1} = 'Participant';
                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]).Properties.VariableNames{2} =([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]);
                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]).Properties.VariableNames{3} = 'Condition';
                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]).Properties.VariableNames{4} = 'LorR';

                    else
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]) = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,1), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,2));];
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]).Properties.VariableNames{1} = 'Participant';
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]).Properties.VariableNames{2} =  ([(parameter_list{p}),'_',(mean_std_cv{msc})]);
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]).Properties.VariableNames{3} = 'Condition';
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]).Properties.VariableNames{4} = 'LorR';
                    end
                else
                    if contains(parameter_list{p},'MoS')
                        temp = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,1), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,3));];
                        temp.Properties.VariableNames{1} = 'Participant';
                        temp.Properties.VariableNames{2} =([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]);
                        temp.Properties.VariableNames{3} = 'Condition';
                        temp.Properties.VariableNames{4} = 'LorR';
                        T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]) = [T_temp.([(parameter_list{p}),'_medial','_',(mean_std_cv{msc})]); temp];

                        temp = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,2), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,3));];
                        temp.Properties.VariableNames{1} = 'Participant';
                        temp.Properties.VariableNames{2} =([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]);
                        temp.Properties.VariableNames{3} = 'Condition';
                        temp.Properties.VariableNames{4} = 'LorR';
                        T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]) = [T_temp.([(parameter_list{p}),'_AP','_',(mean_std_cv{msc})]); temp];

                    else
                        temp = [table(repelem(fnames{i},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,1), repelem(condition{j},2,1),results.(parameter_list{p}).(mean_std_cv{msc}).(string(condition{j}))(t:t+1,2));];
                        temp.Properties.VariableNames{1} = 'Participant';
                        temp.Properties.VariableNames{2} = ([(parameter_list{p}),'_',(mean_std_cv{msc})]);
                        temp.Properties.VariableNames{3} = 'Condition';
                        temp.Properties.VariableNames{4} = 'LorR';
                        T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]) = [T_temp.([(parameter_list{p}),'_',(mean_std_cv{msc})]); temp];
                    end
                end
            end
        end
    end
    t = t + 2;
end

Total = table;
Total_L = table;
Total_R = table;
Total = [T_temp.dls_mean(:,1) T_temp.dls_mean(:,4) T_temp.dls_mean(:,3) T_temp.dls_mean(:,2) T_temp.durationGaitCycle_mean(:,2) T_temp.stancePhase_mean(:,2) T_temp.steplength_mean(:,2) T_temp.stepwidth_mean(:,2) T_temp.stridelength_mean(:,2) T_temp.swingPhase_mean(:,2) T_temp.MoS_medial_mean(:,2) T_temp.MoS_AP_mean(:,2) ...
    T_temp.dls_std(:,2) T_temp.durationGaitCycle_std(:,2) T_temp.stancePhase_std(:,2) T_temp.steplength_std(:,2) T_temp.stepwidth_std(:,2) T_temp.stridelength_std(:,2) T_temp.swingPhase_std(:,2) T_temp.MoS_medial_std(:,2) T_temp.MoS_AP_std(:,2) ...
    T_temp.dls_CV(:,2) T_temp.durationGaitCycle_CV(:,2) T_temp.stancePhase_CV(:,2) T_temp.steplength_CV(:,2) T_temp.stepwidth_CV(:,2) T_temp.stridelength_CV(:,2) T_temp.swingPhase_CV(:,2) T_temp.MoS_medial_CV(:,2) T_temp.MoS_AP_CV(:,2)];

writetable(Total,[destPath,'PatientData.xlsx'], 'Sheet',1)
datasave= fullfile(destPath,'results');
save(datasave,'results','-v7.3');
save(datasave,'Total','-v7.3');

%% ======================================== BOX PLOT -- RAW DATA ================================================ %%
box_plot.dls_boxplot          = [results.dls.mean.har40_0(:,1) results.dls.mean.har20_0(:,1) results.dls.mean.normg_0(:,1) results.dls.mean.wei20_0(:,1) results.dls.mean.wei40_0(:,1)];
box_plot.durationGC_boxplot   = [results.durationGaitCycle.mean.har40_0(:,1) results.durationGaitCycle.mean.har20_0(:,1) results.durationGaitCycle.mean.normg_0(:,1) results.durationGaitCycle.mean.wei20_0(:,1) results.durationGaitCycle.mean.wei40_0(:,1)];
box_plot.stepwidth_boxplot    = [results.stepwidth.mean.har40_0(:,1) results.stepwidth.mean.har20_0(:,1) results.stepwidth.mean.normg_0(:,1) results.stepwidth.mean.wei20_0(:,1) results.stepwidth.mean.wei40_0(:,1)];
box_plot.stridelength_boxplot = [results.stridelength.mean.har40_0(:,1) results.stridelength.mean.har20_0(:,1) results.stridelength.mean.normg_0(:,1) results.stridelength.mean.wei20_0(:,1) results.stridelength.mean.wei40_0(:,1)];
box_plot.steplength_boxplot   = [results.steplength.mean.har40_0(:,1) results.steplength.mean.har20_0(:,1) results.steplength.mean.normg_0(:,1) results.steplength.mean.wei20_0(:,1) results.steplength.mean.wei40_0(:,1)];
box_plot.swingPhase_boxplot   = [results.swingPhase.mean.har40_0(:,1) results.swingPhase.mean.har20_0(:,1) results.swingPhase.mean.normg_0(:,1) results.swingPhase.mean.wei20_0(:,1) results.swingPhase.mean.wei40_0(:,1)];
box_plot.stancePhase_boxplot  = [results.stancePhase.mean.har40_0(:,1) results.stancePhase.mean.har20_0(:,1) results.stancePhase.mean.normg_0(:,1) results.stancePhase.mean.wei20_0(:,1) results.stancePhase.mean.wei40_0(:,1)];
box_plot.MOS_LEFT_ML_boxplot  = [results.MoS.mean.har40_0(:,1) results.MoS.mean.har20_0(:,1) results.MoS.mean.normg_0(:,1) results.MoS.mean.wei20_0(:,1) results.MoS.mean.wei40_0(:,1)];
box_plot.MOS_LEFT_AP_boxplot  = [results.MoS.mean.har40_0(:,2) results.MoS.mean.har20_0(:,2) results.MoS.mean.normg_0(:,2) results.MoS.mean.wei20_0(:,2) results.MoS.mean.wei40_0(:,2)];
box_plot.cadence_boxplot      = [results.cadence.mean.har40_0(:,1) results.cadence.mean.har20_0(:,1) results.cadence.mean.normg_0(:,1) results.cadence.mean.wei20_0(:,1) results.cadence.mean.wei40_0(:,1)];

parameter_list = fieldnames(box_plot);
Files_name  = {'DLS','Stride_Time','Step_Width','Stride_Length','Step_Length','Swing_Phase','Stance_Phase','MoS_ML','MoS_AP', 'Cadence'};
Titles  = {'Double limb Support Time','Stride Time','Step Width','Stride Length','Step Length','Swing Phase','Stance Phase','MoS ML','MoS AP', 'Cadence'};
y_label = {'Time (s)','Time (s)','Width (cm)', 'Length (cm)', 'Time (s)', 'Time (s)', 'Length (mm)','Length (mm)','Length (mm)','Steps per minute'};

for t= 1:length(parameter_list)
    box_plot.(parameter_list{t})(box_plot.(parameter_list{t}) == 0) = NaN; % Replacing zero with NaN to have no effect on the calculation
    figure; boxplot(rmoutliers(box_plot.(parameter_list{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel([y_label{t}]); title(Titles{t});
    saveas(gca,fullfile(destPath, ['\',Files_name{t}]),'fig'); close;
end

%% ========================================= BOX PLOT -- CV ================================================== %%
box_plot_CV.dls_CV_boxplot          = [results.dls.CV.har40_0(:,1) results.dls.CV.har20_0(:,1) results.dls.CV.normg_0(:,1) results.dls.CV.wei20_0(:,1) results.dls.CV.wei40_0(:,1)];
box_plot_CV.durationGC_CV_boxplot   = [results.durationGaitCycle.CV.har40_0(:,1) results.durationGaitCycle.CV.har20_0(:,1) results.durationGaitCycle.CV.normg_0(:,1) results.durationGaitCycle.CV.wei20_0(:,1) results.durationGaitCycle.CV.wei40_0(:,1)];
box_plot_CV.stepwidth_CV_boxplot    = [results.stepwidth.CV.har40_0(:,1) results.stepwidth.CV.har20_0(:,1) results.stepwidth.CV.normg_0(:,1) results.stepwidth.CV.wei20_0(:,1) results.stepwidth.CV.wei40_0(:,1)];
box_plot_CV.stridelength_CV_boxplot = [results.stridelength.CV.har40_0(:,1) results.stridelength.CV.har20_0(:,1) results.stridelength.CV.normg_0(:,1) results.stridelength.CV.wei20_0(:,1) results.stridelength.CV.wei40_0(:,1)];
box_plot_CV.steplength_CV_boxplot   = [results.steplength.CV.har40_0(:,1) results.steplength.CV.har20_0(:,1) results.steplength.CV.normg_0(:,1) results.steplength.CV.wei20_0(:,1) results.steplength.CV.wei40_0(:,1)];
box_plot_CV.swingPhase_CV_boxplot   = [results.stancePhase.CV.har40_0(:,1) results.stancePhase.CV.har20_0(:,1) results.stancePhase.CV.normg_0(:,1) results.stancePhase.CV.wei20_0(:,1) results.stancePhase.CV.wei40_0(:,1)];
box_plot_CV.stancePhase_CV_boxplot  = [results.swingPhase.CV.har40_0(:,1) results.swingPhase.CV.har20_0(:,1) results.swingPhase.CV.normg_0(:,1) results.swingPhase.CV.wei20_0(:,1) results.swingPhase.CV.wei40_0(:,1)];
box_plot_CV.MOS_LEFT_ML_CV_boxplot  = [results.MoS.CV.har40_0(:,1) results.MoS.CV.har20_0(:,1) results.MoS.CV.normg_0(:,1) results.MoS.CV.wei20_0(:,1) results.MoS.CV.wei40_0(:,1)];
box_plot_CV.MOS_LEFT_AP_CV_boxplot  = [results.MoS.CV.har40_0(:,2) results.MoS.CV.har20_0(:,2) results.MoS.CV.normg_0(:,2) results.MoS.CV.wei20_0(:,2) results.MoS.CV.wei40_0(:,2)];
parameter_list_CV = fieldnames(box_plot_CV);

Files_name  = {'DLS_CV','Stride_Time_CV','Step_Width_CV','Stride_Length_CV','Step_Length_CV','Swing_Phase_CV','Stance_Phase_CV','MoS_ML_CV','MoS_APL_CV'};
Titles  = {'Double limb Support Time - CV','Stride Time - CV','Step Width - CV','Stride Length - CV','Step Length - CV','Swing Phase - CV','Stance Phase - CV','MoS ML at LHS - CV','MoS AP at LHS - CV'};

for t= 1:length(parameter_list_CV)
    box_plot_CV.(parameter_list_CV{t})(box_plot_CV.(parameter_list_CV{t}) == 0) = NaN;
    figure; boxplot(rmoutliers(box_plot_CV.(parameter_list_CV{t})),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel('Coefficient of Variation'); title(Titles{t});
    saveas(gca,fullfile(destPath, Files_name{t}),'fig'); close;
end

%% ========================================= Mean & Std values in excel -- CV ================================================== %%
for t= 1:length(parameter_list)
    summarised_value.(parameter_list{t})    = MeanSD_2(box_plot.(parameter_list{t}))';
    if t ~= 10
        summarised_value_CV.(parameter_list_CV{t}) = MeanSD_2(box_plot_CV.(parameter_list_CV{t}))';
    else
        continue
    end
end

%% Plots for Manuscript -- Mean
parameter_list = fieldnames(box_plot);
Titles  = {'Double limb Support Time','Stride Time','Step Width','Stride Length','Step Length','Swing Phase','Stance Phase','MoS ML','MoS AP', 'Cadence'};

% Temporal
indx = 1;figure;
for t= [1,2,6,7]
    subplot(1,4,indx);
    boxplot(rmoutliers(box_plot.(parameter_list{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel([y_label{t}]); title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','Temporal Parameters']),'fig'); close;

% Spatio
indx = 1; figure;
for t= [3,5,4]
    subplot(1,3,indx);
    boxplot(rmoutliers(box_plot.(parameter_list{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel([y_label{t}]); title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','Spatio Parameters']),'fig'); close;

% MoS
indx = 1; figure;
for t= 8:9
    subplot(1,2,indx);
    boxplot(rmoutliers(box_plot.(parameter_list{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel([y_label{t}]); title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','MoS']),'fig'); close;

%% Plots for Manuscript -- CV
parameter_list_CV = fieldnames(box_plot_CV);
Titles  = {'Double limb Support Time - CV','Stride Time - CV','Step Width - CV','Stride Length - CV','Step Length - CV','Swing Phase - CV','Stance Phase - CV','MoS ML at LHS - CV','MoS AP at LHS - CV'};

% Temporal
indx = 1;figure;
for t= [1,2,6,7]
    subplot(1,4,indx);
    boxplot(rmoutliers(box_plot_CV.(parameter_list_CV{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions');  ylabel('Coefficient of Variation'); title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','Temporal_CV']),'fig'); close;

% Spatio
indx = 1; figure;
for t= [3,5,4]
    subplot(1,3,indx);
    boxplot(rmoutliers(box_plot_CV.(parameter_list_CV{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions'); ylabel('Coefficient of Variation');title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','Spatio_CV']),'fig'); close;

% MoS
indx = 1; figure;
for t= 8:9
    subplot(1,2,indx);
    boxplot(rmoutliers(box_plot_CV.(parameter_list_CV{t}),"quartiles"),'Notch','off','Labels',{'Har40','Har20','Normg','Wei20','Wei40'});
    xlabel('Weight Conditions');  ylabel('Coefficient of Variation'); title(Titles{t});
    indx = indx + 1;
end
saveas(gca,fullfile(destPath, ['\','MoS_CV']),'fig'); close;
