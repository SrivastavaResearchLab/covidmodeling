close all
vacc_data  = 'vaccinations-by-manufacturer.xlsx';
vacc_data = readtable(vacc_data);
for region = ["United States","India","Brazil","Germany","South Korea","South Africa"]
    disp(region)
    figure; hold on
    selected = ismember(string(table2array(vacc_data(:,1))),region);
    country_data = vacc_data(selected,:);
    vnames = string(unique(country_data.vaccine));
    for i = 1:length(vnames)
        v = ismember(string(country_data.vaccine),vnames(i));
        plot(country_data.date(v),country_data.total_vaccinations(v),'DisplayName',vnames(i));
    end
    legend('location','northwest')
    title(region)
end