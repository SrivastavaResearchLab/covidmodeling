function disp_opts = generate_plots_predictions(param, fixed_params, disp_opts)
    if disp_opts.sens_alpha_paired || disp_opts.all_figs
        end_offset = 3;
        start_offset = -596-51;

        alpha1_proportion = [0.25 0.30 0.50];
        alpha2_proportion = [0.15 0.10 0.30];
        alphaB_proportion = [0.60 0.60 0.20];
        unvacc_proportion = [0.00 0.00 0.00];

%         alpha1_proportion = [0.5 0.6 0.7];
%         alpha2_proportion = [0.3 0.2 0.1];
%         alphaB_proportion = [0.2 0.2 0.2];
        
%         alpha1_proportion = [0.70 0.65 0.64 0.63 0.62 0.61 0.60 ];
%         alpha2_proportion = [0.20 0.35 0.36 0.37 0.38 0.39 0.40 ];
%         alphaB_proportion = [0.10 0.10 0.10 0.10 0.10 0.10 0.10 ];

%         alpha1_proportion = [0.3 0.5 0.7];
%         alpha2_proportion = [0.7 0.5 0.3];
%         alphaB_proportion = [0.1,0.2,0.3];
       
%         alpha1_proportion = [0.25 0.5 0.7];
%         alpha2_proportion = [0.65 0.5 0.3];
%         alphaB_proportion = [0.1,0.2,0.3];
        
        US_data = fixed_params.US_data;
        
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
            
            fixed_params2.sens_vars.frac_alpha1 = alpha1_proportion(i);
            fixed_params2.sens_vars.frac_alpha2 = alpha2_proportion(i);
            fixed_params2.sens_vars.frac_alphaB = alphaB_proportion(i);
            fixed_params2.unvacc_rate = unvacc_proportion(i);
            
            if i==1
                fprintf("Plotting 7-day average\n")
                plot_data_avg(fixed_params2)
            end
            
            fprintf("Plotting sensitivity graph: %i of %i\n",...
                i,length(alpha1_proportion))
            disp_name = ...
                "Dose 1: " + num2str(alpha1_proportion(i)*100) + ...
                "\%, " + "Dose 2: " + num2str(alpha2_proportion(i)*100) + ...
                "\%, " + "Booster: " + num2str(alphaB_proportion(i)*100) + "\%";
            plot_basic(param2, fixed_params2, disp_opts, ...
                disp_name);
        end
        
        if disp_opts.save_figs
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/png/sens_alpha_paired_" + ...
                string(fixed_params2.location) + ".png")
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/fig/sens_alpha_paired_" + ...
                string(fixed_params2.location) + ".fig")
            saveas(disp_opts.sens_alpha_paired_fig,...
                "./figures/eps/sens_alpha_paired_" + ...
                string(fixed_params2.location) + ".eps","epsc")
        end
        hold off
    end

    if disp_opts.surface_alpha1_alpha2 || disp_opts.all_figs
        % -----------------------------------------------------
        num_subdiv = 30;
%         alpha1_proportion = linspace(0.7, 0.5, num_subdiv);
%         alpha2_proportion = linspace(0.2, 0.4, num_subdiv);
%         alphaB_proportion =   repmat(0.1,   1, num_subdiv);
        alpha1_proportion = linspace(0.25, 0.35, num_subdiv);
        alpha2_proportion = linspace(0.15, 0.05, num_subdiv);
        alphaB_proportion =   repmat(0.60,    1, num_subdiv);
        % -----------------------------------------------------

        end_offset = 3;
        start_offset = -596-51;
        
        US_data = fixed_params.US_data;
        
        end_day = length(US_data.date) + end_offset;
        fixed_params.end_day = end_day;
        
        
        figure(disp_opts.surface_alpha1_alpha2_fig);
        param2 = param;
        fixed_params2 = fixed_params;
        
        fixed_params2.sens_plot_specs.end_offset = end_offset;
        fixed_params2.sens_plot_specs.start_offset = start_offset;
        
        hold on
        set(gcf,"Position",[2 0.2 1000 754]) % set(gcf,"Position",[2 0.2 1300 754])
        
        plotting_axis = 'alpha1_alpha2_vary';
