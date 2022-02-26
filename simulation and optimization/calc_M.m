function M = calc_M(fixed_params,dates)

test_data = fixed_params.test_data;
Mg = fixed_params.Mg;
Mmax = fixed_params.Mmax;

date_list = test_data.t;
daily_tests = test_data.daily_tests;

% calculate M at reported dates
% daily_tests = tests per 1000 people (smoothed)
M_reported = min(Mmax,Mg./daily_tests);

% initialize M and set at selected dates
M = zeros(size(dates));

reported_bool = ~isnan(test_data.daily_tests);
reported_dates = test_data.t(reported_bool);
reported_data = test_data.daily_tests(reported_bool);
M(dates < reported_dates(1)) = Mmax;
M(dates > reported_dates(end)) = min(Mmax,Mg./reported_data(end));

reported_bool = (dates > reported_dates(1)) & (dates < reported_dates(end));
M(reported_bool) = interp1(date_list,M_reported,dates(reported_bool));

% M(dates > reported_dates(end)) = M_reported(end);

M(~isnan(M)) = max(M(~isnan(M)),2); % actual/reported cases will never be < 2
end