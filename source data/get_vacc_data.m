function vacc_data = get_vacc_data(region, vacc_data)
    vacc_data = readtable(vacc_data);
    
    selected = ismember(string(table2array(vacc_data(:,1))),region);
    
    if sum(selected) == 0
        error(string(region) + " can not be found in vaccination data")
    else
        vacc_data = vacc_data(selected,:);
    end
    
    people_fully_vaccinated = vacc_data.people_fully_vaccinated;
    people_vaccinated = vacc_data.people_vaccinated;
    
    % interpolate and smooth vaccination data (fully vaccinated)
    nanx = isnan(people_fully_vaccinated);
    t=1:numel(people_fully_vaccinated);
    people_fully_vaccinated(nanx) = ...
        interp1(t(~nanx), people_fully_vaccinated(~nanx), t(nanx));
    people_fully_vaccinated = movmean(people_fully_vaccinated,7);
    
    % replace first section of missing data with 0 (no one is fully vaxxed)
    nanx = isnan(people_fully_vaccinated);
    people_fully_vaccinated(nanx) = 0;
    
    % interpolate and smooth vaccination data (any dose)
    nanx = isnan(people_vaccinated);
    t=1:numel(people_vaccinated);
    people_vaccinated(nanx) = ...
        interp1(t(~nanx), people_vaccinated(~nanx), t(nanx));
    people_vaccinated = movmean(people_vaccinated,7);
    
    vacc_data.people_fully_vaccinated = people_fully_vaccinated;
    vacc_data.people_vaccinated = people_vaccinated;
end