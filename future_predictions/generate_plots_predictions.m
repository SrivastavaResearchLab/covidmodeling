function disp_opts = generate_plots_predictions(param, fixed_params, disp_opts)
    
    if disp_opts.plot_cases || disp_opts.all_figs
        figure(disp_opts.plot_cases_fig); 
        %-----
        brown=fixed_params.brown;red=fixed_params.red;gray=fixed_params.gray;
        gold=fixed_params.gold;black=fixed_params.black;

        US_data = fixed_params.US_data; N = fixed_params.N;
        start_day = fixed_params.start_day; end_day = fixed_params.end_day;
        end_cases = min(end_day,length(US_data.date));

        VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
        VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;
        var_names = fixed_params.var_names;

        n_var = length(fixed_params.dbeta);

        % run simulation
        [t,y] = sim_SVIRD(param,fixed_params);

        S = y(:,1); V1 = y(:,2); V2 = y(:,3); R = y(:,4); D = y(:,5);
        I = y(:,6); VR1 = y(:,7); VR2 = y(:,8); Iv = y(:,9:(9+n_var-1));

        % convert t to datetime in same timeframe
        dt = datetime(datestr(datenum(US_data.date(start_day))+t));
        dt_daily = US_data.date(start_day)+(0:(end_day-start_day));

        % calculate parameters, beta, alpha, and new cases over time
        param_t = vary_params(t,param);
        b = calc_beta(V1+V2+VR1+VR2, I+sum(Iv,2), param_t);
        dbeta = fixed_params.dbeta;
        new_cases = S.*(b.*I + b.*sum(dbeta.*Iv,2)) + ...
            V1.*((1-VE1).*b.*I + b.*sum((1-VE1V).*dbeta.*Iv,2)) + ...
            V2.*((1-VE2).*b.*I + b.*sum((1-VE2V).*dbeta.*Iv,2));
        new_cases = new_cases .* N;
    %     [alpha1,alpha2] = calc_alpha(fixed_params,dt_daily);

        S = S.*N; V1 = V1.*N; V2 = V2.*N; R = R.*N; D = D.*N;
        I = I.*N; Iv = Iv.*N; VR1 = VR1.*N; VR2 = VR2.*N;

        t_recorded = datenum(dt - US_data.date(1))+1;
        t_daily = datenum(dt_daily - US_data.date(1))+1;

        M0 = fixed_params.M(1); Mf = fixed_params.M(2);
        dM = fixed_params.M(3); t_dM = fixed_params.M(4);

        M_daily = Mf + (M0-Mf)./(1+exp(dM.*(t_daily-t_dM)));
        %-----
        hold on
        set(gcf,"Position",[2 0.2 1500 450])
        title(fixed_params.location)

        bar(US_data.date(start_day:end_cases),US_data.cases(start_day:end_cases).*M_daily,...
            "FaceColor",gray,"EdgeColor",gray,"DisplayName","Daily new cases")
        plot(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases).*M_daily,...
            "-.","Color",brown,"DisplayName","7-day average","LineWidth",8)
        plot(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases),...
            "-.","Color",gold,"DisplayName","7-day average","LineWidth",8)
        plot(dt,new_cases,"-","Color",red,"DisplayName","Model Prediction",...
            "LineWidth",8)
        ylabel("Actual Cases")
        
        yl = ylim; ylim([0 yl(2)]);
        xlim([US_data.date(start_day) US_data.date(end_cases)]);

        title(fixed_params.location);
        
        movegui("northwest")
        ax = gca; ax.YRuler.Exponent = 0;
        
        if disp_opts.stacked_bar
            sens_name = "";
            sens_val = 0;
            comp_list = [S,V1,V2,R,D,I,VR1,VR2,Iv];
            fig = plot_stacked_bar(fixed_params,US_data,start_day,...
                end_day,comp_list,dt,sens_name,sens_val);
            
            if disp_opts.save_figs
                saveas(fig,"./figures/png/stack_bar_cases_" + ...
                    string(fixed_params.location) + ".png")
                saveas(fig,"./figures/fig/stack_bar_cases_" + ...
                    string(fixed_params.location) + ".fig")
                saveas(fig,"./figures/eps/stack_bar_cases_" + ...
                    string(fixed_params.location) + ".eps","epsc")
            end
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.plot_cases_fig,"./figures/png/cases_" + ...
                string(fixed_params.location) + ".png")
            saveas(disp_opts.plot_cases_fig,"./figures/fig/cases_" + ...
                string(fixed_params.location) + ".fig")
            saveas(disp_opts.plot_cases_fig,"./figures/eps/cases_" + ...
                string(fixed_params.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_dV || disp_opts.all_figs
        end_offset = 526;
        dV_list = [0 5 10];
        start_offset = -46;
        
        for i = 1:length(dV_list)
            figure(disp_opts.sens_dV_fig);
            
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;

            US_data = fixed_params2.US_data; N = fixed_params2.N;
            start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
            end_cases = min(end_day,length(US_data.date));

            end_day = length(US_data.date) + end_offset;
            fixed_params2.end_day = end_day;
            %--------------------------------
            param2.d2 = [repelem(param2.d2,length(param2.d1)) dV_list(i)];
            
            new_shift = days(US_data.date(end)-US_data.date(1)-2);
            param2.d1 = [param2.d1 500];
            param2.turn_dates = [param.turn_dates new_shift];
            param2.t_trans = [param.t_trans 100];
            %--------------------------------
            hold on
            set(gcf,"Position",[2 0.2 1000 754])
            
            plot_data_avg(fixed_params2)
            plot_basic(param2, fixed_params2, disp_opts, ...
                sprintf("$d_V$ = %g", param2.d2(end)), 'dV', dV_list(i));
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_dV_fig,"./figures/png/sens_dV_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_dV_fig,"./figures/fig/sens_dV_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_dV_fig,"./figures/eps/sens_dV_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_dI || disp_opts.all_figs
        end_offset = 526;
        dI_list = [40 100 500];
        start_offset = -46;
        
        for i = 1:length(dI_list)
            figure(disp_opts.sens_dI_fig);
            
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;

            US_data = fixed_params2.US_data; N = fixed_params2.N;
            start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
            end_cases = min(end_day,length(US_data.date));

            end_day = length(US_data.date) + end_offset;
            fixed_params2.end_day = end_day;
            %--------------------------------
            param2.d2 = [repelem(param2.d2,length(param2.d1)) 0]; %param2.d2(1)
            
            new_shift = days(US_data.date(end)-US_data.date(1)-2);
            param2.d1 = [param2.d1 dI_list(i)];
            param2.turn_dates = [param.turn_dates new_shift];
            param2.t_trans = [param.t_trans 100];
            %--------------------------------
            hold on
            set(gcf,"Position",[2 0.2 1000 754])
            
            plot_data_avg(fixed_params2)
            plot_basic(param2, fixed_params2, disp_opts, ...
                sprintf("$d_I$ = %g", param2.d1(end)), 'dI', dI_list(i));
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_dI_fig,"./figures/png/sens_dI_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_dI_fig,"./figures/fig/sens_dI_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_dI_fig,"./figures/eps/sens_dI_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_dI_dV || disp_opts.all_figs
        end_offset = 526+81;
        dI_list = [500 350 200];
        dV_list = [0 0 0];
        start_offset = -46-73;
        
        if length(dI_list) ~= length(dV_list)
            error('dI and dV lists must be matched pairs of values')
        end
        
        for i = 1:length(dI_list)
            figure(disp_opts.sens_dI_dV_fig);
            
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;

            US_data = fixed_params2.US_data; N = fixed_params2.N;
            start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
            end_cases = min(end_day,length(US_data.date));

            end_day = length(US_data.date) + end_offset;
            fixed_params2.end_day = end_day;
            %--------------------------------
            param2.d2 = [repelem(param2.d2,length(param2.d1)) dV_list(i)];
            
            new_shift = days(US_data.date(end)-US_data.date(1)-2-49);
            param2.d1 = [param2.d1 dI_list(i)];
            trans_width = 1000;
            param2.turn_dates = [param.turn_dates new_shift+trans_width/2];
            param2.t_trans = [param.t_trans trans_width];
            %--------------------------------
            hold on
            set(gcf,"Position",[2 1 1250 800])
            
            plot_data_avg(fixed_params2)
            plot_basic(param2, fixed_params2, disp_opts, ...
                sprintf("$d_I$ = %g, $d_V$ = %g", param2.d1(end), param2.d2(end)), ...
                'dI,dV', [num2str(dI_list(i)) ',' num2str(dV_list(i))]);
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_dI_dV_fig,"./figures/png/sens_dI_dV_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_dI_dV_fig,"./figures/fig/sens_dI_dV_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_dI_dV_fig,"./figures/eps/sens_dI_dV_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_alpha1 || disp_opts.all_figs
        end_offset = 526;
        alpha_list = [0 1 5 10];
        start_offset = -46;
        
        for i = 1:length(alpha_list)
            figure(disp_opts.sens_alpha1_fig);
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;

            US_data = fixed_params2.US_data; N = fixed_params2.N;
            start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
            end_cases = min(end_day,length(US_data.date));

            end_day = length(US_data.date) + end_offset;
            fixed_params2.end_day = end_day;
            
            hold on
            set(gcf,"Position",[2 0.2 1000 754])
            
            fixed_params2.sens_vars.frac_alpha1 = alpha_list(i);
            
            plot_data_avg(fixed_params2)
            plot_basic(param2, fixed_params2, disp_opts, ...
                "$\alpha_1$ = " + num2str(alpha_list(i)*100) + "\%", ...
                'alpha1', alpha_list(i));
        end

        if disp_opts.save_figs
            saveas(disp_opts.sens_alpha1_fig,...
                "./figures/png/vary_alpha1_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_alpha1_fig,...
                "./figures/fig/vary_alpha1_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_alpha1_fig,...
                "./figures/eps/vary_alpha1_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_alpha2 || disp_opts.all_figs
        end_offset = 526;
        alpha_list = [0 1 5 10];
        start_offset = -46;
        
        for i = 1:length(alpha_list)
            figure(disp_opts.sens_alpha2_fig);
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;

            US_data = fixed_params2.US_data; N = fixed_params2.N;
            start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
            end_cases = min(end_day,length(US_data.date));

            end_day = length(US_data.date) + end_offset;
            fixed_params2.end_day = end_day;
            
            hold on
            set(gcf,"Position",[2 0.2 1000 754]) % set(gcf,"Position",[2 0.2 1300 754])
            
            fixed_params2.sens_vars.frac_alpha2 = alpha_list(i);
            
            plot_data_avg(fixed_params2)
            plot_basic(param2, fixed_params2, disp_opts, ...
                "$\alpha_2$ = " + num2str(alpha_list(i)*100) + "\%", ...
                'alpha2', alpha_list(i));
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_alpha2_fig,...
                "./figures/png/vary_alpha2_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_alpha2_fig,...
                "./figures/fig/vary_alpha2_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_alpha2_fig,...
                "./figures/eps/vary_alpha2_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.sens_alpha_paired || disp_opts.all_figs
        end_offset = 526+81+100-130;
        start_offset = -596;
        alpha1_proportion = [0.25, 0.5, 0.75];
        alpha2_proportion = 1 - alpha1_proportion;
        
        US_data = fixed_params.US_data; N = fixed_params.N;
        start_day = fixed_params.start_day; end_day = fixed_params.end_day;
        end_cases = min(end_day,length(US_data.date));
        
        % Calculate total vaccines (alpha1+alpha2) at end reported data
        dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
        [alpha1_base,alpha2_base,~] = calc_alpha(fixed_params,dt_daily);
        
        % Convert alpha1&2 proportions (proportion of total vaccines
        % allocated to doses 1&2) to frac_alpha1&2 values (fraction of 
        % alpha1&2 at end of reported data allocated to each dose)
        [frac_alpha1_vals,frac_alpha2_vals] = ...
            prop_to_frac(alpha1_base(end),alpha2_base(end),...
            alpha1_proportion,alpha2_proportion);
        
        end_day = length(US_data.date) + end_offset;
        fixed_params.end_day = end_day;
        
        for i = 1:length(alpha1_proportion)
            figure(disp_opts.sens_alpha_paired_fig);
            param2 = param;
            fixed_params2 = fixed_params;
            
            fixed_params2.sens_plot_specs.end_offset = end_offset;
            fixed_params2.sens_plot_specs.start_offset = start_offset;
            
            hold on
            set(gcf,"Position",[2 0.2 1000 754]) % set(gcf,"Position",[2 0.2 1300 754])
            
            fixed_params2.sens_vars.frac_alpha1 = frac_alpha1_vals(i);
            fixed_params2.sens_vars.frac_alpha2 = frac_alpha2_vals(i);
            
            plot_data_avg(fixed_params2)
            
            disp_name = ...
                "Dose 1: " + num2str(alpha1_proportion(i)*100) + ...
                "\%, " + "Dose 2: " + ...
                num2str(alpha2_proportion(i)*100) + "\%";
            plot_basic(param2, fixed_params2, disp_opts, ...
                disp_name, ...
                'alpha1,alpha2', ...
                num2str(alpha1_proportion(i)*100) + "," + num2str(alpha2_proportion(i)*100));
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/png/vary_alpha_paired_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/fig/vary_alpha_paired_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/eps/vary_alpha_paired_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end
    
    if disp_opts.contour_alpha || disp_opts.all_figs
        figure(disp_opts.contour_alpha_fig)
        set(disp_opts.contour_alpha_fig,"Position",[2 0.2 1300 754])
        
        end_offset = 1200;
        
        alpha1_list = linspace(0.5,4,7);
        alpha2_list = linspace(0.5,4,7);
        
        [alpha1_plot,alpha2_plot] = meshgrid(alpha1_list, alpha2_list);
        value_list = zeros(length(alpha2_list),length(alpha1_list));
        
        for j = 1:length(alpha1_list)
            for i = 1:length(alpha2_list)
                % Progress through datapoints
                fprintf(['alpha1: %g of %g, ','alpha2: %g of %g\n'],j,...
                    length(alpha1_list),i,length(alpha2_list))
                
                param2 = param;
                fixed_params2 = fixed_params;
            
                fixed_params2.sens_plot_specs.end_offset = end_offset;
                
                fixed_params2.sens_vars.frac_alpha1 = alpha1_list(j);
                fixed_params2.sens_vars.frac_alpha2 = alpha2_list(i);

                US_data = fixed_params2.US_data; N = fixed_params2.N;
                start_day = fixed_params2.start_day; end_day = fixed_params2.end_day;
                end_cases = min(end_day,length(US_data.date));

                end_day = length(US_data.date) + end_offset;
                fixed_params2.end_day = end_day; % set(gcf,"Position",[2 0.2 1000 754])
                

                VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
                VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;
                VES = fixed_params.VES; VESV = fixed_params.VESV';

                n_vars = length(fixed_params2.dbeta);

                % run simulation
                [t,y] = sim_SVIRD(param,fixed_params2);

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
                
                % calculate parameters, beta, alpha, and new cases over time
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
                
                start_ind = find(dt_daily == US_data.date(end));
                
                new_cases = interp1(dt,new_cases,dt_daily);
                value_list(i,j) = sum(new_cases(start_ind:end));
            end
        end
        
        % Plot contour plot
        [c,h] = contourf(alpha1_plot*100,alpha2_plot*100,value_list,5);

        % Formatting
        h.LineWidth = 2;

        h.LevelList = round(h.LevelList,2);
        clabel(c,h,"FontSize",30,"Color","red","LabelSpacing", 900)

        ylabel("Relative Second Vaccination Rate, $\alpha_2$","Interpreter","latex")
        xlabel("Relative First Vaccination Rate, $\alpha_1$","Interpreter","latex")
           
        xtickformat("percentage")
        ytickformat("percentage")
        
        if disp_opts.save_figs
            saveas(disp_opts.contour_alpha_fig,...
                "./figures/png/contour_alpha_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.contour_alpha_fig,...
                "./figures/fig/contour_alpha_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.contour_alpha_fig,...
                "./figures/eps/contour_alpha_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        
        if disp_opts.save_data_contour
            writematrix(alpha1_plot*100,'./countour/alpha1_plot.csv')
            writematrix(alpha2_plot*100,'./countour/alpha2_plot.csv')
            writematrix(value_list,'./countour/value_list.csv')
        end
    end
    
    if disp_opts.legend || disp_opts.all_figs
        plot_legend(disp_opts,fixed_params2) 
        if disp_opts.save_figs
            saveas(disp_opts.legend_fig,"./figures/png/legend.png")
            saveas(disp_opts.legend_fig,"./figures/fig/legend.fig")
            saveas(disp_opts.legend_fig,"./figures/eps/legend.eps","epsc")
        end
    end
    
    if disp_opts.write_colormap
        cmap = [...
            0 0 0.5156;...
            0 0 0.8750;...
            0 0.2344 1.0000;...
            0 0.5938 1.0000;...
            0 0.9531 1.0000;...
            0.3125 1.0000 0.6875;...
            0.6719 1.0000 0.3281;...
            1.0000 0.9688 0;...
            1.0000 0.6094 0;...
            1.0000 0.2500 0;...
            0.8906 0 0;...
            0.5312 0 0;...
            ];
        writematrix(cmap,'./colormap/cmap.csv')
    end
end