function dydt = SIRD_VB(t,y,param,fixed_params)
param = vary_params(t,param);

n_var = length(fixed_params.dbeta);

% reshape compartment array into matrix
y = reshape(y,[4,numel(y)/4]);

nS = 1; nR = 2; nD = 3; nI = 4:(4+n_var);
nUV = 1; nV1 = 2; nV2 = 3; nVS = 4;

threshold = 1e-6;

V_total = sum(y([nV1 nV2 nVS],[nS nR nI]),'all');
I_total = sum(y(:,nI),'all');
b = calc_beta(V_total, I_total, param);

gamma = param.gamma; mu = param.mu;
gamma_var = fixed_params.gamma_var; mu_var = fixed_params.mu_var;
dbeta = fixed_params.dbeta; t_imm = fixed_params.t_imm;
VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
VE1V = fixed_params.VE1V'; VE2V = fixed_params.VE2V';
VES = fixed_params.VES; VESV = fixed_params.VESV';

% calculate alpha(t)
date = index2date(fixed_params.US_data,fixed_params.start_day,t);
[alpha1,alpha2,alpha3] = calc_alpha(fixed_params,date);

% VE(immunity #, variant #)
% immunity #: unvaccinated, first dose, second dose, waning immunity
VE = [zeros(1,1+n_var) ; [VE1 VE1V'] ; [VE2 VE2V'] ; [VES VESV']];

% WANING IMMUNITY FROM UNVACCINATED, RECOVERED? **NO REINFECTIONS?
upflow = [0 ; 0 ; 0 ; alpha3];
downflow = [alpha1 ; alpha2 ; 1/t_imm ; 0];

upflow   = repmat(upflow,  [1,size(y,2)]);
downflow = repmat(downflow,[1,size(y,2)]);

% set vacc. outflow of compartment to zero if below threshold and reproportion
[upflow,downflow] = check_empty(y,upflow,downflow,threshold,nD);

% pad outflow matrices
pad = zeros(1,size(upflow,2));
upflow = [pad ; upflow ; pad];
downflow = [pad ; downflow ; pad];

% calculate variant betas and append original strain beta, gamma,& mu (dbeta=1)
b = [1 dbeta]*b;
gamma = [gamma gamma_var];
mu = [mu mu_var];

dydt = zeros(size(y));
for nimm = 1:4
    S = y(nimm,nS); I = y(nimm,nI); R = y(nimm,nR); D = y(nimm,nD);
    ve = VE(nimm,:);
    
    % calculate net outflow for each immunity level
    outflow = -upflow(nimm+1,:) - downflow(nimm+1,:) + upflow(nimm+2,:) + downflow(nimm,:);
    
    % differential equations
    dydt(nimm,nS) = -S*sum((1-ve).*b.*I) + outflow(nS);
    dydt(nimm,nI) = (S.*b.*(1-ve) - mu.*gamma - gamma).*I + outflow(nI);
    dydt(nimm,nR) = sum(gamma.*I) + outflow(nR);
    dydt(nimm,nD) = sum(mu.*gamma.*I) + outflow(nD);
end

% reshape compartment matrix back to array
dydt = reshape(dydt,[numel(dydt),1]);
end