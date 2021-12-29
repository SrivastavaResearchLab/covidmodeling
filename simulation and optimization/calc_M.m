function M = calc_M(fixed_params,dates)

test_data = fixed_params.test_data;
Mg = fixed_params.Mg;
Mmax = fixed_params.Mmax;

date_list = test_data.t;
daily_tests = test_data.daily_tests;

% calculate M at reported dates
M_reported = min(Mmax,Mg./daily_tests);

% initialize M and set at selected dates
M = zeros(size(dates));

M(dates < date_list(1)) = Mmax;

reported_dates = (dates > date_list(1)) & (dates < date_list(end));
M(reported_dates) = interp1(date_list,M_reported,dates(reported_dates));

M(dates > date_list(end)) = M_reported(end);

% M = max(M,1); % actual/reported cases will never be < 1 % this makes Nan -> 1
end