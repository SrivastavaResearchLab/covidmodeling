function disp_opts = generate_plots_predictions(param, fixed_params, disp_opts)
    if disp_opts.sens_alpha_paired || disp_opts.all_figs
        end_offset = 3;
        start_offset = -596-51;

%         alpha1_proportion = [0.5];
%         alpha2_proportion = [0.5];
%         alphaB_proportion = [0];

        alpha1_proportion = [0.2];
        alpha2_proportion = [0.2];
        alphaB_proportion = [0.6];
        
%         alpha1_proportion = [0.3 0.5 0.7];
%         alpha2_proportion = [0.7 0.5 0.3];
%         alphaB_proportion = [0.0,0.0,0.0];

%         alpha1_proportion = [0.3 0.5 0.7];
%         alpha2_proportion = [0.7 0.5 0.3];
%         alphaB_proportion = [0.1,0.2,0.3];
%         
%         alpha1_proportion = [0.25 0.5 0.7];
%         alpha2_proportion = [0.65 0.5 0.3];
%         alphaB_proportion = [0.1,0.2,0.3];
        
        US_data = fixed_params.US_data;
        
        end_day = length(US_data.date) + end_offset;
        fixed_params.end_day = end_day;
        
        for i = 1:length(alpha1_proportion)
            fprintf("Iter: %i of %i\n",i,length(alpha1_proportion))
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
            
            if i==1
                fprintf("Plotting 7-day average\n")
                plot_data_avg(fixed_params2)
            end
            
            fprintf("Plotting sensitivity graph: %i of %i\n",...
                i,length(alpha1_proportion))
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
end