function test_data = get_test_data(region, reported_data)
    reported_data = readtable(reported_data);
    
    selected = strcmp(string(reported_data.location),region);
    
    if sum(selected) == 0
        error(string(region) + " can not be found in tests/day data")
    else
        reported_data = reported_data(selected,:);
    end
    
    daily_tests = reported_data.new_tests_smoothed_per_thousand;
    
    test_data.daily_tests = daily_tests;
    test_data.t = reported_data.date;
end