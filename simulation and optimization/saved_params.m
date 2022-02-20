function [param,fixed_params] = saved_params(fixed_params, nturn_dates, param)
    
switch char(fixed_params.location)
    case "India"
        switch nturn_dates
            case 6
                param.d1 = [1024.08, 68.7422, 81.9796, 262.77, 149.56, 76.6227, 3112.64];
                param.R0 = [3.32761];
                param.turn_dates = [53.8044, 137.163, 241.591, 346.745, 390.341, 471.449];
                param.t_trans = [99.998, 12.315, 96.6621, 28.4856, 35.3839, 100];
                param.d2 = [1.00351];
                
                fixed_params.Mmax = 130;
                fixed_params.Mg = 15;

                fixed_params.dom_vacc = "AstraZeneca";
                %                 fixed_params.vdate = datetime(["December 29, 2020","February 17, 2021","October 5, 2020"]); first reported
                fixed_params.vdate = datetime(["June 6, 2020","February 19, 2021","January 4, 2021","June 4, 2020"]);
                
%                 fixed_params.var_names = ["alpha","gamma","delta"];
%                 fixed_params.dbeta = [1.51223 3.01933 2.62173]; % IN % fit parameters
                
                fixed_params.var_names = ["alpha","gamma","delta","kappa"];
                fixed_params.dbeta = [1.5140 2.8683 2.7973 1.5170]; % IN
                fixed_params.VE1V = [0.514 0.48 0.329 0.514];
                fixed_params.VE2V = [0.661 0.824 0.598 0.661]; % gamma not sure (assume original strain)
                fixed_params.VES1V = [0.3 0.5 0.25 0.3];
                fixed_params.VES2V = [0.3 0.5 0.25 0.3];
                
                fixed_params.country_color = [1.0000 0.6000 0.2000];
