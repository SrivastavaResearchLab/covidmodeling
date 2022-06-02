function plot_data_avg(fixed_params)
end_offset = fixed_params.sens_plot_specs.end_offset;

brown=fixed_params.colors.brown;

US_data = fixed_params.US_data; N = fixed_params.N;
start_day = fixed_params.start_day; end_day = fixed_params.end_day;
end_cases = min(end_day,length(US_data.date));

end_day = length(US_data.date) + end_offset;
fixed_params.end_day = end_day;

% t_recorded = datenum(US_data.date(start_day:length(US_data.date)) - ...
%     US_data.date(1))+1;
t_recorded = US_data.date(start_day:length(US_data.date));
% dt = datetime(datestr(datenum(US_data.date(start_day))+t));
% M = calc_M(fixed_params,dt);
M_daily = calc_M(fixed_params,t_recorded);

plot(US_data.date(start_day:end_cases),100*US_data.average(start_day:end_cases).*M_daily/N,...
    '-.','Color',brown,'HandleVisibility','off','LineWidth',5)
end