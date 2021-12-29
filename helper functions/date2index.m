function in = date2index(US_data,start_day,dt)
    in = datenum(dt - US_data.date(start_day));
end