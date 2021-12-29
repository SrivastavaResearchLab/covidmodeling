function dt = index2date(US_data,start_day,index)
    start_ind = datenum(US_data.date(start_day));
    dt = datetime(datestr(start_ind+index));
end