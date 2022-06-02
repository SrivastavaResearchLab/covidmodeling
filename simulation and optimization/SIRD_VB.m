function dydt = SIRD_VB(t,y,param,fixed_params)
param = vary_params(t,param);

n_var = length(fixed_params.dbeta);

% reshape compartment array into matrix (5 stacks: nUV,nV1,nV2,nVS1,nVS2)
y = reshape(y,[5,numel(y)/5]);

yix = fixed_params.yix;
nS = yix.nS; nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;
nUV = yix.nUV; nV1 = yix.nV1; nV2 = yix.nV2; nVS1 = yix.nVS1; nVS2 = yix.nVS2;

% set vaccination to zero if compartment is below this threshold
vacc_threshold = 1e-6;

V_total = sum(y([nV1 nV2 nVS1 nVS2],[nS nR nRW nI]),'all');
I_total = sum(y(:,nI),'all');
b = calc_beta(V_total, I_total, param);

gamma = param.gamma; mu = param.mu;
gamma_var = fixed_params.gamma_var; mu_var = fixed_params.mu_var;
dbeta = fixed_params.dbeta; t_imm = fixed_params.t_imm;
VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
VE1V = fixed_params.VE1V'; VE2V = fixed_params.VE2V';
VES1 = fixed_params.VES1; VES1V = fixed_params.VES1V';
VES2 = fixed_params.VES2; VES2V = fixed_params.VES2V';
k = fixed_params.k; kw = fixed_params.kw;

% calculate alpha(t)
date = index2date(fixed_params.US_data,fixed_params.start_day,t);
[alpha1,alpha2,alphaB] = calc_alpha(fixed_params,date,y);

% VE(immunity #, variant #)
% immunity #: unvaccinated, first dose, second dose, waning1, waning2
VE = [zeros(1,1+n_var) ; [VE1 VE1V'] ; [VE2 VE2V'] ; [VES1 VES1V'] ; [VES2 VES2V']];

% set vacc. outflow of compartment to zero if below threshold and reproportion
weights = distribute_flows(y,vacc_threshold,nD);

% waning immunity population proportions (for second dose and booster)
propS1 = sum(y(nVS1,:))/(sum(y(nVS1,:)) + sum(y(nV1,:)));
propS2 = sum(y(nVS2,:))/(sum(y(nVS2,:)) + sum(y(nV2,:)));
propV1 = 1 - propS1;
propV2 = 1 - propS2;

% set propS1,propV1 with 1,0 (in case of 0/0=NaN)
if isnan(propS1)
    propS1 = 1; propV1 = 0;
end

if isnan(propS2)
    propS2 = 1; propV2 = 0;
end

% define flows between stacks in stacked compartment model
no_flow = zeros(1,size(y,2));
vacc_inflow = [no_flow ; ...
            alpha1 * weights(nUV,:) ; ...
            alpha2 * (propV1*weights(nV1,:)+propS1*weights(nVS1,:)) + alphaB * propS2*weights(nVS2,:) ; ...
            no_flow ; ...
            no_flow];

vacc_outflow = [alpha1 * weights(nUV,:) ; ...
            alpha2 * propV1*weights(nV1,:) ; ...
            no_flow ; ...
            alpha2 * propS1*weights(nVS1,:) ; ...
            alphaB * propS2*weights(nVS2,:)];

wane_flow = [no_flow ; ...
                -y(nV1,:)/t_imm ; ... % waning immunity from first dose
                -y(nV2,:)/t_imm ; ... % waning immunity from second dose
                y(nV1,:)/t_imm ; ... % waning immunity from first dose
                y(nV2,:)/t_imm]; % waning immunity from second dose

net_flow = vacc_inflow - vacc_outflow + wane_flow;

% calculate variant betas and append original strain beta, gamma,& mu (dbeta=1)
b = [1 dbeta]*b;
gamma = [gamma gamma_var];
mu = [mu mu_var];

dydt = zeros(size(y));
for nimm = [nUV nV1 nV2 nVS1 nVS2] %(1:5)
    S = y(nimm,nS); I = y(nimm,nI); R = y(nimm,nR); RW = y(nimm,nRW); D = y(nimm,nD);
    ve = VE(nimm,:);
    
    % differential equations
    dydt(nimm,nS) = -S*sum((1-ve).*b.*I) + net_flow(nimm,nS);
    dydt(nimm,nI) = (S.*b.*(1-ve) - mu.*gamma - gamma).*I + net_flow(nimm,nI);
    dydt(nimm,nR) = gamma.*I - R/t_imm + net_flow(nimm,nR);
    dydt(nimm,nRW) = R/t_imm + net_flow(nimm,nRW);
    dydt(nimm,nD) = sum(mu.*gamma.*I) + net_flow(nimm,nD);

    % add reinfections
    dydt(nimm,nI) = dydt(nimm,nI) + k.*b.*(1-ve).*I.*(sum(R)-R) ...
                                  + kw.*b.*(1-ve).*I.*(sum(RW)-RW);
    dydt(nimm,nR) = dydt(nimm,nR) - R.*(sum(k.*b.*I)-k.*b.*I);
    dydt(nimm,nRW) = dydt(nimm,nRW) - RW.*(sum(kw.*b.*I)-kw.*b.*I);
end

% reshape compartment matrix back to array
dydt = reshape(dydt,[numel(dydt),1]);
end