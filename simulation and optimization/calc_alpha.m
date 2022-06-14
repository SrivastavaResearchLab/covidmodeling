function [alpha1,alpha2,alphaB] = calc_alpha(fixed_params,dates,y)
arguments
    fixed_params
    dates
    y = []
end

% define parameters to do sensitivity on
sens_vars = fixed_params.sens_vars;
frac_alpha1 = sens_vars.frac_alpha1;
frac_alpha2 = sens_vars.frac_alpha2;
frac_alphaB = sens_vars.frac_alphaB;

% DONT ALLOW S OR V1 TO GO BELOW ZERO FOR FUTURE PREDICTIONS (CHECK PLOTS)
vacc_data = fixed_params.vacc_data;
alpha_transition = sens_vars.alpha_transition; % Changed from: alpha_transition = fixed_params.alpha_transition

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

arr_length = length(alpha1_reported); % Length of alpha1_reported, alpha2_reported, etc.

% Picking array index to start applying frac_alpha1, frac_alpha2, etc.
% Pick date for beginning of vaccination (e.g. 14-Dec-2020) if
% retrospective study, if not then select last date of reported data
if ~fixed_params.retrospective_study
    ind_selected = arr_length;
    % Set alpha for all reported data, interpolating between datapoints as 
    % necessary
    selected_dates = (dates <= date_list(ind_selected)) & (dates >= date_list(1));
    alpha1(selected_dates) = interp1(date_list,alpha1_reported,dates(selected_dates));
    alpha2(selected_dates) = interp1(date_list,alpha2_reported,dates(selected_dates));
    alphaB(selected_dates) = interp1(date_list,alphaB_reported,dates(selected_dates));
else
    % Define compartment indices
    yix = fixed_params.yix;
    nS = yix.nS; nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;
    nUV = yix.nUV; nV1 = yix.nV1; nV2 = yix.nV2; nVS1 = yix.nVS1; nVS2 = yix.nVS2;

    
    boost_start_date = find(alphaB_reported > 0, 1);

    % Set alpha for all reported data, interpolating between datapoints as 
    % necessary
    selected_dates = (dates <= date_list(arr_length)) & (dates >= date_list(1));
    alpha1(selected_dates) = interp1(date_list,alpha1_reported,dates(selected_dates));
    alpha2(selected_dates) = interp1(date_list,alpha2_reported,dates(selected_dates));
    alphaB(selected_dates) = interp1(date_list,alphaB_reported,dates(selected_dates));
    
    % Accounts for problems when certain doses haven't been started yet and
    % they report NaN
    alpha1(isnan(alpha1)) = 0;
    alpha2(isnan(alpha2)) = 0;
    alphaB(isnan(alphaB)) = 0;
    
    % Set alpha for dates after the beginning of vaccination, but before
    % the beginning of the booster
    selected_dates = (dates < date_list(boost_start_date));
    total_doses = alpha1 + alpha2 + alphaB;
    
    frac_alphaB(selected_dates) = 0;
    
    % If there are no more suceptibles, set frac_alpha1 to 0
%     if y(nUV,nS) < fixed_params.unvacc_rate
%         frac_alpha1 = 0;
%     end
    if sum(y(nUV,:),1) < fixed_params.unvacc_rate
        frac_alpha1 = 0;
    end

    if sum(y([nV1 nVS1],:),1) < fixed_params.unvacc_rate
        frac_alpha2 = 0;
    end

    total_frac = frac_alpha1 + frac_alpha2 + frac_alphaB;
    alpha1 = total_doses * (frac_alpha1/total_frac);
    alpha2 = total_doses * (frac_alpha2/total_frac);
    alphaB = total_doses * (frac_alphaB/total_frac);
end

% convert to population fraction
alpha1 = alpha1/fixed_params.N;
alpha2 = alpha2/fixed_params.N;
alphaB = alphaB/fixed_params.N;

% alpha must be positive
alpha1 = max(0,alpha1);
alpha2 = max(0,alpha2);
alphaB = max(0,alphaB);
end