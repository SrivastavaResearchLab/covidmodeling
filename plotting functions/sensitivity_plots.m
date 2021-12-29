function sensitivity_plots(param, fixed_params, disp_opts)
    colors = fixed_params.colors;
    gray = colors.gray; red = colors.red;
    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    
    var_names = fixed_params.var_names;
    
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
        
        n_tests = 2; % number of tests
        
        for v = 1:3
        for p = 1:2 %[dbeta,gamma_var,vdates]
            plot_title = fixed_params.location + "_" + string(v) + "_";
            if p == 1
                dist = 0.05; % distance between tests
                plot_title = plot_title + "beta_";
            elseif p == 2
                dist = 4;
                plot_title = plot_title + "gamma_";
            elseif p == 3
                dist = 5;
                plot_title = plot_title + "vdate_";
            end
        og_dbeta = fixed_params.dbeta;
        og_gamma_var = fixed_params.gamma_var;
        og_vdate = fixed_params.vdate;
        
        fig = figure;
        for n = -n_tests:n_tests
            if p == 1
                fixed_params.dbeta(v) = dbeta(v) + n*dist;
            elseif p == 2
                fixed_params.gamma_var(v) = 1/(1/gamma_var(v) + n*dist);
            elseif p == 3
                fixed_params.vdate(v) = vdate + n*dist;
            end
            
            frac = n/n_tests;

            [t,y] = sim_SVIRD(param,fixed_params);

            n_vars = length(fixed_params.dbeta);
            
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

            param_t = vary_params(t,param);

            % convert t to datetime in same timeframe
            dt = index2date(US_data,start_day,t);

            % calculate parameters, beta, and new cases over time
            b = calc_beta(V, I+sum(Iv,2), param_t);
            dbeta = fixed_params.dbeta; bv = b*dbeta;
            VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
            VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;

            new_cases = S.*(b.*I + b.*sum(dbeta.*Iv,2)) + ...
                V1.*((1-VE1).*b.*I + b.*sum((1-VE1V).*dbeta.*Iv,2)) + ...
                V2.*((1-VE2).*b.*I + b.*sum((1-VE2V).*dbeta.*Iv,2));
            new_casesv = S.*(bv.*Iv) + ...
                V1.*(b.*(1-VE1V).*dbeta.*Iv) + ...
                V2.*(b.*(1-VE2V).*dbeta.*Iv);
            new_cases = new_cases .* fixed_params.N;
            new_casesv = new_casesv .* fixed_params.N;

            new_casesog = new_cases - sum(new_casesv,2);

            rf = abs(min(0,frac)); bf = max(0,frac);
            col = rf*red + bf*blue;
            
            subplot(4,1,1); hold on
            if p==1
                title("d\beta")
            elseif p==2
                title("gamma_{var}")
            elseif p==3
                title("transmission start date")
            end
            plot(dt,new_casesog,'Color',col,'LineWidth',8*(2-abs(frac))/2);
            axis tight
            ylabel('WT')

            subplot(4,1,2); hold on
            plot(dt,new_casesv(:,1),'Color',col,'LineWidth',8*(2-abs(frac))/2);
            axis tight
            ylabel('Alpha'); xline(fixed_params.vdate(1))

            subplot(4,1,3); hold on
            plot(dt,new_casesv(:,2),'Color',col,'LineWidth',8*(2-abs(frac))/2);
            axis tight
            ylabel('Gamma'); xline(fixed_params.vdate(2))

            subplot(4,1,4); hold on
            plot(dt,new_casesv(:,3),'Color',col,'LineWidth',8*(2-abs(frac))/2);
            axis tight
            ylabel('Delta'); xline(fixed_params.vdate(3))
            
            set(subplot(4,1,v+1),'Color',[0.96,0.91,0.56])
%             subplot(4,1,v+1)
%             ylabel("variant")
            
            drawnow
            
            % reset variables that were changed for plotting
            dbeta = og_dbeta;
            gamma_var = og_gamma_var;
            vdate = og_vdate;
        end
        
        if disp_opts.save_figs
            saveas(fig,"./png/beta_gamma_sensitivitymin" + string(v) + string() + ".png")
            saveas(fig,"./fig/beta_gamma_sensitivitymin" + string(v) + string(fixed_params.location) + ".fig")
            saveas(fig,"./eps/beta_gamma_sensitivitymin" + string(v) + string(fixed_params.location) + ".eps",'epsc')
        end
        end
        end
    end
end