function [US_data,N] = set_population(JHU_file,pop_file,pop_name,JHU_name)
    % read covid cases and population from JHU and UN datasets
    
    JHU_data = readtable(JHU_file,'VariableNamingRule','preserve','ReadVariableNames',1);
    pop_data = readtable(pop_file,'VariableNamingRule','preserve','ReadVariableNames',1);
    
    if ~isempty(JHU_name)
        selected = ismember(string(JHU_data.('Country/Region')),JHU_name);
    else
        selected = ones(size(JHU_data,1),1);
    end
    
    if sum(selected) == 0
        error("selected location can not be found in JHU daily reports dataset")
    else
        US_data.cases = diff(sum(table2array(JHU_data(selected,5:end)),1));
        US_data.average = movmean(US_data.cases,7);
        US_data.date = datetime(JHU_data(1,6:end).Properties.VariableNames);
        US_data.selected = table2array(JHU_data(selected,2));
    end

    selected = ismember(string(pop_data.Region),pop_name);
    if sum(selected) == 0
        error("selected location can not be found in WHO population size dataset")
    else
        N = table2array(pop_data(selected,end))*1e3;
    end
end