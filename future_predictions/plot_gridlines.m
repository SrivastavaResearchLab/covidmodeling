function plot_gridlines(surf_handle, x_gridlines, y_gridlines)
    x_data=surf_handle.XData;
    y_data=surf_handle.YData;
    z_data=surf_handle.ZData;
    
    x=x_data(1,:);
    y=y_data(:,1);

    xspacing = round(length(x)/x_gridlines);
    %%Plot the mesh lines 
    % Plotting lines in the X-Z plane
    hold on
    xz_lines = linspace(y(1),y(end),y_gridlines);
    for i = 1:y_gridlines
        Y1 = xz_lines(i)*ones(size(x)); % a constant vector
        Z1 = interp2(datenum(x_data)-datenum(x_data(1,1))+1,y_data,z_data,...
            datenum(x_data(1,:))-datenum(x_data(1,1))+1,Y1);
        p = plot3(x,Y1,Z1,'-k');
        p.LineWidth = 1;
    end
    % Plotting lines in the Y-Z plane
    for i = 1:xspacing:length(x)
        [r, c] = size(y);
        X2 = repmat(x(i),r,c);
        Z2 = z_data(:,i);
        p = plot3(X2,y,Z2,'-k');
        p.LineWidth = 1;
    end
hold off
end