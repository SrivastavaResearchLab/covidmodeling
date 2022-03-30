function disp_opts = create_figures(disp_opts)
    % open selected figures in disp_opts
    if disp_opts.combined_beta || disp_opts.all_figs
        disp_opts.combined_beta_fig = figure; hold on
    end
    
    if disp_opts.combined_d1 || disp_opts.all_figs
        disp_opts.combined_d1_fig = figure; hold on
        annotation(gcf,'arrow',[0.065 0.065],...
            [0.059228650137741 0.199335332677062],'LineWidth',8,'HeadSize',30);
    end
    
    if disp_opts.combined_cases || disp_opts.all_figs
        disp_opts.combined_cases_fig = figure; hold on
    end
    
    if disp_opts.combined_M || disp_opts.all_figs
        fig = figure; hold on
        fig.Position(3) = 1.5*fig.Position(3);
        disp_opts.combined_M_fig = fig;
    end
    
    if disp_opts.combined_phi || disp_opts.all_figs
        disp_opts.combined_phi_fig = figure; hold on
    end
    
    if disp_opts.combined_phi3d || disp_opts.all_figs
        disp_opts.combined_phi3d_fig = figure; hold on
    end
    
    if disp_opts.legend || disp_opts.all_figs
        disp_opts.legend_fig = figure;
        disp_opts.legend_handle = legend('orientation','vertical','box','off');
    end

    if disp_opts.stacks_legend || disp_opts.all_figs
        disp_opts.stackslegend_fig = figure;
        disp_opts.stackslegend_handle = legend('orientation','vertical','box',1,'edgecolor',[1 1 1]);
    end
    
    if disp_opts.combined_alpha || disp_opts.all_figs
        disp_opts.combined_alpha_fig = figure; hold on
    end
end