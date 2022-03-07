function RMSE = calc_variant_error(param_vec,fixed_params)
global min_RMSE

US_data = fixed_params.US_data; 
start_day = fixed_params.start_day; end_day = fixed_params.end_day;
variant_data = fixed_params.variant_data; var_names = fixed_params.var_names;

% move variant_parameters from params to fixed_params
len = fixed_params.len;
fixed_params.dbeta = param_vec(len(7)+1:len(8));
fixed_params.gamma_var = param_vec(len(8)+1:len(9));
fixed_params.vdate = param_vec(len(9)+1:len(10));
fixed_params.vdate = index2date(fixed_params.US_data, fixed_params.start_day, fixed_params.vdate);
param_vec = param_vec(1:fixed_params.len(end-2));

[t,y,param] = sim_SVIRDvec(param_vec,fixed_params);

n_vars = length(fixed_params.dbeta);

% reshape compartment array into matrix (5 stacks: nUV,nV1,nV2,nVS1,nVS2)
y = reshape(y,[size(y,1),5,size(y,2)/5]);

nI = fixed_params.yix.nI;

% convert t to datetime in same timeframe
dt = index2date(US_data,start_day,t);

[inflow,outflow] = calc_flows(t,y,param,fixed_params);
predicted_cases = squeeze(sum(inflow(:,:,nI),2));
predicted_cases = predicted_cases .* fixed_params.N;

t_recorded = datenum(US_data.date(start_day:end_day) - US_data.date(1))+1;
dt_recorded = US_data.date(start_day:end_day);
M = calc_M(fixed_params,dt_recorded);

reported_cases = M.*US_data.average(t_recorded);
v_prop = zeros(length(variant_data.t),n_vars);
for var_i = 1:n_vars
    v_prop(:,var_i) = variant_data.(var_names(var_i));
end
v_prop = [(1-sum(v_prop,2)) v_prop];

% interpolate so predictions occur at same times as recorded data
predicted_cases_weekly = interp1(dt,predicted_cases,variant_data.t);
reported_cases_weekly = interp1(US_data.date(t_recorded),reported_cases,variant_data.t)';

RMSEv = zeros(1,n_vars+1);
for v = 1:(n_vars+1)
    reported_dates = ~isnan(predicted_cases_weekly(:,v));
    reported_vcases = reported_cases_weekly.*v_prop(:,v);
    
    reported_vcases = reported_vcases(reported_dates);
    predicted_vcases = predicted_cases_weekly(reported_dates,v);
    
    RMSEv(v) = sqrt(mean((predicted_vcases-reported_vcases).^2)) / mean(reported_vcases);
end

RMSE = sum(RMSEv);

if fixed_params.plot_optim & (RMSE < min_RMSE)
    pstring = "EWT: %g";
    for var_i = 1:n_vars
        pstring = pstring + " | " + " E" + var_names(var_i) + ": %g";
    end
    pstring = pstring + "|| total: %g\n";
    fprintf(pstring,RMSEv,RMSE);
    
    % plot during optimization
    set(0, 'CurrentFigure', fixed_params.errorfig);
    
    sp = subplot(n_vars+1,1,1); cla(sp); hold on
    bar(variant_data.t,reported_cases_weekly.*v_prop(:,1),1, ...
        'FaceColor',([86 92 97]/255 + 2)/3,'EdgeColor','none');
    plot(dt,predicted_cases(:,1),':','Color',[86 92 97]/255,'LineWidth',8);
    axis tight
    
%     if fixed_params.show_trans
%         show_trans(US_data,start_day,param,fixed_params)
%     end
    
    variant_colors = [200 16 46 ; 134 38 51 ; 0 58 112 ; 50 240 100] ./ 255;
    
    for var_i = 1:n_vars
        sp = subplot(n_vars+1,1,var_i+1); cla(sp); hold on
            bar(variant_data.t,reported_cases_weekly.*v_prop(:,var_i+1), ...
                    1,'FaceColor',(variant_colors(var_i,:) + 2)/3,'EdgeColor','none'); 
        plot(dt,predicted_cases(:,var_i+1),':','Color',variant_colors(var_i,:),'LineWidth',8);
        xline(fixed_params.vdate(var_i));
        axis tight
    end
    
    drawnow
    min_RMSE = RMSE;
end

for n = 1:(length(param.turn_dates) - 1)
    right_bound = param.turn_dates(n) + param.t_trans(n)/2;
    left_bound = param.turn_dates(n+1) - param.t_trans(n+1)/2;
    if right_bound > left_bound
        overlap_mult = 1e9*(right_bound-left_bound)/param.t_trans(n+1);
        RMSE = RMSE*(1+overlap_mult);
    end
end
end