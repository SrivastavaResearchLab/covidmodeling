function fixed_params = set_sens_vars(fixed_params)
% set parameters used for sensitivity plots
sens_vars.frac_alpha1 = 1;
sens_vars.frac_alpha2 = 1;
sens_vars.frac_alphaB = 1;

fixed_params.sens_vars = sens_vars;
end