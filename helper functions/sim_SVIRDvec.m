function [t,y,param] = sim_SVIRDvec(param_vec,fixed_params)
% runs simulation using vector of parameters (for use in fminsearch)

% define start/stop indices to recover parameters
len = fixed_params.len;

% disease characteristics to optimize
param = vec2struct(param_vec,len);

[t,y] = sim_SVIRD(param,fixed_params);
end