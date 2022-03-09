%% Load Datasets
close all; %clear;
tic

PREFIX = '../';

addpath([PREFIX 'helper functions'],...
    [PREFIX 'source data'],...
    [PREFIX 'plotting functions'],...
    [PREFIX 'simulation and optimization'],...
    [PREFIX PREFIX 'covidmodeling'])

JHU_data = 'global covid cases feb26.xlsx';
pop_file = 'global population data.xlsx';
vacc_file = 'vaccinations feb26.xlsx';
test_file = 'daily_tests data feb26.xlsx';
variant_file = 'gisaid_variants feb26.xlsx';
new_data = 0;

fixed_params.optimize_params = 0;

%% Set Simulation Options
disp_opts.sens_alpha_paired = 1; 
disp_opts.stacked_bar = 1;
%------------------------------
fixed_params.retrospective_study = 1;
fixed_params.vacc_start_date = "14-Dec-2020";
fixed_params.boost_start_date = "13-Aug-2021";

disp_opts.save_figs = 0;

%% Creating figures for simulations
if disp_opts.sens_alpha_paired || disp_opts.all_figs
    disp_opts.sens_alpha_paired_fig = figure;
    figure1 = disp_opts.sens_alpha_paired_fig;
    
    disp_opts.sens_alpha_paired_legend = legend;
    set(disp_opts.sens_alpha_paired_legend,'Interpreter','latex')
    legend boxoff
end

%% Set Populations
% india germany canada brazil japan US
loc_list.US = 'United States'; % title for legend
pop_names.US = "United States of America"; % name in UN population spreadsheet
JHU_names.US = "US"; % location name in JHU spreadsheet
var_names.US = "USA";
td_list.US = 9;

loc_list.IN = 'India';
td_list.IN = 6;

loc_list.DE = 'Germany';
td_list.DE = 5;

loc_list.CA = 'Canada';
td_list.CA = 6;

loc_list.BR = 'Brazil';
td_list.BR = 5;

loc_list.KR = 'South Korea';
pop_names.KR = "Republic of Korea";
JHU_names.KR = ["Korea, South"];
td_list.KR = 7;

% fn = {'IN'};
fn = {'US'};
for k = 1:length(fn)

location = loc_list.(fn{k});
nturn_dates = td_list.(fn{k});

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

fprintf(1, [loc_list.(fn{k}) '\n']);

% get data from source
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
end_day = length(case_data.cases);%358+46;

% length of simulation (days)
T = end_day - start_day;
t_span = [0 T];

% set fixed_param array for simulation
fixed_params.US_data = case_data; fixed_params.start_day = start_day; 
fixed_params.end_day = end_day; fixed_params.nturn_dates = nturn_dates;
fixed_params.N = N; fixed_params.location = location;
% vaccine characteristics
fixed_params = set_plot_defaults(fixed_params);

fixed_params = set_sens_vars(fixed_params);

fixed_params = set_sens_plot_specs(fixed_params);

[param,fixed_params] = set_params(fixed_params, var_data);

disp_opts = generate_plots_predictions(param, fixed_params, disp_opts);
end
toc
set(0,'DefaultFigureVisible','on')