function [param,fixed_params] = set_params(fixed_params, var_data)
nturn_dates = fixed_params.nturn_dates;

% fixed params
param.mu = [0.005];
param.gamma = 1/10;
T = fixed_params.end_day - fixed_params.start_day;
fixed_params.t_imm = 150; % waning immunity time constant (days)

% initial conditions of optimization (default if none saved)
param.d1 = 100*ones(1,nturn_dates+1);
param.turn_dates = (1:nturn_dates)/(nturn_dates+1) * T;
param.t_trans = 50*ones(1,nturn_dates);
param.d2 = 0;
param.R0 = 3;

% set saved, location-specific parameters
[param,fixed_params] = saved_params(fixed_params, nturn_dates, param);

% variant characteristics
n_var = length(fixed_params.dbeta);
fixed_params.mu_var = param.mu * ones(1,n_var);
fixed_params.gamma_var = param.gamma * ones(1,n_var);

% get selected variant's data from GISAID
fixed_params = get_variant_data(var_data, fixed_params);

% establish indexing for compartment array
yix.nS = 1; yix.nD = 2; yix.nI = 3:(3+n_var);
yix.nR = (4+n_var):(4+2*n_var); yix.nRW = (5+2*n_var):(5+3*n_var);
yix.nUV = 1; yix.nV1 = 2; yix.nV2 = 3; yix.nVS1 = 4; yix.nVS2 = 5;
fixed_params.yix = yix;

if fixed_params.optimize_params
    if fixed_params.append_refit_params || fixed_params.append_params
        nturn_dates = nturn_dates+1;
        param.d1 = [param.d1 500];
        param.turn_dates = [param.turn_dates mean([param.turn_dates(end) T])];
        param.t_trans = [param.t_trans 50];
    end
    
    paramLB = param;
    paramUB = param;
    if fixed_params.append_params
        % lower bounds of optimization
        paramLB.d1 = [param.d1 0];
        paramLB.turn_dates = [param.turn_dates param.turn_dates(end)];
        paramLB.t_trans = [param.t_trans 10];
        paramLB.d2 = 0;

        % upper bounds of optimization
        paramUB.d1 = [param.d1 10000];
        paramUB.turn_dates = [param.turn_dates T];
        paramUB.t_trans = [param.t_trans 100];
        paramUB.d2 = 10;
    else
        % lower bounds of optimization
        paramLB.d1 = zeros(1,nturn_dates+1);
        paramLB.R0 = 1; % param.R0;
%         paramLB.gamma = 1/14; % param.gamma;
        paramLB.turn_dates = zeros(1,nturn_dates);
        paramLB.t_trans = 10*ones(1,nturn_dates);
        paramLB.d2 = 0;

        % upper bounds of optimization
        paramUB.d1 = 10000*ones(1,nturn_dates+1); % original bounds!
%         paramUB.d1 = 800*ones(1,nturn_dates+1);
        paramUB.R0 = 6;%param.R0;
%         paramUB.gamma = 1/8;%param.gamma;
        paramUB.turn_dates = T*ones(1,nturn_dates);
        paramUB.t_trans = 100*ones(1,nturn_dates);
        paramUB.d2 = 10;
    end

    if fixed_params.calc_variants
        var_param.dbeta = fixed_params.dbeta;
        var_paramLB.dbeta = zeros(1,length(var_param.dbeta));
        var_paramUB.dbeta = 30*ones(1,length(var_param.dbeta));
%         var_paramLB.dbeta = fixed_params.dbeta;
%         var_paramUB.dbeta = fixed_params.dbeta;
        
        var_param.gamma_var = fixed_params.gamma_var;
        var_paramLB.gamma_var = fixed_params.gamma_var;
        var_paramUB.gamma_var = fixed_params.gamma_var;
%         var_paramLB.gamma_var = [1/41 1/41 1/41];
%         var_paramUB.gamma_var = [1/7 1/7 1/7];
        
%         var_param.vdate = date2index(fixed_params.US_data, fixed_params.start_day, fixed_params.vdate);
        vdate_in = date2index(fixed_params.US_data,fixed_params.start_day,fixed_params.vdate);
        var_param.vdate = vdate_in;
        var_paramLB.vdate = var_param.vdate - 90;
        var_paramUB.vdate = var_param.vdate + 90;
        
        [param,fixed_params] = fit_variant_params(param,paramLB,paramUB,...
                                    fixed_params,var_param,var_paramLB,var_paramUB);
    else
        % calculate optimal parameters
        param = fit_params(param,paramLB,paramUB,fixed_params);
    end
end
end