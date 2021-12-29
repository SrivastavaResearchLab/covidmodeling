function disp_opts = generate_plots(param, fixed_params, disp_opts)
    % only calculate if there will be a plot
    if disp_opts.plot_cases || disp_opts.SVEIRD_plot || ...
            disp_opts.combined_beta || disp_opts.combined_d1 || ...
            disp_opts.combined_cases || disp_opts.combined_M || ...
            disp_opts.combined_alpha || disp_opts.variant_plot || ...
            disp_opts.check_variants || disp_opts.legend || ...
            disp_opts.combined_phi
        
        colors = fixed_params.colors;
        brown=colors.brown; red=colors.red; gray=colors.gray;
        gold=colors.gold; black=colors.black; blue=colors.blue;
        country_color = fixed_params.country_color;

        US_data = fixed_params.US_data; N = fixed_params.N;
        start_day = fixed_params.start_day; end_day = fixed_params.end_day;
        end_cases = min(end_day,length(US_data.date));
        
        loc_name = fixed_params.location;
        all_countries = disp_opts.all_countries;
        abbrev = disp_opts.abbrev;

        VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
        VE1V = fixed_params.VE1V; VE2V = fixed_params.VE2V;
        VES = fixed_params.VES; VESV = fixed_params.VESV;
        var_names = fixed_params.var_names;

        n_var = length(fixed_params.dbeta);

        % run simulation
        [t,y] = sim_SVIRD(param,fixed_params);
        
        % reshape compartment array into matrix
        y = reshape(y,[size(y,1),4,size(y,2)/4]);
        
        % recover compartments: y(immunity #, compartment #)
        nS = 1; nR = 2; nD = 3; nI = 4:(4+n_var);
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
        bv = b.*dbeta;
        new_casesv = S.*(bv.*Iv) + ...
            V1.*(b.*(1-VE1V).*dbeta.*Iv) + ...
            V2.*(b.*(1-VE2V).*dbeta.*Iv) + ...
            VS2.*(b.*(1-VESV).*dbeta.*Iv);
        new_cases = new_cases .* N;
        new_casesv = new_casesv .* N;
        [alpha1,alpha2] = calc_alpha(fixed_params,dt_daily);

        S = S.*N; V1 = V1.*N; V2 = V2.*N; R = R.*N; D = D.*N;
        I = I.*N; VR1 = VR1.*N; VR2 = VR2.*N; VS2 = VS2.*N; Iv = Iv.*N;
        VSR2 = VSR2.*N;
        
        M = calc_M(fixed_params,dt);
        M_daily = calc_M(fixed_params,dt_daily);

        new_cases_perday = interp1(dt,new_cases,dt_daily);

        disp(datetime(datestr(datenum(US_data.date(start_day))+[0 end_day-start_day])))
        fprintf(1,'%s:\nActual Cases: %g%%\nActual Deaths: %g\n',...
            loc_name,sum(100*new_cases_perday/N),...
            D(end))
    end
    
    if disp_opts.plot_cases || disp_opts.all_figs
        fig=figure; hold on
        set(gcf,'Position',[2 0.2 1500 590])
        title(loc_name,'fontsize',55)

        bar(US_data.date(start_day:end_cases),US_data.cases(start_day:end_cases).*M_daily,...
            'FaceColor',gray,'EdgeColor',gray,'DisplayName','Daily new cases')
        plot(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases).*M_daily,...
            '-.','Color',brown,'DisplayName','7-day average','LineWidth',8)
        plot(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases),...
            '-.','Color',gold,'DisplayName','7-day average','LineWidth',8)
        plot(dt,new_cases,'-','Color',red,'DisplayName','Model Prediction',...
            'LineWidth',8)
        ylabel("Actual Cases")
        
        yl = ylim; ylim([0 yl(2)]);
        xlim([US_data.date(start_day) US_data.date(end_cases)]);

        title(loc_name);
        if disp_opts.show_trans
            show_trans(US_data,start_day,param)
        end
        movegui('northwest')
        ytickformat('%.0f') % remove scientific notation
        ax = gca; ax.YAxis.Exponent = 0;
        
        if disp_opts.save_figs
            saveas(fig,"./png/cases_" + string(loc_name) + ".png")
            saveas(fig,"./fig/cases_" + string(loc_name) + ".fig")
            saveas(fig,"./eps/cases_" + string(loc_name) + ".eps",'epsc')
        end
        
    end

    if disp_opts.SVEIRD_plot || disp_opts.all_figs
        fig=figure;
        barv=[S,V1,V2,VS2,R+VR1+VR2+VSR2,D,I,Iv];
        barv_daily = interp1(dt,barv,dt_daily);
        barf = bar(dt_daily,barv_daily,1,'stacked');
        barf(1).FaceColor = brown; barf(1).DisplayName = "Susceptible";
        barf(2).FaceColor = gray; barf(2).DisplayName = "First dose";
        barf(3).FaceColor = gray/2; barf(3).DisplayName = "Fully Vaccinated";
        barf(4).FaceColor = blue; barf(4).DisplayName = "Vaccinated Susceptible";
        barf(5).FaceColor = gold; barf(5).DisplayName = "Recovered";
        barf(6).FaceColor = black; barf(6).DisplayName = "Deceased";
        barf(7).FaceColor = red; barf(7).DisplayName = "Infected";
        for i=1:n_var
            f = (n_var+1-i)/(n_var+1);
            barf(i+7).FaceColor = red*f;
            barf(i+7).DisplayName = "Infected (" + var_names(i) + ")";
        end
        axis tight; legend('location','EastOutside')
        title(loc_name)
        
        if disp_opts.save_figs
            saveas(fig,"./png/SVEIRD_" + string(loc_name) + ".png")
            saveas(fig,"./fig/SVEIRD_" + string(loc_name) + ".fig")
            saveas(fig,"./eps/SVEIRD_" + string(loc_name) + ".eps",'epsc')
        end
    end

    if disp_opts.combined_beta || disp_opts.all_figs
        figure(disp_opts.combined_beta_fig);
        plot(dt,b,'DisplayName',loc_name,'Color',country_color)
        axis tight;
        
        ylabel('Transmission Rate, $\beta$ (1/day)',...
            'interpreter','latex','FontSize',45)
        yl = ylim; ylim([0 yl(2)]);
        ax = gca; ax.YRuler.Exponent = 0;
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        
        if disp_opts.save_figs
            saveas(disp_opts.combined_beta_fig,"./png/combined_beta.png")
            saveas(disp_opts.combined_beta_fig,"./fig/combined_beta.fig")
            saveas(disp_opts.combined_beta_fig,"./eps/combined_beta.eps",'epsc')
        end
        
    end

    if disp_opts.combined_d1 || disp_opts.all_figs
        figure(disp_opts.combined_d1_fig);
        plot(dt,param_t.d1,'DisplayName',loc_name,'Color',country_color)
        axis tight;
        
        ylabel('Increasing level of caution, $d_I$',...
            'interpreter','latex','FontSize',45)
        yl = ylim; ylim([0 yl(2)]);
        ax = gca; ax.YRuler.Exponent = 0;
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        
        if disp_opts.save_figs
            saveas(disp_opts.combined_d1_fig,"./png/combined_dI.png")
            saveas(disp_opts.combined_d1_fig,"./fig/combined_dI.fig")
            saveas(disp_opts.combined_d1_fig,"./eps/combined_dI.eps",'epsc')
        end
        
    end

    if disp_opts.combined_cases || disp_opts.all_figs
        figure(disp_opts.combined_cases_fig);

        plot(dt,100*new_cases/N,'DisplayName',loc_name,...
            'LineWidth',8,'Color',country_color)
        
        axis tight
        yl = ylim; ylim([0 yl(2)]);
        xlim([US_data.date(start_day) US_data.date(end_day)]);
        
        ylabel('Daily New Cases (%)',...
            'interpreter','latex')
        ax = gca; ax.YRuler.Exponent = 0;
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ytickformat(ax, '%g');
        
        if disp_opts.save_figs
            saveas(disp_opts.combined_cases_fig,"./png/combined_cases.png")
            saveas(disp_opts.combined_cases_fig,"./fig/combined_cases.fig")
            saveas(disp_opts.combined_cases_fig,"./eps/combined_cases.eps",'epsc')
        end
        
    end

    if disp_opts.combined_M || disp_opts.all_figs
        figure(disp_opts.combined_M_fig);

        plot(dt,M,'DisplayName',loc_name,...
            'LineWidth',8,'Color',country_color)
        
        set(gca,'yscale','log')
        
        axis tight
        yl = ylim; ylim([0 yl(2)]);
        xlim([US_data.date(start_day) US_data.date(end_day)]);
        
        ylabel("Actual/Reported Cases, M")
        ax = gca; ax.YRuler.Exponent = 0;
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        
        if disp_opts.save_figs
            saveas(disp_opts.combined_M_fig,"./png/combined_M.png")
            saveas(disp_opts.combined_M_fig,"./fig/combined_M.fig")
            saveas(disp_opts.combined_M_fig,"./eps/combined_M.eps",'epsc')
        end
        
    end

    if disp_opts.combined_alpha || disp_opts.all_figs
        figure(disp_opts.combined_alpha_fig);
        subplot(2,1,1); hold on;
        plot(dt_daily,100*alpha1,'DisplayName',loc_name,'Color',country_color)
        axis tight;
        
        ylabel('$\alpha_1$ (1/day)',...
            'interpreter','latex','FontSize',45)
