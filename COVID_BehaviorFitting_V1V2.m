%% Load Datasets
close all;
tic
addpath('helper functions','source data',...
    'plotting functions','simulation and optimization')

JHU_data = 'global covid cases feb26.xlsx';
pop_file = 'global population data.xlsx';
vacc_file = 'vaccinations feb26.xlsx';
test_file = 'daily_tests data feb26.xlsx';
variant_file = 'gisaid_variants feb26.xlsx';
new_data = 0;  % 1 to download above files, 0 to check if data already loaded

% Set default plot settings
if exist('fixed_params','var')
    fixed_params = set_plot_defaults(fixed_params);
else
    fixed_params = set_plot_defaults(struct);
end

%% Set Simulation Options
fixed_params.optimize_params = 0;
fixed_params.append_params = 0;
fixed_params.append_refit_params = 0;
fixed_params.plot_optim = 1;
fixed_params.calc_variants = 1;
fixed_params.retrospective_study = 0;

% set display options
disp_opts.print_params = 0; disp_opts.fname="";
disp_opts.SVEIRD_plot = 0;
disp_opts.stacks_plot = 0;
disp_opts.plot_cases = 1; disp_opts.show_trans = 1;
disp_opts.combined_beta = 0;
disp_opts.combined_d1 = 0;
disp_opts.combined_cases = 0;
disp_opts.combined_M = 0;
disp_opts.combined_alpha = 0;
disp_opts.check_variants = 1; % reported/predicted variants over time

disp_opts.variant_plot = 0; % variant proportions over time
disp_opts.bgvar_sensitivity = 0; % RMSE as function of (beta,gamma)
disp_opts.beta_gamma_sensitivity = 0; % grid of variant curves by (beta,gamma)
disp_opts.var_params_plots = 0; % sensitivity on each variant parameter
disp_opts.combined_phi = 0; % dbeta*VE for each variant/dosage
disp_opts.combined_phi3d = 0; % dbeta*VE for each variant/dosage

disp_opts.test_wane = 0; % test simulation with only vaccinations (no infections)

disp_opts.legend = 0;
disp_opts.all_figs = 0;
disp_opts.save_figs = 1;

disp_opts = create_figures(disp_opts);

%% Set Populations
% india germany canada brazil japan US
loc_list.US = 'United States'; % title for legend
pop_names.US = "United States of America"; % name in UN population spreadsheet
JHU_names.US = "US"; % location name in JHU spreadsheet
var_names.US = "USA";
td_list.US = 9;

loc_list.IN = 'India';
td_list.IN = 7;

loc_list.DE = 'Germany';
td_list.DE = 7;

loc_list.CA = 'Canada';
td_list.CA = 6;

loc_list.BR = 'Brazil';
td_list.BR = 5;

loc_list.KR = 'South Korea';
pop_names.KR = "Republic of Korea";
JHU_names.KR = "Korea, South";
td_list.KR = 8;

loc_list.JP = 'Japan';
td_list.JP = 11;

loc_list.ZA = 'South Africa';
td_list.ZA = 5;

% fn = fieldnames(loc_list);
% fn = {'DE'}; %ZA,DE
fn = {'US','DE','IN','JP','ZA'}; %BR
disp_opts.all_countries = string(cell2mat(fn'))';
for k = 1:length(fn)

location = loc_list.(fn{k});
nturn_dates = td_list.(fn{k});
disp_opts.abbrev = fn{k};

if isfield(pop_names,fn{k})
      pop_name = pop_names.(fn{k});
else; pop_name = loc_list.(fn{k});
end

if isfield(JHU_names,fn{k})
      JHU_name = JHU_names.(fn{k});
else; JHU_name = loc_list.(fn{k});
end

if isfield(var_names,fn{k})
      vsheet_name = var_names.(fn{k});
else; vsheet_name = loc_list.(fn{k});
end

fprintf(1, ['\n' loc_list.(fn{k}) '\n']);

% get data from source
if new_data || ~exist('case_data','var') || ~any(strcmp(case_data.selected,JHU_name))
    disp('loading new data')
    [case_data,N] = set_population(JHU_data,pop_file,pop_name,JHU_name);
    fixed_params.test_data = get_test_data(location, test_file);
    fixed_params.vacc_data = get_vacc_data(location, vacc_file);
end
var_data.vsheet_name = vsheet_name; var_data.variant_file = variant_file;

%% Optimize Parameters and Run Simulation
% time frame used to fit parameters
start_day = 53;
end_day = length(case_data.cases); % 358+46;

% length of simulation (days)
T = end_day - start_day;
t_span = [0 T];

% set fixed_param array for simulation
fixed_params.US_data = case_data; fixed_params.start_day = start_day; 
fixed_params.end_day = end_day; fixed_params.nturn_dates = nturn_dates;
fixed_params.N = N; fixed_params.location = location;
fixed_params.show_trans = disp_opts.show_trans;
fixed_params.alpha_transition = 50; % for future predictions

if disp_opts.print_params && ~isempty(char(disp_opts.fname))
	fid = fopen(disp_opts.fname, 'a+');
    fprintf(fid, ['\n' char(datetime(clock)) '\n']);
end

fixed_params = set_sens_vars(fixed_params);

[param,fixed_params] = set_params(fixed_params, var_data);

print_params(param, fixed_params, disp_opts)

disp_opts = generate_plots(param, fixed_params, disp_opts);

save_legend(disp_opts)

sensitivity_plots(param, fixed_params, disp_opts);
end
toc
set(0,'DefaultFigureVisible','on')
%% Curve Fitting

%% Run Simulation

%% Model Equations

%% Calculate varying alpha
