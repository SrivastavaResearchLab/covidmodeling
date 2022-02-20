function fixed_params = set_sens_vars(fixed_params)
sens_vars.frac_alpha1 = 1;
sens_vars.frac_alpha2 = 1;
sens_vars.alpha_transition = 30;
 
fixed_params.sens_vars = sens_vars;
end