%         yl = ylim; ylim([0 yl(2)]);
        ylim([0 1.5]);
        
        xl = xlim; xlim([datetime('December 1, 2020') xl(2)]);
        ax = gca; ax.YRuler.Exponent = 0; ytickformat('percentage');
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        
        
        subplot(2,1,2); hold on
        plot(dt_daily,100*alpha2,'DisplayName',loc_name,'Color',country_color)
        axis tight;
        
        ylabel('$\alpha_2$ (1/day)',...
            'interpreter','latex','FontSize',45)
%         yl = ylim; ylim([0 yl(2)]);
        ylim([0 1.5]);
        xl = xlim; xlim([datetime('December 1, 2020') xl(2)]);
        ax = gca; ax.YRuler.Exponent = 0; ytickformat('percentage');
        ax.LineStyleOrderIndex = ax.ColorOrderIndex;
        ax.FontSize = 45;
        
        
        if disp_opts.save_figs
            saveas(disp_opts.combined_alpha_fig,"./png/combined_alpha.png")
            saveas(disp_opts.combined_alpha_fig,"./fig/combined_alpha.fig")
            saveas(disp_opts.combined_alpha_fig,"./eps/combined_alpha.eps",'epsc')
        end
    end

    if disp_opts.variant_plot || disp_opts.all_figs
        start_var = find(Iv(:,1),1,'first');
        
        fig4=figure; hold on;
        Ipl = I(start_var:end); Ivpl = Iv(start_var:end,:);
        barv=[Ipl,Ivpl]./sum([Ipl,Ivpl],2).*max([Ipl Ivpl],[],'all');
        barv_daily = interp1(dt(start_var:end),barv,dt_daily);
        barf = bar(dt_daily,barv_daily,'stacked','BarWidth',1);
        barf(1).FaceColor = gray; barf(1).HandleVisibility = 'off';
        plot(dt(start_var:end),Ipl,':','Color',red,'DisplayName','Infected','LineWidth',8)
        
        for i=1:n_var
            f = (n_var+1-i)/(n_var+1);
            barf(i+1).FaceColor = gray*f;
            barf(i+1).DisplayName = 'Infected ('+var_names(i)+')';
