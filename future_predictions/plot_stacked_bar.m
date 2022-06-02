function plot_stacked_bar(fixed_params, disp_opts, y, t, title_stored)
    arguments
        fixed_params
        disp_opts
        y
        t
        title_stored = ""
    end
    colors = fixed_params.colors;
    grayL = colors.grayL; gray = colors.gray; grayD = colors.grayD;
    brown = colors.brown; red = colors.red;
    orange = colors.orange; yellow = colors.yellow; white = colors.white;

    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    end_cases = min(end_day,length(US_data.date));

    yix = fixed_params.yix;
    nS = yix.nS; nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;
    nUV = yix.nUV; nV1 = yix.nV1; nV2 = yix.nV2; nVS1 = yix.nVS1; nVS2 = yix.nVS2;

    % convert t to datetime in same timeframe
    dt = datetime(datestr(datenum(US_data.date(start_day))+t));
    dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
    
    figure;
    barv=[sum(y(:,nV1,:),3), ... % First dose
        sum(y(:,nVS1,:),3), ... % First dose, waning
        sum(y(:,nV2,:),3), ... % Fully vaccinated
        sum(y(:,nVS2,:),3), ... % Fully vaccinated, waning
        y(:,nUV,nS), ... % Unvaccinated, susceptible
        sum(y(:,nUV,[nI,nR]),3), ... % Unvaccinated, recovered
        sum(y(:,nUV,nRW),3)]; % Unvaccinated, recovered, waning
    
    barv_daily = interp1(dt,barv,dt_daily);
    barf = bar(dt_daily,barv_daily,1,'stacked');
    barf(1).FaceColor = brown; barf(1).DisplayName = "First dose";
    barf(2).FaceColor = red; barf(2).DisplayName = "First dose, waning";
    barf(3).FaceColor = orange; barf(3).DisplayName = "Fully vaccinated";
    barf(4).FaceColor = yellow; barf(4).DisplayName = "Fully vaccinated, waning";
    barf(5).FaceColor = grayD; barf(5).DisplayName = "Unvaccinated";
    barf(6).FaceColor = gray; barf(6).DisplayName = "Unvaccinated, recovered";
    barf(7).FaceColor = grayL; barf(7).DisplayName = "Unvaccinated, recovered, waning";
    axis tight;
    legend('Location','southoutside','FontSize',18);

    if strjoin(string(title_stored)) ~= ""
        title(title_stored,'Interpreter','latex')
    end

    if disp_opts.save_figs
        saveas(gcf,...
            "./figures/png/stacked_bar/st_bar_" + ...
            string(datestr(now,'mmddTHHMMSS')) + ".png")
        saveas(gcf,...
            "./figures/fig/stacked_bar/st_bar_" + ...
            string(datestr(now,'mmddTHHMMSS')) + ".fig")
        saveas(gcf,...
            "./figures/eps/stacked_bar/st_bar_" + ...
            string(datestr(now,'mmddTHHMMSS')) + ".eps","epsc")
    end
end