function surface_plot_predictions(param,fixed_params,disp_opts,plotting_axis,...
    alpha1_vals, alpha2_vals, alphaB_vals, unvacc_prop, st_bar_idxs)
    arguments
        param
        fixed_params
        disp_opts
        plotting_axis
        alpha1_vals
        alpha2_vals
        alphaB_vals
        unvacc_prop = []
        st_bar_idxs = []
    end

    colors = fixed_params.colors;
    grayL = colors.grayL; gray = colors.gray; grayD = colors.grayD;
    brown = colors.brown; red = colors.red;
    orange = colors.orange; yellow = colors.yellow; white = colors.white;
    
    US_data = fixed_params.US_data; N = fixed_params.N;
    start_day = fixed_params.start_day; end_day = fixed_params.end_day;
    end_cases = min(end_day,length(US_data.date));
    
    sens_plot_specs = fixed_params.sens_plot_specs;
    end_offset = sens_plot_specs.end_offset;
    start_offset = sens_plot_specs.start_offset;
    
    end_day = length(US_data.date) + end_offset;
    fixed_params.end_day = end_day;
    
    if ~(length(alpha1_vals) == length(alpha2_vals) && ...
            length(alpha2_vals) == length(alphaB_vals))
        error('Alpha vector sizes are not compatible')
    end
    num_pts = length(alpha1_vals);

    new_cases_arr = zeros(num_pts, end_day - start_day + 1);
    for i = 1:num_pts
        fprintf("Iter: %i of %i\n",i,num_pts)

        param2 = param;
        fixed_params2 = fixed_params;
        fixed_params2.sens_plot_specs.end_offset = end_offset;
        fixed_params2.sens_plot_specs.start_offset = start_offset;
        fixed_params2.sens_vars.frac_alpha1 = alpha1_vals(i);
        fixed_params2.sens_vars.frac_alpha2 = alpha2_vals(i);
        fixed_params2.sens_vars.frac_alphaB = alphaB_vals(i);

        if ~isempty(unvacc_prop)
            fixed_params2.unvacc_rate = unvacc_prop(i);
        end

        [t,y] = sim_SVIRD(param2,fixed_params2);
                
        % convert t to datetime in same timeframe
        % reshape compartment array into matrix (5 stacks: nUV,nV1,nV2,nVS1,nVS2)
        y = reshape(y,[size(y,1),5,size(y,2)/5]);

        if ~isempty(st_bar_idxs) && disp_opts.stacked_bar
            if any(ismember(st_bar_idxs,i))
                title = ...
                    {"Dose 1: " + num2str(alpha1_vals(i)*100) + ...
                    "\%, " + "Dose 2: " + num2str(alpha2_vals(i)*100) + ...
                    "\%,", "Booster: " + num2str(alphaB_vals(i)*100) + ...
                    "\% --- Unvacc rate: " + ...
                    num2str(fixed_params.unvacc_rate * 100) + "\%"};
                plot_stacked_bar(fixed_params, disp_opts, y, t, title)
            end
        end
    
        % create variables for indexing compartment array
        yix = fixed_params.yix;
        nS = yix.nS; nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;
        nUV = yix.nUV; nV1 = yix.nV1; nV2 = yix.nV2; nVS1 = yix.nVS1; nVS2 = yix.nVS2;
        
        [inflow,~] = calc_flows(t,y,param,fixed_params);
        new_cases = squeeze(sum(inflow(:,:,nI),[2 3]));
        new_cases = 100 * new_cases;

        t_daily = linspace(t(1),t(end),t(end)+1);
        new_cases = interp1(t,new_cases,t_daily);

        % convert t to datetime in same timeframe
        if i == 1
            dt = datetime(datestr(datenum(US_data.date(start_day))+t_daily));
        end

        new_cases_arr(i,:) = new_cases;
    end

    x_gridlines = 40;
    y_gridlines = 40;
    switch plotting_axis
        case 'alpha1_alpha2_vary'
            figure(disp_opts.surface_alpha1_alpha2_fig);
            set(gcf,"Position",[2 0.2 1000 754])

            alpha1_alpha2_plotting = alpha1_vals / (alpha1_vals(1) + alpha2_vals(1));
            [time_axis, alpha1_alpha2_axis] = meshgrid(dt, alpha1_alpha2_plotting);
%             time_axis_nums = datenum(time_axis) - datenum(time_axis(1,1));
            
            s_handle = surf(time_axis, alpha1_alpha2_axis, new_cases_arr, ...
                'EdgeColor', 'none');
            
            plot_gridlines(s_handle, x_gridlines, y_gridlines)

            zlabel("New Cases/Day (% Population)")
            ax = gca; ax.ZRuler.Exponent = 0; ax.FontSize = 30;
            ztickformat("percentage")
            
            ylabel('First Dose Fraction')

            xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);
            
            cam_position = 1.0e+03 * [-3.1288 -0.0012 0.0055];
            campos(cam_position);
        case 'alphaB_vary'
            figure(disp_opts.surface_alphaB_fig);
            set(gcf,"Position",[2 0.2 1000 754])

            [time_axis, alphaB_axis] = meshgrid(dt, alphaB_vals);

            s_handle = surf(time_axis, alphaB_axis, new_cases_arr, ...
                'EdgeColor', 'none');

            plot_gridlines(s_handle, x_gridlines, y_gridlines)
            
            zlabel("New Cases/Day (% Population)")
            ax = gca; ax.ZRuler.Exponent = 0; ax.FontSize = 30;
            ztickformat("percentage")
            
            ylabel('Booster Dose Proportion')

            xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);

            cam_position = 1.0e+03 * [-3.1288 -0.0012 0.0055];
            campos(cam_position);
        case 'unvacc_vary'
            figure(disp_opts.unvacc_vary_fig);
            set(gcf,"Position",[2 0.2 1000 754])

            [time_axis, unvacc_axis] = meshgrid(dt, unvacc_prop);
%             time_axis_nums = datenum(time_axis) - datenum(time_axis(1,1));
            
            s_handle = surf(time_axis, unvacc_axis, new_cases_arr,...
                'EdgeColor', 'none');

            plot_gridlines(s_handle, x_gridlines, y_gridlines)

            zlabel("New Cases/Day (% Population)")
            ax = gca; ax.ZRuler.Exponent = 0; ax.FontSize = 30;
            ztickformat("percentage")
            
            ylabel('Proportion Unvaccinated Population')

            xlim([US_data.date(end_cases) + start_offset US_data.date(end_cases)+end_offset]);
            
            cam_position = 1.0e+03 * [-3.1288 -0.0012 0.0055];
            campos(cam_position);
        otherwise
            error('Not a recognized plotting axis')
    end
end