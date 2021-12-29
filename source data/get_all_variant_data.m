function fixed_params = get_all_variant_data(region, variant_file, fixed_params, plotc)
    % get data for the proportion of each variant over time in a given region
    
    var_names = sheetnames(variant_file);

    for v = 2:length(var_names)
        sheet_name = var_names(v);
        split_var = split(var_names(v));
        var_names(v) = split_var(2);
        
        [~,~,variant_sheet] = xlsread(variant_file,sheet_name);
        
        variant_sheet = cell2table(variant_sheet);
        selected = find(ismember(string(table2array(variant_sheet(:,1))),region));
        
        if sum(selected) == 0
            disp(region + " can not be found in variant data (" + string(var_names(v)) + ")")
        else
            v_data = variant_sheet(selected:(selected+1),:);
            v_data = cell2mat(v_data{:,3:end});
            v_data = v_data(1,:)./v_data(2,:);
            
            raw_data.(var_names(v)) = v_data;
            
            nanx = isnan(v_data);
%             nanx = nanx | ()
            
            if sum(~nanx) <= 2
                disp("insufficient variant data for variant " + string(var_names(v)) + " in " + region)
            else
                % interpolate values where no data was collected
                t=1:numel(v_data);
                disp(string(var_names(v)))
                disp(size(v_data));
                disp(size(t(~nanx)));
                disp(size(t(nanx)));
                v_data(nanx) = interp1(t(~nanx), v_data(~nanx), t(nanx));

                % replace first section of missing data with 0 (no variant)
                nanx = isnan(v_data);
                v_data(nanx) = 0;

                variant_data.(var_names(v)) = v_data;
            end
        end
    end
    t = table2array(variant_sheet(1,3:end));
    week = cellfun(@(x) str2double(x(end-1:end)),t,'UniformOutput',false);
    year = cellfun(@(x) str2double(x(1:4)),t,'UniformOutput',false);
    
    week = cell2mat(week);
    year = cell2mat(year);
    
    t = datetime(year,1,1);
    t = t - days(weekday(t)) + days(week*7);
    
    variant_data.t = t;
    raw_data.t = t;
    
    % remove data entries for the 0th week (duplicate with 52nd week)
    variant_data = structfun(@(x) x(week~=0),variant_data,'UniformOutput',false);
    raw_data = structfun(@(x) x(week~=0),raw_data,'UniformOutput',false);
    
    fixed_params.variant_data = variant_data;
    
    if plotc
        fig_proc = figure; hold on
        fn = fieldnames(variant_data);
        n_vars = length(fn) - 1;
        
        for v = 1:n_vars
            var_name = fn{v};
            plot(variant_data.t,(variant_data.(var_name)),'DisplayName',var_name);
        end
        legend('location','northwest')
        xlabel('t')
        ylabel('reported variant proportion')
        title("processed variant proportions over time: " + region)
        axis tight
        
        saveas(fig_proc,"./png/reportedvariantprops_" + string(region) + ".png")
        saveas(fig_proc,"./fig/reportedvariantprops_" + string(region) + ".fig")
        saveas(fig_proc,"./eps/reportedvariantprops_" + string(region) + ".eps",'epsc')
        
        fig_raw = figure; hold on
        fn = fieldnames(variant_data);
        n_vars = length(fn) - 1;
        
        for v = 1:n_vars
            var_name = fn{v};
            plot(raw_data.t,(raw_data.(var_name)),'o','DisplayName',var_name);
        end
        legend('location','northwest')
        xlabel('t')
        ylabel('reported variant proportion, raw')
        axis tight
        title("raw variant proportions over time: " + region)
        
        saveas(fig_raw,"./png/reportedvariantprops(raw)_" + string(region) + ".png")
        saveas(fig_raw,"./fig/reportedvariantprops(raw)_" + string(region) + ".fig")
        saveas(fig_raw,"./eps/reportedvariantprops(raw)_" + string(region) + ".eps",'epsc')
    end
end