function show_trans(US_data,start_day,param)
    h = findobj('LineWidth',1.6,'-or','LineWidth',1.9);
    delete(h)
    
    for dt = 1:length(param.turn_dates)
        if mod(dt,2); col = "r"; else; col = "k"; end
        
        try
            xline(index2date(US_data,start_day,...
                             param.turn_dates(dt)), ...
                col,'LineWidth',1.9)
            xline(index2date(US_data,start_day,...
                             param.turn_dates(dt) + param.t_trans(dt)/2), ...
                ":"+col,'LineWidth',1.6)
            xline(index2date(US_data,start_day,...
                             param.turn_dates(dt) - param.t_trans(dt)/2), ...
                ":"+col,'LineWidth',1.6)
        catch
            warning("Data inputs must match the axis configuration. A " + ...
                "numeric axis must have numeric data inputs or data " + ...
                "inputs which can be converted to double.")
            
            param.turn_dates
        end
    end
end