%             barf(i+1).HandleVisibility = 'off';
            plot(dt(start_var:end),Iv(start_var:end,i),'--','Color',red*f,'DisplayName','Infected ('+var_names(i)+')','LineWidth',8)
        end
        
        axis tight; ;
        xlim([dt(start_var) dt(end)])
        legend('location','EastOutside')
        title(loc_name)
        
        if disp_opts.save_figs
            saveas(fig4,"./png/variant2_" + string(loc_name) + ".png")
            saveas(fig4,"./fig/variant2_" + string(loc_name) + ".fig")
            saveas(fig4,"./eps/variant2_" + string(loc_name) + ".eps",'epsc')
        end
    end

    if disp_opts.check_variants || disp_opts.all_figs
        variant_data = fixed_params.variant_data;
        t_weekly = variant_data.t;
        
        fig_v=figure; hold on
        set(gcf,'Position',[0 0, 1050, 800]) % resize figure to label Jan,Apr,Jul,Oct
        
        newcases_weekly = interp1(US_data.date(start_day:end_cases), ...
            US_data.average(start_day:end_cases).*M_daily,t_weekly);
        new_casesog = new_cases - sum(new_casesv,2);
        
        og_prop = 1;
        for name=var_names
            og_prop = og_prop - variant_data.(name);
        end
        
        og_prop_daily = interp1(t_weekly,og_prop,dt_daily);
        
        sgtitle(loc_name,'FontSize',32)
        
        subplot(1+n_var,1,1); hold on
        bar(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases).*M_daily.*og_prop_daily,...
            'FaceColor',([86 92 97]/255 + 2)/3,'EdgeColor','none')
        plot(dt,new_casesog,':','Color',[86 92 97]/255,'LineWidth',8)
        axis tight; set(gca,'XTickLabel',[])
        ax=gca; ax.YRuler.Exponent = 0; % remove scientific notation
        yyaxis right; ylabel('WT','color',[0 0 0]) % label variants on right of plot (black text)
        set(gca,'YTickLabel',[])
        
        variant_colors = [200 16 46 ; 134 38 51 ; 0 58 112 ; 50 240 100] ./ 255;
        
        for var_i = 1:n_var
            subplot(1+n_var,1,1+var_i); hold on
            bar(t_weekly,variant_data.(var_names(var_i)).*newcases_weekly,1,'FaceColor',(variant_colors(var_i,:) + 2)/3,'EdgeColor','none')
            plot(dt,new_casesv(:,var_i),':','Color',variant_colors(var_i,:),'LineWidth',8)
            axis tight; xl = xlim; xlim([min(dt),xl(2)]); 
            ax=gca; ax.YRuler.Exponent = 0; % remove scientific notation
            yyaxis right; ylabel(var_names(var_i),'color',[0 0 0]) % label variants on right of plot (black text)
            set(gca,'YTickLabel',[])
            
            xline(fixed_params.vdate(var_i))
            xTick = get(gca,'XTickLabel'); set(gca,'XTickLabel',[])
        end
        set(gca,'XTickLabel',xTick) % label only bottom subplot's xaxis

        if disp_opts.save_figs
            saveas(fig_v,"./png/checkvariants_" + string(loc_name) + ".png")
            saveas(fig_v,"./fig/checkvariants_" + string(loc_name) + ".fig")
            saveas(fig_v,"./eps/checkvariants_" + string(loc_name) + ".eps",'epsc')
        end
    end
    
    if disp_opts.combined_phi || disp_opts.all_figs
        figure(disp_opts.combined_phi_fig);
        
        VE = [zeros(size(fixed_params.VE1V)) ; fixed_params.VE1V ; fixed_params.VE2V ; fixed_params.VESV];
        phi = (1-VE) .* repmat(fixed_params.dbeta,4,1);
        
        N_countries = length(all_countries);
        subplot(ceil(N_countries/3),min(3,N_countries),find(all_countries==abbrev,1))
        
        imshow(phi/max(phi,[],'all'),'initialmagnification','fit','colormap',parula)
        
        for i=1:size(phi,1)
            for j=1:size(phi,2)
                text(j,i,sprintf('%.3f',phi(i,j)),'fontsize',12)
            end
        end
        
        title(loc_name)
        
        if disp_opts.save_figs
            saveas(gcf,"./png/phi_" + string(loc_name) + ".png")
            saveas(gcf,"./fig/phi_" + string(loc_name) + ".fig")
            saveas(gcf,"./eps/phi_" + string(loc_name) + ".eps",'epsc')
        end
    end
    
    if disp_opts.combined_phi3d || disp_opts.all_figs
        figure(disp_opts.combined_phi3d_fig);
        
        VE = [zeros(size(fixed_params.VE1V)) ; fixed_params.VE1V ; fixed_params.VE2V ; fixed_params.VESV];
        phi = (1-VE) .* repmat(fixed_params.dbeta,4,1);
        
        N_countries = length(all_countries);
        subplot(ceil(N_countries/3),min(3,N_countries),find(all_countries==abbrev,1))
        
        bar3(phi,1)
        
%         for i=1:size(phi,1)
%             for j=1:size(phi,2)
%                 text(i-.25,j-.25,phi(i,j)+.2,sprintf('%.3f',phi(i,j)),'fontsize',30)
%             end
%         end
        
        title(loc_name)
        
        if disp_opts.save_figs
            saveas(gcf,"./png/phi3d_" + string(loc_name) + ".png")
            saveas(gcf,"./fig/phi3d_" + string(loc_name) + ".fig")
            saveas(gcf,"./eps/phi3d_" + string(loc_name) + ".eps",'epsc')
        end
    end

    if disp_opts.legend || disp_opts.all_figs
        figure(disp_opts.legend_fig); hold on
        plot(dt,param_t.d1,'DisplayName',loc_name,'Color',country_color);
        ax = gca; ax.LineStyleOrderIndex = ax.ColorOrderIndex;
    end
    
    if (disp_opts.combined_beta || disp_opts.combined_d1) && ...
            ax.LineStyleOrderIndex == 5
        set(groot,'defaultLineLineWidth',5)
    end
end