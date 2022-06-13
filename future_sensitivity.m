function sens_cases = future_sensitivity(t,y,param,fixed_params,sens_var,sens_vec)
for sens_i = 1:length(sens_vec)
    switch sens_var
        case "start date"
            fixed_params.vdate = [fixed_params.vdate sens_vec(sens_i)];
            fixed_params.dbeta = [fixed_params.vdate 30];
        case "dbeta"
            fixed_params.vdate = [fixed_params.vdate datetime("June 1, 2022")];
            fixed_params.dbeta = [fixed_params.vdate sens_vec(sens_i)];
    end
    
    sens_cases = zeros(length(sens_vec),length(t),length(y));
    for i = 1:length(sens_vec)
    ymat = zeros(5,2+3*(n_var+1));
    ymat(nV1,nS) = 1; % initial conditions
    
    % reshape y array into row vector for ode45
    y0 = reshape(ymat,[1,numel(ymat)]);
    
    %set ode solver options
    reltol = 1e-6; maxstep = 1; abstol = 1e-6;
    options = odeset('RelTol',reltol,'AbsTol',abstol,'MaxStep',maxstep);
    
    fixed_params_test = fixed_params;
    fixed_params_test.vacc_data.alpha1_reported = ...
        zeros(size(fixed_params.vacc_data.alpha1_reported));
    fixed_params_test.vacc_data.alpha2_reported = ...
        zeros(size(fixed_params.vacc_data.alpha2_reported));
    
    [tv,yw] = ode45(@(tsim,ysim) SIRD_VB(tsim,ysim,param,fixed_params_test),...
        [0 4*fixed_params.t_imm],y0,options);
    
    % reshape compartment array into matrix
    yw = reshape(yw,[size(yw,1),5,size(yw,2)/5]);
    V1_test = yw(:,nV1,nS); V1W_test = yw(:,nVS1,nS);
    end
end
end