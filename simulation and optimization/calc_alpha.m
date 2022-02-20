function [alpha1,alpha2,alphaB] = calc_alpha(fixed_params,dates)

% define parameters to do sensitivity on
sens_vars = fixed_params.sens_vars;
frac_alpha1 = sens_vars.frac_alpha1;
frac_alpha2 = sens_vars.frac_alpha2;
frac_alphaB = sens_vars.frac_alphaB;

% DONT ALLOW S OR V1 TO GO BELOW ZERO FOR FUTURE PREDICTIONS (CHECK PLOTS)
vacc_data = fixed_params.vacc_data;
alpha_transition = fixed_params.alpha_transition;

date_list = vacc_data.date;
alpha1_reported = vacc_data.alpha1_reported;
alpha2_reported = vacc_data.alpha2_reported;
alphaB_reported = vacc_data.alphaB_reported;

alpha1 = zeros(size(dates));
alpha2 = zeros(size(dates));
alphaB = zeros(size(dates));

% no vaccination before there is data
alpha1(date_list(1) > dates) = 0;
alpha2(date_list(1) > dates) = 0;
alphaB(date_list(1) > dates) = 0;

% smoothly transition from last reported date to value for future
% predictions (last reported data point * frac_alpha)
%   _(alpha1)_
if ~fixed_params.retrospective_study
    y1 = alpha1_reported(end);
    y2 = alpha1_reported(end)*frac_alpha1;
else
    vacc_start_date = find(date_list==datetime(fixed_params.vacc_start_date));
    y1 = alpha1_reported(vacc_start_date);
    y2 = alpha1_reported(vacc_start_date)*frac_alpha1;
end

interp_result = cos_interp(y1,y2,(datenum(dates)-datenum(date_list(end)))/alpha_transition);

bool_interp = (date_list(end) < dates) & (date_list(end) + alpha_transition >= dates);
alpha1(bool_interp) = interp_result(bool_interp);
alpha1(date_list(end) + alpha_transition < dates) = alpha1_reported(end)*frac_alpha1;

%   _(alpha2)_
if ~fixed_params.retrospective_study
    y1 = alpha2_reported(end);
    y2 = alpha2_reported(end)*frac_alpha2;
else
    vacc_start_date = find(date_list==datetime(fixed_params.vacc_start_date));
    y1 = alpha2_reported(vacc_start_date);
    y2 = alpha2_reported(vacc_start_date)*frac_alpha2;
end


% y1 = alpha2_reported(end);
% y2 = alpha2_reported(end)*frac_alpha2;

interp_result = cos_interp(y1,y2,(datenum(dates)-datenum(date_list(end)))/alpha_transition);

alpha2(bool_interp) = interp_result(bool_interp);
alpha2(date_list(end) + alpha_transition < dates) = alpha2_reported(end)*frac_alpha2;

%   _(alphaB)_
if ~fixed_params.retrospective_study
    y1 = alphaB_reported(end);
    y2 = alphaB_reported(end)*frac_alphaB;
else
    vacc_start_date = find(date_list==datetime(fixed_params.vacc_start_date));
    y1 = alphaB_reported(vacc_start_date);
    y2 = alphaB_reported(vacc_start_date)*frac_alphaB;
end

% y1 = alphaB_reported(end);
% y2 = alphaB_reported(end)*frac_alphaB;

interp_result = cos_interp(y1,y2,(datenum(dates)-datenum(date_list(end)))/alpha_transition);

alphaB(bool_interp) = interp_result(bool_interp);
alphaB(date_list(end) + alpha_transition < dates) = alphaB_reported(end)*frac_alphaB;

% interpolate data between the dates that data was reported
selected_dates = (dates <= date_list(end)) & (dates >= date_list(1));
alpha1(selected_dates) = interp1(date_list,alpha1_reported,dates(selected_dates));
alpha2(selected_dates) = interp1(date_list,alpha2_reported,dates(selected_dates));
alphaB(selected_dates) = interp1(date_list,alphaB_reported,dates(selected_dates));

% convert to population fraction
alpha1 = alpha1/fixed_params.N;
alpha2 = alpha2/fixed_params.N;
alphaB = alphaB/fixed_params.N;

% alpha must be positive
alpha1 = max(0,alpha1);
alpha2 = max(0,alpha2);
alphaB = max(0,alphaB);
end