%         plotting_axis = 'alphaB_vary';
        st_bar_idxs = [15];
        surface_plot_predictions(param2, fixed_params2, disp_opts,...
            plotting_axis, alpha1_proportion, alpha2_proportion, ...
            alphaB_proportion, [], st_bar_idxs)
        

        if disp_opts.save_figs
            saveas(disp_opts.surface_alpha1_alpha2,...
                "./figures/png/alpha1_alpha2_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".png")
            saveas(disp_opts.surface_alpha1_alpha2,...
                "./figures/fig/alpha1_alpha2_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".fig")
            saveas(disp_opts.surface_alpha1_alpha2,...
                "./figures/eps/alpha1_alpha2_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".eps","epsc")
        end
        hold off
    end

    if disp_opts.surface_alphaB || disp_opts.all_figs
        % -----------------------------------------------------
        num_subdiv = 30;
        alpha1_proportion = linspace(0.55, 0.25, num_subdiv);
        alpha2_proportion = linspace(0.45, 0.15, num_subdiv);
        alphaB_proportion = linspace(0.0, 0.60, num_subdiv);
        % -----------------------------------------------------
        
        end_offset = 3;
        start_offset = -596-51;
        
        US_data = fixed_params.US_data;
        
        end_day = length(US_data.date) + end_offset;
        fixed_params.end_day = end_day;
        
        figure(disp_opts.surface_alphaB_fig);
        param2 = param;
        fixed_params2 = fixed_params;
        
        fixed_params2.sens_plot_specs.end_offset = end_offset;
        fixed_params2.sens_plot_specs.start_offset = start_offset;
        
        hold on
        set(gcf,"Position",[2 0.2 1000 754]) % set(gcf,"Position",[2 0.2 1300 754])
        
        plotting_axis = 'alphaB_vary';

        surface_plot_predictions(param2, fixed_params2, disp_opts,...
            plotting_axis, alpha1_proportion, alpha2_proportion, ...
            alphaB_proportion)
        

        if disp_opts.save_figs
            saveas(disp_opts.surface_alphaB_fig,...
                "./figures/png/alphaB_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".png")
            saveas(disp_opts.surface_alphaB_fig,...
                "./figures/fig/alphaB_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".fig")
            saveas(disp_opts.surface_alphaB_fig,...
                "./figures/eps/alphaB_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".eps","epsc")
        end
        hold off
    end

    if disp_opts.unvacc_vary || disp_opts.all_figs
        % -----------------------------------------------------
        num_subdiv = 12;
        alpha1_proportion = repmat(0.25, 1, num_subdiv);
        alpha2_proportion = repmat(0.15, 1, num_subdiv);
        alphaB_proportion = repmat(0.6, 1, num_subdiv);
        unvacc_prop = linspace(0, 0.4, num_subdiv);
        % -----------------------------------------------------
        
        end_offset = 3;
        start_offset = -596-51;
        
        US_data = fixed_params.US_data;
        
        end_day = length(US_data.date) + end_offset;
        fixed_params.end_day = end_day;
        
        figure(disp_opts.unvacc_vary_fig);
        param2 = param;
        fixed_params2 = fixed_params;
        
        fixed_params2.sens_plot_specs.end_offset = end_offset;
        fixed_params2.sens_plot_specs.start_offset = start_offset;
        
        hold on
        set(gcf,"Position",[2 0.2 1000 754]) % set(gcf,"Position",[2 0.2 1300 754])
        
        plotting_axis = 'unvacc_vary';

        surface_plot_predictions(param2, fixed_params2, disp_opts,...
            plotting_axis, alpha1_proportion, alpha2_proportion, ...
            alphaB_proportion, unvacc_prop)
        
        if disp_opts.save_figs
            saveas(disp_opts.unvacc_vary_fig,...
                "./figures/png/unvacc_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".png")
            saveas(disp_opts.unvacc_vary_fig,...
                "./figures/fig/unvacc_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".fig")
            saveas(disp_opts.unvacc_vary_fig,...
                "./figures/eps/unvacc_vary_" + ...
                string(datestr(now,'mmddTHHMMSS')) + ".eps","epsc")
        end
        hold off
    end
end