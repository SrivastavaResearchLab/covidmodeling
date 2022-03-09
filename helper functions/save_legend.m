function save_legend(disp_opts)
if disp_opts.legend || disp_opts.all_figs
    allLineHandles = findall(disp_opts.legend_fig, 'type', 'line');
    
    warning('off')
    for i = 1:length(allLineHandles)
        allLineHandles(i).XData = NaN;
    end
    
    axis off
    
    disp_opts.legend_handle.Units = 'pixels';
    boxLineWidth = disp_opts.legend_handle.LineWidth;
    
    disp_opts.legend_handle.Position = [75, 1, ...
        disp_opts.legend_handle.Position(3), disp_opts.legend_handle.Position(4)];
    legLocPixels = disp_opts.legend_handle.Position;
    
    disp_opts.legend_fig.Units = 'pixels';
    disp_opts.legend_fig.InnerPosition = [1, 1, legLocPixels(3) + 150, ...
        legLocPixels(4) + 12 * boxLineWidth];
    
    saveas(disp_opts.legend_fig,'./png/legend.png');
    saveas(disp_opts.legend_fig,'./fig/legend.fig');
    saveas(disp_opts.legend_fig,'./eps/legend.eps','epsc');
end

if disp_opts.stacks_legend || disp_opts.all_figs
    allLineHandles = findall(disp_opts.stackslegend_fig, 'type', 'bar');
    
    warning('off')
    for i = 1:length(allLineHandles)
        allLineHandles(i).XData = NaN;
    end
    
    axis off
    
    disp_opts.stackslegend_handle.Units = 'pixels';
    boxLineWidth = disp_opts.stackslegend_handle.LineWidth;
    
    disp_opts.stackslegend_handle.Position = [75, 1, ...
        disp_opts.stackslegend_handle.Position(3), disp_opts.stackslegend_handle.Position(4)];
    legLocPixels = disp_opts.stackslegend_handle.Position;
    
    disp_opts.stackslegend_fig.Units = 'pixels';
    disp_opts.stackslegend_fig.InnerPosition = [1, 1, legLocPixels(3) + 150, ...
        legLocPixels(4) + 12 * boxLineWidth];
    
    saveas(disp_opts.stackslegend_fig,'./png/stackslegend.png');
    saveas(disp_opts.stackslegend_fig,'./fig/stackslegend.fig');
    saveas(disp_opts.stackslegend_fig,'./eps/stackslegend.eps','epsc');
end
end