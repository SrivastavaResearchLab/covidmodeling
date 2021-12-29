function param = fit_params(param0,paramLB,paramUB,fixed_params)

% [mu,d1,R0,gamma,mu_var,dbeta,gamma_var,M,turn_dates,t_trans,d2]
[param_vec0,len] = struct2vec(param0);
[param_vecLB,~] = struct2vec(paramLB);
[param_vecUB,~] = struct2vec(paramUB);
fixed_params.len = len;

if fixed_params.plot_optim
    fixed_params = create_error_figure(fixed_params);
end

% calculate optimal parameters
% fid=figure; fixed_params.fid = fid; hold on
error0 = calc_error(param_vec0,fixed_params);
abs_tol = 1e-10;

% plot error values during optimization
options = optimset('PlotFcns',{@optimplotfval}, ...
    'TolFun',abs_tol/error0,'TolX',inf);
%     options = optimset('TolFun',abs_tol/error0,'TolX',inf);

global min_RMSE
min_RMSE = inf;

[param_vec,min_RMSE] = ...
    fminsearchbnd(@(param_vec) calc_error(param_vec,fixed_params),...
                    param_vec0,param_vecLB,param_vecUB,options);

% update param struct with optimized parameters
param = vec2struct(param_vec,len);
end