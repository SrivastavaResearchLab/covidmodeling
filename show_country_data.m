% close all
addpath('helper functions','source data',...
    'plotting functions','simulation and optimization')

JHU_file = 'global covid cases nov2.xlsx';
pop_file = 'global population data.xlsx';

JHU_data = readtable(JHU_file,'VariableNamingRule','preserve','ReadVariableNames',1);
pop_data = readtable(pop_file,'VariableNamingRule','preserve','ReadVariableNames',1);

country_names = string(JHU_data.('Country/Region'));
country_names = unique(country_names);

figure
for country = country_names'
    fixed_params.vacc_data = get_vacc_data(location, vacc_file);
    selected = ismember(string(JHU_data.('Country/Region')),country);

    US_data.cases = diff(sum(table2array(JHU_data(selected,5:end)),1));
    US_data.average = movmean(US_data.cases,7);
    US_data.date = datetime(JHU_data(1,6:end).Properties.VariableNames);
    US_data.selected = table2array(JHU_data(selected,2));

    plot(US_data.date,US_data.cases)
    title(US_data.selected{1})
    drawnow
    pause(.1)
end