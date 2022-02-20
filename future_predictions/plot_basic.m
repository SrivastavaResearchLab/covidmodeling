function plot_basic(param,fixed_params,disp_opts,dispName,sens_name,...
    sens_val)
    
    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    end_cases = min(end_day,length(US_data.date));
    
    sens_plot_specs = fixed_params.sens_plot_specs;
    end_offset = sens_plot_specs.end_offset;
    start_offset = sens_plot_specs.start_offset;
    
    end_day = length(US_data.date) + end_offset;
    fixed_params.end_day = end_day;
    
    VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
    VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;
    VES = fixed_params.VES; VESV = fixed_params.VESV';
    
    n_vars = length(fixed_params.dbeta);
    
    % run simulation
    [t,y] = sim_SVIRD(param,fixed_params);
    
    % reshape compartment array into matrix
    y = reshape(y,[size(y,1),4,size(y,2)/4]);

    % recover compartments: y(immunity #, compartment #)
    nS = 1; nR = 2; nD = 3; nI = 4:(4+n_vars);
    nUV = 1; nV1 = 2; nV2 = 3; nVS = 4;

    S = y(:,nUV,nS); V1  = y(:,nV1,nS); V2  = y(:,nV2,nS);
    R = y(:,nUV,nR); VR1 = y(:,nV1,nR); VR2 = y(:,nV2,nR);
    D = sum(y(:,:,nD),2);
    I = squeeze(sum(y(:,:,nI(1)),2));
    Iv = squeeze(sum(y(:,:,nI(2:end)),2));
    VS2 = y(:,nVS,nS); VSR2 = y(:,nVS,nR);
    V = sum(y(:,[nV1 nV2 nVS],[nS nI nR]),[2 3]);
    
    % convert t to datetime in same timeframe
    dt = datetime(datestr(datenum(US_data.date(start_day))+t));
    dt_daily = US_data.date(start_day)+(0:(end_day-start_day));

    % calculate parameters, beta, alpha, and new cases over time
    param_t = vary_params(t,param);
    b = calc_beta(V, I+sum(Iv,2), param_t);
    dbeta = fixed_params.dbeta;
    new_cases = S.*(b.*I + b.*sum(dbeta.*Iv,2)) + ...
            V1.*((1-VE1).*b.*I + b.*sum((1-VE1V).*dbeta.*Iv,2)) + ...
            V2.*((1-VE2).*b.*I + b.*sum((1-VE2V).*dbeta.*Iv,2)) + ...
            VS2.*((1-VES).*b.*I + b.*sum((1-VES).*dbeta.*Iv,2));
    new_cases = new_cases .* N;
    
    [alpha1,alpha2] = calc_alpha(fixed_params,dt_daily);

    S = S.*N; V1 = V1.*N; V2 = V2.*N; VR1 = VR1.*N; VR2 = VR2.*N; R = R.*N; 
    D = D.*N; I = I.*N; Iv = Iv.*N;
    
    t_recorded = datenum(US_data.date(start_day:length(US_data.date)) - ...
        US_data.date(1))+1;
    M0 = fixed_params.M(1); Mf = fixed_params.M(2); dM = fixed_params.M(3); t_dM = fixed_params.M(4);
    M = Mf + (M0-Mf)./(1+exp(dM.*(t_recorded-t_dM)));
    plot(dt,100*new_cases./N,'DisplayName',dispName,...
        'LineWidth',5)
    
    ylabel("New Cases/Day (% Population)")
    ax = gca; ax.YRuler.Exponent = 0; ax.FontSize = 30;
    ytickformat("percentage")
    xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);
%     show_trans(US_data,start_day,param) % DEBUG
    
    if disp_opts.alpha_TS || disp_opts.all_figs
        fig = figure;
        subplot(2,1,1); hold on

        dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
        plot(dt_daily,100*alpha1,"DisplayName",fixed_params.location)
        axis tight;

        ylabel("$\alpha_1$ (1/day)",...
            "interpreter","latex","FontSize",45)
        ylim([0 1.5]);

        xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);
        ax = gca; ax.YRuler.Exponent = 0; ytickformat("percentage");
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        hold off

        subplot(2,1,2); hold on
        plot(dt_daily,100*alpha2,"DisplayName",fixed_params.location)
        axis tight;

        ylabel("$\alpha_2$ (1/day)",...
            "interpreter","latex","FontSize",45)
        xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);
        ax = gca; ax.YRuler.Exponent = 0; ytickformat("percentage");
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        hold off

        if disp_opts.save_figs
            saveas(fig,"./figures/png/alpha_plot_" + sens_name + ...
                num2str(sens_val) + "_" + ...
                string(fixed_params.location) + ".png")
            saveas(fig,"./figures/fig/alpha_plot_dV_" + sens_name + ...
                "_" + num2str(sens_val) + "_" + ...
                string(fixed_params.location) + ".fig")
            saveas(fig,"./figures/eps/alpha_plot_" + sens_name + ...
                "_" + num2str(sens_val) + "_" + ...
                string(fixed_params.location) + ".eps","epsc")
        end
    end

    if disp_opts.stacked_bar || disp_opts.all_figs
        plot_begin_date = US_data.date(end_cases) +  start_offset;
        comp_list = [S,V1,V2,VS2,R+VR1+VR2+VSR2,D,I,Iv];
        fig = plot_stacked_bar(fixed_params,US_data,start_day,...
            end_day,comp_list,dt,sens_name,sens_val,...
            plot_begin_date,end_offset);

        if disp_opts.save_figs
            saveas(fig,"./figures/png/stack_bar_" + sens_name + ...
                "_" + num2str(sens_val) + "_" + ...
                string(fixed_params.location) + ".png")
            saveas(fig,"./figures/fig/stack_bar_" + sens_name + ...
                "_" + num2str(sens_val) + "_" + ... 
                string(fixed_params.location) + ".fig")
            saveas(fig,"./figures/eps/stack_bar_" + sens_name + ...
                "_" + num2str(sens_val) + "_" + ...
                string(fixed_params.location) + ".eps","epsc")
        end
    end
end