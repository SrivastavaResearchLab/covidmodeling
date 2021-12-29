function RMSE = calc_error(param_vec,fixed_params)
global min_RMSE

US_data = fixed_params.US_data; start_day = fixed_params.start_day; 
end_day = fixed_params.end_day;
brown = fixed_params.brown;

[t,y,param] = sim_SVIRDvec(param_vec,fixed_params);

n_vars = length(fixed_params.dbeta);

% reshape compartment array into matrix
y = reshape(y,[4,numel(y)/4]);

S = y(:,nUV,nS); V1  = y(:,nV1,nS); V2  = y(:,nV2,nS);
R = y(:,nUV,nR); VR1 = y(:,nV1,nR); VR2 = y(:,nV2,nR);
D = sum(y(:,:,nD),2);
I = squeeze(sum(y(:,:,nI(1)),2));
Iv = squeeze(sum(y(:,:,nI(2:end)),2));
VS2 = y(:,nVS,nS); VSR2 = y(:,nVS,nR);

V = sum(y(:,[nV1 nV2 nVS],[nS nI nR]),[2 3]);

param_t = vary_params(t,param);

% convert t to datetime in same timeframe
dt = index2date(US_data,start_day,t);

% calculate parameters, beta, and new cases over time
b = calc_beta(V, I+sum(Iv,2), param_t);
dbeta = fixed_params.dbeta;
VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;

new_cases = S.*(b.*I + b.*sum(dbeta.*Iv,2)) + ...
        V1.*((1-VE1).*b.*I + b.*sum((1-VE1V).*dbeta.*Iv,2)) + ...
        V2.*((1-VE2).*b.*I + b.*sum((1-VE2V).*dbeta.*Iv,2));
new_cases = new_cases .* fixed_params.N;

t_recorded = datenum(US_data.date(start_day:end_day) - US_data.date(1))+1;
% M0 = fixed_params.M(1); Mf = fixed_params.M(2);
% dM = fixed_params.M(3); t_dM = fixed_params.M(4);
% M = Mf + (M0-Mf)./(1+exp(dM.*(t_recorded-t_dM)));
dt_recorded = US_data.date(start_day:end_day);
M = calc_M(fixed_params,dt_recorded);

RI_cases = M.*US_data.average(t_recorded);

% interpolate so predictions occur at same times as recorded data
new_cases = interp1(dt,new_cases,US_data.date(start_day:end_day));

% root mean squared error
RMSE = sqrt(mean((new_cases-RI_cases).^2));
% mean absolute error
% RMSE = mean(abs(new_cases - RI_cases));
RMSE = RMSE / fixed_params.N;

if fixed_params.plot_optim & (RMSE < min_RMSE)
    min_RMSE = RMSE;
    % plot during optimization
    set(0, 'CurrentFigure', fixed_params.fid);
    
    % remove previous fit
    h = findobj('Color',brown,'LineStyle','-');
    delete(h)
    
    yyaxis left
    plot(US_data.date(start_day:end_day),new_cases,'-','Color',brown)
    drawnow
    
    if fixed_params.show_trans
        show_trans(US_data,start_day,param)
    end
end

for n = 1:(length(param.turn_dates) - 1)
    right_bound = param.turn_dates(n) + param.t_trans(n)/2;
    left_bound = param.turn_dates(n+1) - param.t_trans(n+1)/2;
    if right_bound > left_bound
        overlap_mult = 1000*(right_bound-left_bound)/param.t_trans(n+1);
        RMSE = RMSE*(1+overlap_mult);
    end
end
end