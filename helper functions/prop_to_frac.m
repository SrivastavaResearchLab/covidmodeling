function [frac_alpha1_vals,frac_alpha2_vals] = ...
    prop_to_frac(alpha1_base,alpha2_base,alpha1_proportion,alpha2_proportion)
total_doses = alpha1_base + alpha2_base;
frac_alpha1_vals = total_doses*alpha1_proportion/alpha1_base;
frac_alpha2_vals = total_doses*alpha2_proportion/alpha2_base;
end