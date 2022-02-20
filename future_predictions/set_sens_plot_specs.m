function fixed_params = set_sens_plot_specs(fixed_params)
% Offsets from the last day of reported data for the start and end of
% sensitivity plots.
sens_plot_specs.start_offset = 0; % start at end of reported data
sens_plot_specs.end_offset = 500; % end 500 days later
 
fixed_params.sens_plot_specs = sens_plot_specs;
end