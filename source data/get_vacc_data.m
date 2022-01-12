function data_out = get_vacc_data(region, vacc_data)
    vacc_data = readtable(vacc_data);
    
    selected = ismember(string(table2array(vacc_data(:,1))),region);
    
    if sum(selected) == 0
        error(string(region) + " can not be found in vaccination data")
    else
        vacc_data = vacc_data(selected,:);
    end
    
    people_fully_vaccinated = vacc_data.people_fully_vaccinated;
    people_vaccinated = vacc_data.people_vaccinated;
    total_boosters = vacc_data.total_boosters;
    
    % interpolate and smooth vaccination data (fully vaccinated)
    nanx = isnan(people_fully_vaccinated);
    if sum(~nanx) > 0
        t=1:numel(people_fully_vaccinated);
        people_fully_vaccinated(nanx) = ...
            interp1(t(~nanx), people_fully_vaccinated(~nanx), t(nanx));
        people_fully_vaccinated = movmean(people_fully_vaccinated,7);
    else
        people_fully_vaccinated = zeros(size(nanx));
    end
    
    % replace first section of missing data with 0 (no one is fully vaxxed)
    nanx = isnan(people_fully_vaccinated);
    people_fully_vaccinated(nanx) = 0;
    
    % interpolate and smooth vaccination data (any dose)
    nanx = isnan(people_vaccinated);
    if sum(~nanx) > 0
        t=1:numel(people_vaccinated);
        people_vaccinated(nanx) = ...
            interp1(t(~nanx), people_vaccinated(~nanx), t(nanx));
        people_vaccinated = movmean(people_vaccinated,7);
    else
        people_vaccinated = zeros(size(nanx));
    end

    % interpolate and smooth vaccination data (booster)
    nanx = isnan(total_boosters);
    if sum(~nanx) > 0
        t=1:numel(total_boosters);
        total_boosters(nanx) = ...
            interp1(t(~nanx), total_boosters(~nanx), t(nanx));
        total_boosters = movmean(total_boosters,7);
    else
        total_boosters = zeros(size(nanx));
    end

    people_fully_vaccinated = [0 ; people_fully_vaccinated];
    people_vaccinated = [0 ; people_vaccinated];
    total_boosters = [0 ; total_boosters];

    alpha1_reported = diff(people_vaccinated);
    alpha2_reported = diff(people_fully_vaccinated);
    alphaB_reported = diff(total_boosters);

    data_out.date = vacc_data.date;
    data_out.alpha1_reported = alpha1_reported;
    data_out.alpha2_reported = alpha2_reported;
    data_out.alphaB_reported = alphaB_reported;
end