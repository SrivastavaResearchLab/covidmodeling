function [param,fixed_params] = fit_variant_params(param0,paramLB,paramUB,...
                            fixed_params,var_param0,var_paramLB,var_paramUB)

% [mu,d1,R0,gamma,mu_var,dbeta,gamma_var,M,turn_dates,t_trans,d2,dbeta]
[param_vec0,len] = struct2vec(param0);
[param_vecLB,~] = struct2vec(paramLB);
[param_vecUB,~] = struct2vec(paramUB);

% add dbeta and gamma_var as optimizable parameters
param_vec0 =  [param_vec0,  var_param0.dbeta  var_param0.gamma_var];
param_vecLB = [param_vecLB, var_paramLB.dbeta var_paramLB.gamma_var];
param_vecUB = [param_vecUB, var_paramUB.dbeta var_paramUB.gamma_var];

% add vdates as optimizable parameters
param_vec0 =  [param_vec0,  var_param0.vdate];
param_vecLB = [param_vecLB, var_paramLB.vdate];
param_vecUB = [param_vecUB, var_paramUB.vdate];

len = [len len(end) + cumsum( ...
    [length(var_param0.dbeta), length(var_param0.gamma_var), length(var_param0.vdate)])];
fixed_params.len = len;

if fixed_params.plot_optim
    fixed_params = create_error_figure(fixed_params);
end

% calculate optimal parameters
error0 = calc_variant_error(param_vec0,fixed_params);
abs_tol = 1e-10;

% plot error values during optimization
options = optimset('PlotFcns',{@optimplotfval});
%     options = optimset('TolFun',abs_tol/error0,'TolX',inf);

global min_RMSE
min_RMSE = inf;

[param_vec,min_RMSE] = ...
    fminsearchbnd(@(param_vec) calc_variant_error(param_vec,fixed_params),...
                    param_vec0,param_vecLB,param_vecUB,options);

% update param struct with optimized parameters
param = vec2struct(param_vec,len);

% move variant_parameters from params to fixed_params
fixed_params.dbeta = param_vec(len(7)+1:len(8));
fixed_params.gamma_var = param_vec(len(8)+1:len(9));
fixed_params.vdate = index2date(fixed_params.US_data, fixed_params.start_day, param_vec(len(9)+1:len(10)));

fprintf("\ndbeta| alpha: %g gamma: %g delta: %g\n",fixed_params.dbeta)
fprintf("gamma| alpha: %g gamma: %g delta: %g\n\n",fixed_params.gamma_var)
end