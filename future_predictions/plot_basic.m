function plot_basic(param,fixed_params,disp_opts,dispName)

    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    end_cases = min(end_day,length(US_data.date));
    
    sens_plot_specs = fixed_params.sens_plot_specs;
    end_offset = sens_plot_specs.end_offset;
    start_offset = sens_plot_specs.start_offset;
    
    end_day = length(US_data.date) + end_offset;
    fixed_params.end_day = end_day;
    
    % run simulation
    [t,y] = sim_SVIRD(param,fixed_params);
    
    % convert t to datetime in same timeframe
    % reshape compartment array into matrix (5 stacks: nUV,nV1,nV2,nVS1,nVS2)
    y = reshape(y,[size(y,1),5,size(y,2)/5]);

    % create variables for indexing compartment array
    yix = fixed_params.yix;
    nS = yix.nS; nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;
    nUV = yix.nUV; nV1 = yix.nV1; nV2 = yix.nV2; nVS1 = yix.nVS1; nVS2 = yix.nVS2;

    % convert t to datetime in same timeframe
    dt = datetime(datestr(datenum(US_data.date(start_day))+t));
    dt_daily = US_data.date(start_day)+(0:(end_day-start_day));
    
    [inflow,~] = calc_flows(t,y,param,fixed_params);
    new_cases = squeeze(sum(inflow(:,:,nI),[2 3]));
    new_cases = new_cases .* N;
    
    plot(dt,100*new_cases./N,'DisplayName',dispName,...
        'LineWidth',5)
    
    ylabel("New Cases/Day (% Population)")
    ax = gca; ax.YRuler.Exponent = 0; ax.FontSize = 30;
    ytickformat("percentage")
    xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);

    xline(datetime(fixed_params.vacc_start_date),...
        'HandleVisibility','off','LineWidth',3,...
        'Color',[0 0.4470 0.7410])
    xline(datetime(fixed_params.boost_start_date),...
        'HandleVisibility','off','LineWidth',3,...
        'Color',[0.4660 0.6740 0.1880])

    if disp_opts.stacked_bar
        plot_stacked_bar(fixed_params, disp_opts, y, t)
%         figure;
%         barv=[sum(y(:,nV1,:),3), ... % First dose
%             sum(y(:,nVS1,:),3), ... % First dose, waning
%             sum(y(:,nV2,:),3), ... % Fully vaccinated
%             sum(y(:,nVS2,:),3), ... % Fully vaccinated, waning
%             y(:,nUV,nS), ... % Unvaccinated, susceptible
%             sum(y(:,nUV,[nI,nR]),3), ... % Unvaccinated, recovered
%             sum(y(:,nUV,nRW),3)]; % Unvaccinated, recovered, waning
% 
%         barv_daily = interp1(dt,barv,dt_daily);
%         barf = bar(dt_daily,barv_daily,1,'stacked');
%         barf(1).FaceColor = brown; barf(1).DisplayName = "First dose";
%         barf(2).FaceColor = red; barf(2).DisplayName = "First dose, waning";
%         barf(3).FaceColor = orange; barf(3).DisplayName = "Fully vaccinated";
%         barf(4).FaceColor = yellow; barf(4).DisplayName = "Fully vaccinated, waning";
%         barf(5).FaceColor = grayD; barf(5).DisplayName = "Unvaccinated";
%         barf(6).FaceColor = gray; barf(6).DisplayName = "Unvaccinated, recovered";
%         barf(7).FaceColor = grayL; barf(7).DisplayName = "Unvaccinated, recovered, waning";
%         axis tight;
%         legend('Location','eastoutside');
    end
end