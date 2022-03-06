function show_trans(US_data,start_day,param)
    h = findobj('LineWidth',1.6,'-or','LineWidth',1.9);
    delete(h)
    
    cfill1 = [1 1 1]; % stripe 1 color
    cfill2 = [0.74 0.69 0.6]; % stripe 2 color
    cstroke = [0.42 0.34 0.3];
    stripe_counter = 1;

    for dt = 1:length(param.turn_dates)
%         if mod(dt,2); col = "r"; else; col = "k"; end
        
        try
%             xline(index2date(US_data,start_day,...
%                              param.turn_dates(dt)), ...
%                 col,'LineWidth',1.9)
%             xline(index2date(US_data,start_day,...
%                              param.turn_dates(dt) + param.t_trans(dt)/2), ...
%                 ":"+col,'LineWidth',1.6)
%             xline(index2date(US_data,start_day,...
%                              param.turn_dates(dt) - param.t_trans(dt)/2), ...
%                 ":"+col,'LineWidth',1.6)

            
            start_trans1 = param.turn_dates(dt) - param.t_trans(dt)/2;
            end_trans1 = param.turn_dates(dt) + param.t_trans(dt)/2;

            yl = ylim; case_max = yl(2);
            if dt == length(param.turn_dates)
                end_day = length(US_data.cases);

                date_vec = [start_trans1 end_trans1 end_day ...
                    end_day end_trans1 start_trans1];
                case_vec = [0 0 0 case_max case_max case_max];
            else
                start_trans2 = param.turn_dates(dt+1) - param.t_trans(dt+1)/2;
                end_trans2 = param.turn_dates(dt+1) + param.t_trans(dt+1)/2;

                date_vec = [start_trans1 end_trans1 start_trans2 end_trans2 ...
                    end_trans2 start_trans2 end_trans1 start_trans1];
                case_vec = [0 0 0 0 case_max case_max case_max case_max];
            end

            if stripe_counter
                C = reshape(repmat(cfill1,[length(date_vec),1,1]),[length(date_vec) 1 3]);
                C(2,1,:) = cfill2; C(3,1,:) = cfill2; C(end-1,1,:) = cfill2; C(end-2,1,:) = cfill2;
            else
                C = reshape(repmat(cfill2,[length(date_vec),1,1]),[length(date_vec) 1 3]);
                C(2,1,:) = cfill1; C(3,1,:) = cfill1; C(end-1,1,:) = cfill1; C(end-2,1,:) = cfill1;
            end
            stripe_counter = ~stripe_counter;
            
            pl = patch(date_vec,case_vec,C,'linestyle','none');
            uistack(pl,'bottom')

            pl = plot([start_trans1 start_trans1],[0 case_max],'-','color',cstroke,'LineWidth',.5);
            uistack(pl,'down',4);
            pl = plot([end_trans1 end_trans1],[0 case_max],'-','color',cstroke,'LineWidth',.5);
            uistack(pl,'down',4);
        catch
            warning("Data inputs must match the axis configuration. A " + ...
                "numeric axis must have numeric data inputs or data " + ...
                "inputs which can be converted to double.")
        end
    end

    pl = plot([start_trans1 start_trans1],[0 case_max],'-','color',cstroke,'LineWidth',.5);
    uistack(pl,'down',4);
    pl = plot([end_trans1 end_trans1],[0 case_max],'-','color',cstroke,'LineWidth',.5);
    uistack(pl,'down',4);
end