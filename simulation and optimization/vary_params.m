function param_v = vary_params(t,param)
% returns appropriate values of time-varying parameters according to t
t_trans = param.t_trans;
v_trans = t_trans .* ones(size(param.turn_dates));

if ~isempty(param.turn_dates) % behavior changes at least once
    if length(t) > 1 % time-series data
        turn_dates = [param.turn_dates t(end)]; % add end day of last wave
        
        fn = fieldnames(param);
        fn(ismember(fn,'M')) = []; % don't vary M with time
        for k=1:numel(fn)
            % set parameter equal to its initial value
            param_v.(fn{k}) = param.(fn{k})(1) * ones(size(t));
            
            % vary parameter over t if it has multiple values
            for n = 1:(length(param.(fn{k}))-1)
                % start/end date of nth change in behavior
                start_d = round(turn_dates(n)); end_d = round(turn_dates(n+1));
                time_frame = (t>=start_d) & (t<=end_d);

                param_v.(fn{k})(time_frame) = param.(fn{k})(n+1);
                
                trans_time = abs(t-param.turn_dates(n)) < v_trans(n)/2;
                mu = (t(trans_time)-param.turn_dates(n)+v_trans(n)/2)./v_trans(n);
                mu = (1 - cos(mu*pi))/2;
                param_v.(fn{k})(trans_time) = param.(fn{k})(n)*(1-mu) + ...
                        param.(fn{k})(n+1)*mu;
            end
        end
    else % at a single time point
        fn = fieldnames(param);
        fn(ismember(fn,'M')) = []; % don't vary M with time
        
        for k=1:numel(fn)
            % set parameter equal to its initial value
            param_v.(fn{k}) = param.(fn{k})(1);
            
            % update parameter if it has multiple values
            for n = 1:(length(param.(fn{k}))-1)
                if t >= param.turn_dates(n)
                    param_v.(fn{k}) = param.(fn{k})(n+1);
                end
                if abs(t-param.turn_dates(n)) < v_trans(n)/2
                    mu = (t-param.turn_dates(n)+v_trans(n)/2)/v_trans(n);
                    mu = (1 - cos(mu*pi))/2;
                    param_v.(fn{k}) = param.(fn{k})(n)*(1-mu) + ...
                        param.(fn{k})(n+1)*mu;
                end
            end
        end
    end
else
    param_v = param;
end

end