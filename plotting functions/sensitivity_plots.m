function sensitivity_plots(param, fixed_params, disp_opts)
    colors = fixed_params.colors;
    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    
    var_names = ["original" fixed_params.var_names];
    
    n_var = length(fixed_params.dbeta);
    
    % add variant data to params
    dbeta = fixed_params.dbeta;
    gamma_var = fixed_params.gamma_var;
    vdate = date2index(fixed_params.US_data, fixed_params.start_day, fixed_params.vdate);
    
    [param_vec,len] = struct2vec(param);
    
    len = [len len(end) + cumsum( ...
        [length(dbeta), length(gamma_var), length(vdate)])];
    fixed_params.len = len;
        
    if disp_opts.bgvar_sensitivity
    fig=figure;
    dbeta_iter = [1 1.2 1.4 1.6 1.8 2 2.2 2.4];
    gamma_iter = [1/14 1/12 1/10 1/8];
    for bi = 1:length(dbeta_iter)
        for gi = 1:length(gamma_iter)
            fixed_params.dbeta(1) = dbeta_iter(bi);
            fixed_params.gamma_var(1) = gamma_iter(gi);
            % run simulation
            [t,y] = sim_SVIRD(param,fixed_params);
            
            I = y(:,6); Iv = y(:,9:(9+n_var-1));
            
            % convert t to datetime in same timeframe
            dt = datetime(datestr(datenum(US_data.date(start_day))+t));
            dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
            
            I = I.*N; Iv = Iv.*N;
            
            start_var = find(Iv(:,1),1,'first');
            
            subplot(length(gamma_iter),length(dbeta_iter),(gi-1)*length(dbeta_iter)+bi)
            hold on;
            Ipl = I(start_var:end); Ivpl = Iv(start_var:end,:);
            barv=[Ipl,Ivpl]./sum([Ipl,Ivpl],2).*max([Ipl Ivpl],[],'all');
            barv_daily = interp1(dt(start_var:end),barv,dt_daily);
            barf = bar(dt_daily,barv_daily,'stacked','BarWidth',1);
            barf(1).FaceColor = gray; barf(1).HandleVisibility = 'off';
            plot(dt(start_var:end),Ipl,':','Color',red,'DisplayName','Infected','LineWidth',4)
            set(gca,'xtick',[]); set(gca,'ytick',[])
            
            for i=1:n_var
                f = (n_var+1-i)/(n_var+1);
                barf(i+1).FaceColor = gray*f;
                barf(i+1).DisplayName = 'Infected ('+var_names(i)+')';
                %             barf(i+1).HandleVisibility = 'off';
                plot(dt(start_var:end),Iv(start_var:end,i), ...
                    '--','Color',red*f, ...
                    'DisplayName','Infected ('+var_names(i)+')', ...
                    'LineWidth',4)
            end
            
            if bi == 1
                ylabel(string(1/fixed_params.gamma_var(1)))
            end
            if gi == length(gamma_iter)
                xlabel(string(fixed_params.dbeta(1)))
            end
            
            axis tight; hold off;
            xlim([dt(start_var) dt(end)])
        end
    end
    han = axes(fig,'visible','off');
    han.XLabel.Visible = 'on';
    han.YLabel.Visible = 'on';
    xlabel('$\beta_{var}/\beta_0$','interpreter','latex')
    ylabel('1/$\gamma$','interpreter','latex')

    if disp_opts.save_figs
        saveas(fig,"./png/variant_sensitivity" + string(fixed_params.location) + ".png")
        saveas(fig,"./fig/variant_sensitivity" + string(fixed_params.location) + ".fig")
        saveas(fig,"./eps/variant_sensitivity" + string(fixed_params.location) + ".eps",'epsc')
    end
    end
    
    if disp_opts.beta_gamma_sensitivity
        test_dbeta = [linspace(1,2.5,21); linspace(1.5,3,21); linspace(3.5,5,21)];
        test_gammav = [1./linspace(7,21,21); 1./linspace(7,21,21); 1./linspace(7,21,21)];
        
        for v = 1:length(dbeta)
            dbeta_vec = test_dbeta(v,:);
            gamma_var_vec = test_gammav(v,:);
            dbeta_vec = sort([dbeta_vec dbeta(v)]);

            RMSE(:,:,v) = zeros(length(dbeta_vec),length(gamma_var_vec));
            for db = 1:length(dbeta_vec)
                for gv = 1:length(gamma_var_vec)
                    dbeta = [1.69902 2.18579 4.1];
                    gamma_var = [0.1 0.1 0.1];
                    
                    fprintf("db: %g, gv: %g\n",db,gv)
                    dbeta(v) = dbeta_vec(db);
                    gamma_var(v) = gamma_var_vec(gv);

                    % add dbeta, gamma_var, and vdates as optimizable parameters
                    param_vec(len(7)+1:len(10)) = [dbeta gamma_var vdate];

                    RMSE(db,gv,v) = calc_variant_error(param_vec,fixed_params);
                end
            end

            fig = figure;
            [gamma_var_vec,dbeta_vec] = meshgrid(gamma_var_vec,dbeta_vec);
            surf(dbeta_vec,1./gamma_var_vec,RMSE(:,:,v));
            xlabel("d\beta"); ylabel("1/gamma_{var}"); zlabel("RMSE")

            %use mesh instead of surf for nonuniform grid

            if disp_opts.save_figs
                saveas(fig,"./png/beta_gamma_sensitivity" + string(v) + string(fixed_params.location) + ".png")
                saveas(fig,"./fig/beta_gamma_sensitivity" + string(v) + string(fixed_params.location) + ".fig")
                saveas(fig,"./eps/beta_gamma_sensitivity" + string(v) + string(fixed_params.location) + ".eps",'epsc')
            end

            fig = figure;
            contourf(dbeta_vec,1./gamma_var_vec,RMSE(:,:,v));
            xlabel("d\beta"); ylabel("1/gamma_{var}");

            if disp_opts.save_figs
                saveas(fig,"./png/beta_gamma_sensitivitycont" + string(v) + string(fixed_params.location) + ".png")
                saveas(fig,"./fig/beta_gamma_sensitivitycont" + string(v) + string(fixed_params.location) + ".fig")
                saveas(fig,"./eps/beta_gamma_sensitivitycont" + string(v) + string(fixed_params.location) + ".eps",'epsc')
            end

            [m1,i1] = min(RMSE(:,:,v),[],1);
            [m2,i2] = min(RMSE(:,:,v),[],2);

            subplot(1,2,1)
            plot(dbeta_vec(i1,1),m1)
            xlabel("d\beta"); ylabel("minimum RMSE")
            subplot(1,2,2)
            plot(1./gamma_var_vec(1,i2),m2)
            xlabel("1/\gamma_{var}"); ylabel("minimum RMSE")

            if disp_opts.save_figs
                saveas(fig,"./png/beta_gamma_sensitivitymin" + string(v) + string(fixed_params.location) + ".png")
                saveas(fig,"./fig/beta_gamma_sensitivitymin" + string(v) + string(fixed_params.location) + ".fig")
                saveas(fig,"./eps/beta_gamma_sensitivitymin" + string(v) + string(fixed_params.location) + ".eps",'epsc')
            end
        end
    end
    
    % add cases of each variants plots with multiple values of dbeta, gamma_var and vdate
    if disp_opts.var_params_plots
        red = [255 0 0]/255;
        blue = [0 150 255]/255;
        
        n_tests = 2; % number of sensitivity conditions in each direction
        
        for v = ["delta"] % variant to do sensitivity on
            sens_vi = find(fixed_params.var_names == v); % for indexing
