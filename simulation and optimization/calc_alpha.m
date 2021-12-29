function [alpha1,alpha2,alpha3] = calc_alpha(fixed_params,dates)
% define parameters to do sensitivity on
sens_vars = fixed_params.sens_vars;
frac_alpha1 = sens_vars.frac_alpha1;
frac_alpha2 = sens_vars.frac_alpha2;

% DONT ALLOW S OR V1 TO GO BELOW ZERO FOR FUTURE PREDICTIONS
vacc_data = fixed_params.vacc_data;
alpha_transition = fixed_params.alpha_transition;

people_fully_vaccinated = [0 ; vacc_data.people_fully_vaccinated];
people_vaccinated = [0 ; vacc_data.people_vaccinated];
date_list = vacc_data.date;

alpha2_reported = diff(people_fully_vaccinated);
alpha1_reported = diff(people_vaccinated);

alpha1 = zeros(size(dates));
alpha2 = zeros(size(dates));

% no vaccination before there is data
alpha1(date_list(1) > dates) = 0;
alpha2(date_list(1) > dates) = 0;

% alpha remains at final reported rate for future dates

y1 = alpha1_reported(end);
y2 = alpha1_reported(end)*frac_alpha1;

interp_result = cos_interp(y1,y2,(datenum(dates)-datenum(date_list(end)))/alpha_transition);

alpha1((date_list(end) < dates) & ...
       (date_list(end) + alpha_transition >= dates)) = ...
    interp_result((date_list(end) < dates) & ...
                  (date_list(end) + alpha_transition >= dates));
alpha1(date_list(end) + alpha_transition < dates) = alpha1_reported(end)*frac_alpha1;
%     alpha1(date_list(end) < dates) = alpha1_reported(end)*frac_alpha1;

y1 = alpha2_reported(end);
y2 = alpha2_reported(end)*frac_alpha2;

interp_result = cos_interp(y1,y2,(datenum(dates)-datenum(date_list(end)))/alpha_transition);

alpha2((date_list(end) < dates) & ...
    (date_list(end) + alpha_transition >= dates)) = ...
    interp_result((date_list(end) < dates) & ...
    (date_list(end) + alpha_transition >= dates));
alpha2(date_list(end) + alpha_transition < dates) = alpha2_reported(end)*frac_alpha2;
%     alpha2(date_list(end) < dates) = alpha2_reported(end)*frac_alpha2;

selected_dates = (dates <= date_list(end)) & (dates >= date_list(1));
% selected_reported = ismember(date_list,dates);
alpha1(selected_dates) = interp1(date_list,alpha1_reported,dates(selected_dates));
alpha2(selected_dates) = interp1(date_list,alpha2_reported,dates(selected_dates));
% alpha1(selected_dates) = alpha1_reported(selected_reported);
% alpha2(selected_dates) = alpha2_reported(selected_reported);

% convert to population fraction
alpha1 = alpha1/fixed_params.N;
alpha2 = alpha2/fixed_params.N;

% alpha must be positive
alpha1 = max(0,alpha1);
alpha2 = max(0,alpha2);

% set rate of booster shot
alpha3 = 0;
end