function param = vec2struct(param_vec,len)
    param.mu =         param_vec(1:len(1)); % mortality of the disease (0.02)
    param.d1 =         param_vec(len(1)+1:len(2));
    param.R0 =         param_vec(len(2)+1:len(3));
    param.gamma =      param_vec(len(3)+1:len(4));
    param.turn_dates = param_vec(len(4)+1:len(5));
    param.t_trans =    param_vec(len(5)+1:len(6));
    param.d2 =         param_vec(len(6)+1:len(7));
end