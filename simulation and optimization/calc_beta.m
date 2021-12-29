function beta = calc_beta(V,I,param)
%get parameters from param struct
beta0 = param.R0.*param.gamma; d1 = param.d1; d2 = param.d2;

% f1 = beta1 + (1 - beta1).*exp(-d1.*I);
f1 = exp(-d1.*I);
f2 = 1./f1 + (1 - 1./f1).*exp(-d2.*V);
beta = beta0 .* f1 .* f2;
end