%         for p = ["dbeta","gamma","vdate","kw"] % sensitivity parameter
        for p = ["dbeta","vdate"] % sensitivity parameter

        og_dbeta = fixed_params.dbeta;
        og_gamma_var = fixed_params.gamma_var;
        og_vdate = fixed_params.vdate;
        og_kw = fixed_params.kw;
        kw_test = [0 0 og_kw(sens_vi) 0.5 1];
        
        fig = figure;
        for n = -n_tests:n_tests
            switch p
                case "dbeta"
                    fixed_params.dbeta(sens_vi) = og_dbeta(sens_vi)*(1-n*0.2);
                    sgtitle("relative transmissibility",'fontsize',get(gca,'fontsize'))
                case "gamma"
                    fixed_params.gamma_var(sens_vi) = 1/(1/og_gamma_var(sens_vi) - n*4);
                    sgtitle("infectious period",'fontsize',get(gca,'fontsize'))
                case "vdate"
                    fixed_params.vdate(sens_vi) = og_vdate(sens_vi) + n*14;
                    sgtitle("transmission start date",'fontsize',get(gca,'fontsize'))
                case "kw"
                    if n == -1 continue; end % skip second iteration
                    fixed_params.kw(sens_vi) = kw_test(n+n_tests+1);
                    sgtitle("relative reinfection rate",'fontsize',get(gca,'fontsize'))
            end
            set(subplot(n_var+1,1,sens_vi+1),'Color',[0.96,0.91,0.56])
            
            frac = n/n_tests;

            [t,y] = sim_SVIRD(param,fixed_params);
            
            % reshape compartment array into matrix
            y = reshape(y,[size(y,1),5,size(y,2)/5]);
            
            % create variables for indexing compartment array
            yix = fixed_params.yix; nI = yix.nI;

            % convert t to datetime in same timeframe
            dt = index2date(US_data,start_day,t);

            % calculate new cases over time
            [inflow,outflow] = calc_flows(t,y,param,fixed_params);
            new_cases = squeeze(sum(inflow(:,:,nI),2));
            new_cases = new_cases .* fixed_params.N;

            rf = abs(min(0,frac)); bf = max(0,frac);
            col = rf*red + bf*blue;
            
            for var_i = 1:(n_var+1)
                subplot(n_var+1,1,var_i); hold on
                plot(dt,new_cases(:,var_i),'-','Color',col,'LineWidth',8*(2-abs(frac))/2);
                axis tight
                
                if (var_i > 1) && (p == "vdate")
                    xline(fixed_params.vdate(var_i-1))
                end

                if sens_vi == var_i-1 
                    xline(fixed_params.vdate(sens_vi),'color',col)
                end
                
                ax=gca; ax.YRuler.Exponent = 0; % remove scientific notation
                yt = yticks; set(gca,'YTick',[0 yt(end)])

                axis tight; xl = xlim; xlim([min(dt),xl(2)]);
                yyaxis right; ylabel(var_names(var_i),'color',[0 0 0]) % label variants on right of plot (black text)
                set(gca,'YTickLabel',[])

                xTick = get(gca,'XTickLabel'); set(gca,'XTickLabel',[])
            end
            set(gca,'XTickLabel',xTick) % label only bottom subplot's xaxis
            
            drawnow
            
            % reset variables that were changed for plotting
            fixed_params.dbeta = og_dbeta;
            fixed_params.gamma_var = og_gamma_var;
            fixed_params.vdate = og_vdate;
        end
        
        if disp_opts.save_figs
            % to preserve background color
            set(gcf,'InvertHardcopy','off');
            for dir = ["./","./final figures/"]
                saveas(fig,dir+"png/" + p + "_sensitivitymin" + v + string(fixed_params.location) + ".png")
                saveas(fig,dir+"fig/" + p + "_sensitivitymin" + v + string(fixed_params.location) + ".fig")
                saveas(fig,dir+"eps/" + p + "_sensitivitymin" + v + string(fixed_params.location) + ".eps",'epsc')
            end
        end
        end
        end
    end
end