function fixed_params = create_error_figure(fixed_params)
    colors = fixed_params.colors;
    US_data = fixed_params.US_data; start_day = fixed_params.start_day; 
    end_day = fixed_params.end_day;
    red = colors.red; gray = colors.gray; 
    gold = colors.gold;
    end_cases = min(end_day,length(US_data.date));
    
    n_vars = length(fixed_params.dbeta);
    var_names = fixed_params.var_names;

    fid=figure; fixed_params.errorfig = fid; hold on
    
    set(0, 'CurrentFigure', fixed_params.errorfig);
    
    if fixed_params.calc_variants
        variant_data = fixed_params.variant_data;

        dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
        t_daily = datenum(dt_daily - US_data.date(1))+1;
        t_daily = index2date(US_data,start_day,t_daily);
        M_daily = calc_M(fixed_params,t_daily)';
        
        og_prop = 1;
        for name=var_names
            og_prop = og_prop - variant_data.(name);
        end
        og_prop_daily = interp1(variant_data.t,og_prop,dt_daily);
        newcases_weekly = interp1(US_data.date(start_day:end_cases), ...
            US_data.average(start_day:end_cases).*M_daily,variant_data.t);

        subplot(n_vars+1,1,1); hold on
        bar(US_data.date(start_day:end_cases),US_data.average(start_day:end_cases).*M_daily.*og_prop_daily,...
            1,'FaceColor',([86 92 97]/255 + 2)/3,'EdgeColor','none')
        axis tight; xl = xlim;
        set(gca,'XTickLabel',[])
        ax=gca; ax.YRuler.Exponent = 0; % remove scientific notation
        yyaxis right; ylabel('original','color',[0 0 0]) % label variants on right of plot (black text)
        set(gca,'YTickLabel',[])

        variant_colors = [200 16 46 ; 134 38 51 ; 0 58 112 ; 50 240 100] ./ 255;
        for var_i = 1:n_vars
            subplot(n_vars+1,1,var_i+1); hold on
            bar(variant_data.t,variant_data.(var_names(var_i)).*newcases_weekly, ...
                1,'FaceColor',(variant_colors(var_i,:) + 2)/3,'EdgeColor','none')
            axis tight; xlim(xl);
            
            ax=gca; ax.YRuler.Exponent = 0; % remove scientific notation
            yyaxis right; ylabel(var_names(var_i),'color',[0 0 0]) % label variants on right of plot (black text)
            set(gca,'YTickLabel',[])
            
            xline(fixed_params.vdate(var_i))
            xTick = get(gca,'XTickLabel'); set(gca,'XTickLabel',[])
        end
        set(gca,'XTickLabel',xTick) % label only bottom subplot's xaxis
        set(gcf,'Position',[0 0, 1050, 800]) % resize figure to label Jan,Apr,Jul,Oct
    else
        yyaxis right
        plot(US_data.date(start_day:end_cases),M,'Color',gold,'LineWidth',1)
        
        yyaxis left
        bar(US_data.date(start_day:end_cases),M.*US_data.cases(start_day:end_cases),...
            'FaceColor',gray,'EdgeColor',gray)
        plot(US_data.date(start_day:end_cases),M.*US_data.average(start_day:end_cases),...
            '-','Color',red)
        
        title(fixed_params.location);
        axis tight
    end
end