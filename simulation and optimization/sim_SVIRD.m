function [t,y] = sim_SVIRD(param,fixed_params)
% fixed simulation parameters
start_day = fixed_params.start_day;
end_day = fixed_params.end_day;

N = fixed_params.N;
n_vars = length(fixed_params.dbeta);

US_data = fixed_params.US_data;
start_dt = index2date(US_data,start_day,start_day);
M = calc_M(fixed_params,start_dt);

% define initial conditions
start_inf = max(1,start_day-round(1/param.gamma(1)));
I0 = M*sum(fixed_params.US_data.average(start_inf:start_day))/N;
R0 = M*sum(fixed_params.US_data.average(1:start_inf))/N;
S0 = 1 - I0 - R0;
ymat = zeros(5,4+n_vars);
nS = 1; nR = 2; nD = 3; nI = 4; nIv = 5:(5+n_vars-1);
nUV = 1; nV1 = 2; nV2 = 3; nVS1 = 4; nVS2 = 5;
ymat(nUV,nS) = S0; ymat(nUV,nR) = R0; ymat(nUV,nI) = I0; t = 0; % initial conditions

% reshape y array into row vector for ode45
y = reshape(ymat,[1,numel(ymat)]);

T = end_day - start_day; % length of simulation (days)
sort_dates = date2index(fixed_params.US_data,start_day,fixed_params.vdate);
[sort_dates,i] = sort(sort_dates);
% ensure sort_dates is a row vector
sort_dates = reshape(sort_dates,[1 numel(sort_dates)]);
sort_dates = [0 sort_dates T];

%set ode solver options
reltol = 1e-6; maxstep = 1; abstol = 1e-6;
options = odeset('RelTol',reltol,'AbsTol',abstol,'MaxStep',maxstep);

for v = 1:(n_vars+1) %one loop per strain in order of incidence
    t_span = [sort_dates(v) sort_dates(v+1)];
    
    y0 = y(end,:);
    if v > 1
        % reshape compartment array into matrix
        y0 = reshape(y0,[5,numel(y0)/5]);
        
        y0(nUV,nIv(i(v-1))) = 1/N; y0(nUV,nS) = y0(nUV,nS)-1/N; % initial conditions (mutation)
        
        % reshape y array into row vector for ode45
        y0 = reshape(y0,[1,numel(y0)]);
    end
    
    [tv,yv] = ode45(@(tsim,ysim) SIRD_VB(tsim,ysim,param,fixed_params),...
        t_span,y0,options);
    
    t = [t(1:end-1) ; tv]; y = [y(1:end-1,:) ; yv];
end
end