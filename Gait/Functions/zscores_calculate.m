parameter_list = fieldnames(results);
Subject = ["HOME_59","JOTE_05","VUDI_31","VEPA_66","TICE_85","ZAMA_78","XALE_91",...
    "HADU_18","ORIN_97","BUYO_36","EBOF_68","DUZI_38","BAFO_45","JOFO_67","NIRO_66",...
    "FANU_27","DEPU_99","PSLD_28","NUDI_96","BUYO_36"];

T_Final = table;
p = 1;
zscor_xnan = @(x) bsxfun(@rdivide, bsxfun(@minus, x, mean(x,'omitnan')), std(x, 'omitnan'));

%% Z - score
for i = 1:length(parameter_list)
    if strcmp((parameter_list{i}),'cadence') ~= 1
        mean_std_CV = fieldnames(results.(parameter_list{i}));
        for j = 1:length(mean_std_CV)
            T_temp = table;
            condition = fieldnames(results.(parameter_list{i}).(mean_std_CV{j}));
            for k = 1:length(condition)
                if condition{k}(end) == '0'
                    if p == 1
                        temp = rmoutliers(results.(parameter_list{i}).(mean_std_CV{j}).(condition{k})(:,:),'quartiles');
                        temp_outlierremoved = table(repelem(condition{k},[size(temp,1)],[1]),temp(:,1),temp(:,2));
                    else
                        temp = rmoutliers(results.(parameter_list{i}).(mean_std_CV{j}).(condition{k})(:,:),'quartiles');
                        temp_outlierremoved = table(temp(:,1),temp(:,2));
                    end
                    T_temp = [T_temp; temp_outlierremoved];
                end
            end
            if p == 1
                T = table(T_temp.Var1,zscor_xnan(T_temp.Var2),zscor_xnan(T_temp.Var3));
                T_Final = [T_Final T];
                T_Final.Properties.VariableNames = {'Conditions',[(parameter_list{i}),'L','_',(mean_std_CV{j})],[(parameter_list{i}),'R','_',(mean_std_CV{j})]};
                p = p + 1;
            else
                T = [zscor_xnan(T_temp.Var1) zscor_xnan(T_temp.Var2)];
                if size(T_Final,1) > size(T,1)
                    T = padarray(T,[(size(T_Final,1) - size(T,1))],NaN,'post');
                    T = table(T(:,1),T(:,2));
                else
                    T = table(T(1:size(T_Final,1),1),T(1:size(T_Final,1),2));
                end
                T_Final = [T_Final T];
                T_Final.Properties.VariableNames{end-1} = [(parameter_list{i}),'L','_',(mean_std_CV{j})];
                T_Final.Properties.VariableNames{end} = [(parameter_list{i}),'R','_',(mean_std_CV{j})];
            end
            clear T temp_outlierremoved
        end
    end
end

filename = 'patientdata_1.xlsx';
writetable(T_Final,filename)
