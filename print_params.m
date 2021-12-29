function print_params(param, fixed_params, disp_opts)
if disp_opts.print_params
    US_data = fixed_params.US_data; start_day = fixed_params.start_day;
    
    if isempty(char(disp_opts.fname))
        fid = 1; % print to console
    else
        fid = fopen(disp_opts.fname, 'a+');
    end

    fprintf(fid,['\n' char(fixed_params.location) '\n']);
    fprintf(fid,string(fixed_params.N));

    turn_dates = datenum(US_data.date(start_day)) + param.turn_dates;

    fprintf(fid,"\n_Behavioral Changes_\n");
    for n=1:length(turn_dates)
        start_trans = datestr(turn_dates(n) - param.t_trans(n)/2);
        end_trans = datestr(turn_dates(n) + param.t_trans(n)/2);
        fprintf(fid,'%s ',start_trans);
        fprintf(fid,'-> %s\n',end_trans);
    end

    fprintf(fid,"__optimized parameters__\n");
    fn = fieldnames(param);
    param_string = '';
    for f=1:length(fn)
        s = ['param.' char(fn{f}) ' = [' sprintf('%g, ',param.(fn{f}))];
        s=s(1:end-2); s = [s '];\n'];
        param_string = [param_string s];
    end
    fprintf(fid,param_string);
end
end