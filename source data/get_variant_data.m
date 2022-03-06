function fixed_params = get_variant_data(var_data, fixed_params)
    % get data for the proportion of each variant over time in a given region
    
    region = var_data.vsheet_name; variant_file = var_data.variant_file;
    var_names = fixed_params.var_names;

    for v = 1:length(var_names)
        var = char(var_names(v));
        is_voc = sum(var == ["alpha" "beta" "gamma" "delta" "omicron"]);
        if is_voc
            sheet_name = "VOC " + upper(var(1)) + lower(var(2:end));
        else
            sheet_name = "VOI " + upper(var(1)) + lower(var(2:end));
        end
        
        [~,~,variant_sheet] = xlsread(variant_file,sheet_name);
        
        variant_sheet = cell2table(variant_sheet);
        selected = find(ismember(string(table2array(variant_sheet(:,1))),region));
        
        if sum(selected) == 0
            error(region + " can not be found in vaccination data")
        else
            v_data = variant_sheet(selected:(selected+1),:);
            v_data = cell2mat(v_data{:,3:end});
            v_data = v_data(1,:)./v_data(2,:);

            % remove points where data was not collected for the next 7 days (twice)
            nanx = isnan(v_data);
            omit = find(~nanx);
            omit = omit(diff(omit)>=7);
            v_data(omit) = nan;

            nanx = isnan(v_data);
            omit = find(~nanx);
            omit = omit(diff(omit)>=7);
            v_data(omit) = nan;
            
            % interpolate values where no data was collected
            nanx = isnan(v_data);
            t=1:numel(v_data);
            if sum(~nanx) > 2
                v_data(nanx) = interp1(t(~nanx), v_data(~nanx), t(nanx));
            end
            
            % replace last section of missing data with last reported
            nanx = isnan(v_data);
            last_reported = find(~nanx,1,'last');
            v_data(cumsum(~nanx)==sum(~nanx)) = v_data(last_reported);

            % replace first section of missing data with 0 (no variant)
            nanx = isnan(v_data);
            v_data(nanx) = 0;
            
            variant_data.(var_names(v)) = v_data;
            if v == 1
                vsum=v_data;
            else
                vsum = vsum + v_data;
            end
        end
        t = table2array(variant_sheet(1,3:end));
    end
    
    % normalize all variant's reported data (should never sum > 1)
    for v = 1:length(var_names)
        variant_data.(var_names(v)) = variant_data.(var_names(v))./max(vsum,1);
    end

    variant_data.t = datetime(table2array(variant_sheet(1,3:end)));
    
    % remove data entries for the 0th week (duplicate with 52nd week)
%     variant_data = structfun(@(x) x(week~=0),variant_data,'UniformOutput',false);
    
    fixed_params.variant_data = variant_data;
end