%                 fixed_params.country_color = [0.0706 0.5333 0.0275];
        end
    case "Germany"
        switch nturn_dates
            case 5
                param.d1 = [178.716, 1251.35, 110.788, 238.951, 188.225, 1461.83];
                param.R0 = [3.2978];
                param.turn_dates = [47.1543, 204.675, 323.033, 382.676, 446.882];
                param.t_trans = [63.9735, 99.2866, 49.9735, 26.2265, 83.8494];
                param.d2 = [0.526345];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 10;
                fixed_params.vdate = datetime(["October 14, 2020","December 13, 2020","April 14, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [1.8185 2.1101 4.9264]; % DE % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3];
                fixed_params.VE2V = [0.94 0.84 0.88];
                fixed_params.VES1V = [0.8 0.5 0.65];
                fixed_params.VES2V = [0.8 0.5 0.65];
                
%                 fixed_params.country_color = [.8667 0 0];
%                 fixed_params.country_color = [1.0000 0.8078 0];
                fixed_params.country_color = [0 0 0];
        end
    case "Canada"
        switch nturn_dates
            case 6
                param.d1 = [122.648, 1186.07, 293.3, 436.572, 360.324, 1490.31, 483.611];
                param.R0 = [2.4388];
                param.turn_dates = [64.8106, 212.63, 316.453, 377.869, 444.139, 497.259];
                param.t_trans = [75.5788, 98.4836, 53.2145, 29.0432, 92.0192, 12.8243];
                param.d2 = [0.0573392];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 5;
                fixed_params.vdate = datetime(["November 3, 2020","November 27, 2020","March 15, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [1.7345 1.8756 3.3793]; % CA % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3];
                fixed_params.VE2V = [0.94 0.84 0.88];
                fixed_params.VES1V = [0.8 0.5 0.65];
                fixed_params.VES2V = [0.8 0.5 0.65];
                
                fixed_params.country_color = [1 0 0];
        end
    case "Brazil"
        switch nturn_dates
            case 5
                param.d1 = [118.76, 59.4293, 576.819, 290.843, 275.012, 1731.3];
                param.R0 = [3.49517];
                param.turn_dates = [55.8525, 161.558, 222.468, 340.114, 520.58];
                param.t_trans = [26.9674, 81.3655, 30.2808, 87.4284, 98.761];
                param.d2 = [0.0265504];
                
                fixed_params.Mmax = 130;
                fixed_params.Mg = 1;
                fixed_params.vdate = datetime(["December 5, 2020","December 7, 2020","May 11, 2021"]);
                fixed_params.dom_vacc = "Coronavac";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [3.2188 3.7752 9.9908]; % BR
                fixed_params.VE1V = 0.35*ones(1,3); % not sure (assume original strain)
                fixed_params.VE2V = 0.66*ones(1,3); % not sure (assume original strain)
                fixed_params.VES1V = 0.3*ones(1,3);
                fixed_params.VES2V = 0.3*ones(1,3);
                
                fixed_params.country_color = [0 0.6078 0.2275];
        end
    case "United States"
        switch nturn_dates
            case 8
                param.d1 = [95.0072, 414.542, 330.968, 428.851, 163.169, 568.851, 1990.34, 665.331, 1312.57];
                param.R0 = [3.3276];
                param.turn_dates = [49.8727, 106.517, 159.169, 240.609, 337.003, 429.324, 487.224, 555.889];
                param.t_trans = [69.8812, 35.7662, 63.3059, 78.057, 74.1703, 85.3549, 30.3295, 54.1859];
                param.d2 = [0.34508];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 5;
%                 fixed_params.vdate = datetime(["September 23, 2020","December 1, 2020","March 23, 2021"]);
                fixed_params.vdate = datetime(["October 9, 2020","December 6, 2020","March 9, 2021","October 18, 2020"]);
                fixed_params.dom_vacc = "Pfizer";  
                
                fixed_params.var_names = ["alpha","gamma","delta","iota"]; % drop gamma, add omicron
                fixed_params.dbeta = [1.8463 2.1801 4.0832 1.7868]; % US % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3 0.49];
                fixed_params.VE2V = [0.94 0.84 0.88 0.94];
                fixed_params.VES1V = [0.49 0.6 0.3 0.49];
                fixed_params.VES2V = [0.8 0.5 0.65 0.8];
                
                fixed_params.country_color = [0.2353 0.2314 0.4314];
%                 fixed_params.country_color = [0.6980 0.1333 0.2039];
        end
    case "South Korea"
        switch nturn_dates
            case 7
                fixed_params.M = [40,3,1/20,130];
                fixed_params.vdate = datetime(["December 28, 2020","January 18, 2021","March 26, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
            case 8
                param.d1 = [1900, 5400, 1000, 5428.851, 1000, 5568.851, 5990.34, 5665.331, 1312.57];
                param.R0 = [3.3276];
                param.turn_dates = [0.0020 136.8371 175.6904 235.0617 314.5236 427.3550 502.3562 595.7495];
                param.t_trans = [28.0269 30.6100 32.1123 37.7279 72.7676 80.6629 42.5569 42.8702];
                param.d2 = [0.3282];
                
                fixed_params.Mmax = 20;
                fixed_params.Mg = 3;
%                 fixed_params.vdate = datetime(["September 23, 2020","December 1, 2020","March 23, 2021"]);
                fixed_params.vdate = datetime(["October 17, 2020","December 16, 2020","February 9, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [1.6711 2.1695 4.1445]; % US % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3];
                fixed_params.VE2V = [0.94 0.84 0.88];
                fixed_params.VES1V = [0.8 0.5 0.65];
                fixed_params.VES2V = [0.8 0.5 0.65];
                
%                 fixed_params.country_color = [0 0 0];
                fixed_params.country_color = [0.0588 0.3922 0.8039];
        end
    case "Japan"
        switch nturn_dates
            case 9
                param.d1 = [2.2361e+03 8.4170e+03 1.6522e+03 4.2269e+03 1.3960e+03 7.9553e+03 3.1989e+03 8.1442e+03 2.1637e+03 9.9705e+03];
                param.R0 = [3.3276];
                param.turn_dates = [51.9135 102.1143 163.5499 233.0309 329.3993 389.5031 443.2176 493.1815 545.3961];
                param.t_trans = [14.3542 56.8288 59.1253 50.5002 49.5630 30.1260 43.7560 14.6776 27.9043];
                param.d2 = [0.1798];
                
                fixed_params.Mmax = 20;
                fixed_params.Mg = 1;
%                 fixed_params.vdate = datetime(["September 23, 2020","December 1, 2020","March 23, 2021"]);
                fixed_params.vdate = datetime(["December 3, 2020","September 7, 2020","April 7, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [2.33 1.40 4.677]; % US % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3];
                fixed_params.VE2V = [0.94 0.84 0.88];
                fixed_params.VES1V = [0.8 0.5 0.65];
                fixed_params.VES2V = [0.8 0.5 0.65];
                
                fixed_params.country_color = [0.7373 0 0.1765];
        end
        case "South Africa"
        switch nturn_dates
            case 5
                param.d1 = [3.6404 139.6798 12.3264 608.8031 167.7804 1.0164e+03];
                param.R0 = [1.63];
                param.turn_dates = [149.6928 242.3058 328.9866 449.3489 551.7741];
                param.t_trans = [99.9999 43.7968 58.4621 50.1765 81.6247];
                param.d2 = [0.4638];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 5;
                fixed_params.vdate = datetime(["September 9, 2020","November 6, 2020","March 17, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta"];
                fixed_params.dbeta = [1.50661 2.01169 4.12573]; % US % fit parameters
                fixed_params.VE1V = [0.49 0.6 0.3];
                fixed_params.VE2V = [0.94 0.84 0.88];
                fixed_params.VES1V = [0.8 0.5 0.65];
                fixed_params.VES2V = [0.8 0.5 0.65];
                
                fixed_params.country_color = [0.8706 0.2196 0.1922];
        end
end

switch fixed_params.dom_vacc
    case "Pfizer"
        fixed_params.VE1 = 0.8;
        fixed_params.VE2 = 0.95;
        fixed_params.VES1 = 0.8;
        fixed_params.VES2 = 0.3;
    case "AstraZeneca"
        fixed_params.VE1 = 0.76;
        fixed_params.VE2 = 0.824;
        fixed_params.VES1 = 0.5;
        fixed_params.VES2 = 0.3;
    case "Coronavac"
        fixed_params.VE1 = 0.35;
        fixed_params.VE2 = 0.66;
        fixed_params.VES1 = 0.3;
        fixed_params.VES2 = 0.3;
end
end