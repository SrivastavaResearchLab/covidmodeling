function plot_legend(disp_opts,fixed_params)
    figure(disp_opts.legend_fig);
    
    n_var = length(fixed_params.dbeta); var_names = fixed_params.var_names;
    N = fixed_params.N;
    
    cmap = readmatrix('./colormap/cmap.csv');
    [r_cmap,~] = size(cmap); 
    
    barf = bar(1:r_cmap-1,ones(r_cmap,7+n_var),1,'stacked');    
    barf(1).FaceColor = cmap(1,:); barf(1).DisplayName = "Susceptible";
    barf(2).FaceColor = cmap(2,:); barf(2).DisplayName = "First dose";
    barf(3).FaceColor = cmap(3,:); barf(3).DisplayName = "Second dose";
    barf(4).FaceColor = cmap(4,:); barf(4).DisplayName = "Second dose suceptible";
    barf(5).FaceColor = cmap(5,:); barf(5).DisplayName = "Recovered";
    barf(6).FaceColor = cmap(6,:); barf(6).DisplayName = "Dead";
    barf(7).FaceColor = cmap(7,:); barf(7).DisplayName = "Infected";
    for k=1:n_var
        barf(k+7).FaceColor = cmap(7+k,:);
        barf(k+7).DisplayName = "Infected (" + var_names(k) + ")";
    end

    lgd = legend;
    allLineHandles = findall(disp_opts.legend_fig, 'type', 'line');
    
    set(gca,'position',[200 200 100 100])
    
    warning('off')
    for i = 1:length(allLineHandles)
        allLineHandles(i).XData = NaN;
    end
    
    axis off
    
    lgd.Units = 'pixels';
    boxLineWidth = lgd.LineWidth;
    
    lgd.Position = [75, 1, ...
        lgd.Position(3), lgd.Position(4)];
    legLocPixels = lgd.Position;
    
    disp_opts.legend_fig.Units = 'pixels';
    disp_opts.legend_fig.InnerPosition = [1, 1, legLocPixels(3) + 150, ...
        legLocPixels(4) + 12 * boxLineWidth];
end