function [param,fixed_params] = saved_params(fixed_params, nturn_dates, param)
    
switch char(fixed_params.location)
    case "India"
        switch nturn_dates
            case 7
                param.d1 = [800, 10.028, 16.411, 30.757, 5.2034, 28.9787, 2785.06, 754.207];
                param.R0 = 4.26513;
                param.turn_dates = [64.6794, 145.785, 241.184, 345.599, 384.612, 469.651, 588.844];
                param.t_trans = [99.2163, 13.0736, 97.2638, 29.0032, 36.4126, 99.9978, 53.8345];
                param.d2 = [0.786196];
                
                fixed_params.Mmax = 130;
                fixed_params.Mg = 15;
%                 fixed_params.Mmax = 10;
%                 fixed_params.Mg = 10;

                fixed_params.dom_vacc = "AstraZeneca";
%                 fixed_params.vdate = datetime(["December 29, 2020","February 17, 2021","October 5, 2020"]); first reported
                fixed_params.vdate = datetime(["June 13, 2020","January 6, 2021","June 10, 2020","December 1, 2021"]);
                
%                 fixed_params.var_names = ["alpha","gamma","delta"];
%                 fixed_params.dbeta = [1.51223 3.01933 2.62173]; % IN % fit parameters
                
                fixed_params.var_names = ["alpha","delta","kappa","omicron"];
                fixed_params.dbeta = [1.7570 3.9890 1.7564 8]; % IN
%                 fixed_params.VE1V = [0.514 0.329 0.514 .3];
%                 fixed_params.VE2V = [0.661 0.598 0.661 .5]; % gamma not sure (assume original strain)
%                 fixed_params.VES1V = [0.3 0.25 0.3 .2];
%                 fixed_params.VES2V = [0.3 0.25 0.3 .1];
                
                fixed_params.country_color = [1.0000 0.6000 0.2000];
%                 fixed_params.country_color = [0.0706 0.5333 0.0275];
        end
    case "Germany"
        switch nturn_dates
            case 7
                param.d1 = [146.845, 1977.07, 153.127, 180.2692, 261.762, 843.79, 10, 9e3];
                param.R0 = [3.18799];
                param.turn_dates = [25.1784, 207.593, 333.261, 382.942, 453.076, 571.448, 686.961];
                param.t_trans = [46.6826, 84.8377, 51.1679, 29.721, 88.132, 39.266, 40.7622];
                param.d2 = [0.353108];

                fixed_params.Mmax = 10;
                fixed_params.Mg = 10;
                fixed_params.vdate = datetime(["October 7, 2020","May 4, 2021","November 24, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","delta","omicron"];
                fixed_params.dbeta = [1.5888 4.5 8.2]; % DE % fit parameters
%                 fixed_params.VE1V = [0.49 0.3 .3];
%                 fixed_params.VE2V = [0.94 0.88 .5];
%                 fixed_params.VES1V = [0.8 0.65 .1];
%                 fixed_params.VES2V = [0.8 0.65 .2];
                
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
                fixed_params.vdate = datetime(["November 3, 2020","November 27, 2020","March 15, 2021","December 1, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","gamma","delta","omicron"];
                fixed_params.dbeta = [1.7345 1.8756 3.3793,6]; % CA % fit parameters
%                 fixed_params.VE1V = [0.49 0.6 0.3 .3];
%                 fixed_params.VE2V = [0.94 0.84 0.88 .5];
%                 fixed_params.VES1V = [0.8 0.5 0.65 .1];
%                 fixed_params.VES2V = [0.8 0.5 0.65 .2];
                
                fixed_params.country_color = [1 0 0];
        end
    case "Brazil"
        switch nturn_dates
            case 5
                param.d1 = [118.76, 59.4293, 576.819, 290.843, 275.012, 1731.3];
                param.R0 = [2.3];
                param.turn_dates = [55.8525, 161.558, 222.468, 340.114, 520.58];
                param.t_trans = [26.9674, 81.3655, 30.2808, 87.4284, 98.761];
                param.d2 = [0.0265504];
                
                fixed_params.Mmax = 15;
                fixed_params.Mg = 1;
                fixed_params.vdate = datetime(["September 2, 2020","December 5, 2020","July 11, 2021","December 1, 2021"]);
                fixed_params.dom_vacc = "Coronavac";
                
                fixed_params.var_names = ["zeta","gamma","delta","omicron"]; % zeta
                fixed_params.dbeta = [1.8 2.5 9.9908,20]; % BR
%                 fixed_params.VE1V = 0.35*ones(1,4); % not sure (assume original strain)
%                 fixed_params.VE2V = 0.66*ones(1,4); % not sure (assume original strain)
%                 fixed_params.VES1V = 0.3*ones(1,4);
%                 fixed_params.VES2V = 0.3*ones(1,4);
                
                fixed_params.country_color = [0 0.6078 0.2275];
        end
    case "United States"
        switch nturn_dates
            case 9
                param.d1 = [67.9992, 919.524, 915.99, 712.859, 76.5559, 472.938, 3162.76, 618.928, 453.467, 2984.96];
                param.R0 = [3.08178];
                param.turn_dates = [37.7616, 106.471, 161.278, 232.628, 319.552, 429.171, 489.087, 579.911, 685.484];
                param.t_trans = [70.4755, 41.6667, 62.8589, 75.7381, 64.5479, 81.9728, 25.1566, 51.0688, 29.5589];
                param.d2 = [0.00209823];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 6;
%                 fixed_params.vdate = datetime(["September 23, 2020","December 1, 2020","March 23, 2021"]);
                fixed_params.vdate = datetime(["October 19, 2020","March 18, 2021","October 15, 2020","November 26, 2021"]);
                fixed_params.dom_vacc = "Pfizer";  
                
                fixed_params.var_names = ["alpha","delta","iota","omicron"]; % epsilon
                fixed_params.dbeta = [1.8007 4.1604 1.6899 21.7992]; % US % fit parameters
%                 fixed_params.VE1V = [0.49 0.3 0.49 .3];
%                 fixed_params.VE2V = [0.94 0.88 0.94 .5];
%                 fixed_params.VES1V = [0.49 0.6 0.3 0.1];
%                 fixed_params.VES2V = [0.8 0.5 0.65 .1];
                
                fixed_params.country_color = [0.2353 0.2314 0.4314];
%                 fixed_params.country_color = [0.6980 0.1333 0.2039];
        end
    case "South Korea"
        switch nturn_dates
            case 7
                fixed_params.M = [40,3,1/20,130];
                fixed_params.vdate = datetime(["December 28, 2020","January 18, 2021","March 26, 2021","December 1, 2021"]);
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
                fixed_params.vdate = datetime(["October 17, 2020","December 16, 2020","February 9, 2021","December 1, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","delta","omicron"];
                fixed_params.dbeta = [1.6711 4.1445 6]; % US % fit parameters
%                 fixed_params.VE1V = [0.49 0.3 .3];
%                 fixed_params.VE2V = [0.94 0.88 .5];
%                 fixed_params.VES1V = [0.8 0.65 .1];
%                 fixed_params.VES2V = [0.8 0.65 .2];
                
%                 fixed_params.country_color = [0 0 0];
                fixed_params.country_color = [0.0588 0.3922 0.8039];
        end
    case "Japan"
        switch nturn_dates
            case 11
                param.d1 = [763.9677 9.9770e+03 1.0276e+03 4.6443e+03 1.0314e+03 5.1941e+03 2.2244e+03 9e+03 1.2294e+03 9.9917e+03 400 9e3];
                param.R0 = 1.9706;
                param.turn_dates = [41.8392 90.7029 150.2255 215.4864 323.6940 376.8371 437.7591 499.9849 543.8163 653.7094 702];
                param.t_trans = [14.7134 20.4305 62.0031 41.1171 55.3854 31.4606 48.9979 46.0483 31.3424 48.0987 30];
                param.d2 = 0.1673;
                
                fixed_params.Mmax = 20;
                fixed_params.Mg = 1;
%                 fixed_params.vdate = datetime(["September 23, 2020","December 1, 2020","March 23, 2021"]);
                fixed_params.vdate = datetime(["December 20, 2020","June 2, 2021","November 20, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["alpha","delta","omicron"];
                fixed_params.dbeta = [2 5.7845 11.8]; % US % fit parameters
%                 fixed_params.VE1V = [0.49 0.6 0.3 .3];
%                 fixed_params.VE2V = [0.94 0.84 0.88 .5];
%                 fixed_params.VES1V = [0.8 0.5 0.65 .1];
%                 fixed_params.VES2V = [0.8 0.5 0.65 .2];
                
                fixed_params.country_color = [0.7373 0 0.1765];
        end
        case "South Africa"
        switch nturn_dates
            case 5
                param.d1 = [15.0103, 200, 2200, 650.601, 3500, 9900];
                param.R0 = [1.7066];
                param.turn_dates = [140, 310.108, 432.427, 530.405, 661.524];
                param.t_trans = [80, 45.987, 52.4702, 113.6579, 52.2914];
                param.d2 = [0.0114195];
                
                fixed_params.Mmax = 10;
                fixed_params.Mg = 5;
                fixed_params.vdate = datetime(["September 12, 2020","March 13, 2021","November 1, 2021"]);
                fixed_params.dom_vacc = "Pfizer";
                
                fixed_params.var_names = ["beta","delta","omicron"];
                fixed_params.dbeta = [2.4 4.6 19]; 
%                 fixed_params.VE1V = [0.6 0.3 .3];
%                 fixed_params.VE2V = [0.84 0.88 .5];
%                 fixed_params.VES1V = [0.5 0.65 .1];
%                 fixed_params.VES2V = [0.5 0.65 .2];
                
                fixed_params.country_color = [0.8706 0.2196 0.1922];
        end
end

switch fixed_params.dom_vacc
    case "Pfizer"
        fixed_params.VE1 = 0.8;
        fixed_params.VE2 = 0.95;
        fixed_params.VES1 = 0.8;
        fixed_params.VES2 = 0.3;

        VE1V.alpha = 0.49; VE1V.delta = 0.3;
        VE1V.iota = 0.49; VE1V.omicron = .3; 
        VE1V.beta = .6;

        VE2V.alpha = 0.94; VE2V.delta = 0.88;
        VE2V.iota = 0.94; VE2V.omicron = .5; 
        VE2V.beta = .84;

        VES1V.alpha = 0.49; VES1V.delta = 0.6;
        VES1V.iota = 0.3; VES1V.omicron = 0.2; 
        VES1V.beta = .5;

        VES2V.alpha = 0.8; VES2V.delta = 0.5;
        VES2V.iota = 0.65; VES2V.omicron = .1; 
        VES2V.beta = .5;
    case "AstraZeneca"
        fixed_params.VE1 = 0.76;
        fixed_params.VE2 = 0.824;
        fixed_params.VES1 = 0.5;
        fixed_params.VES2 = 0.3;

        VE1V.alpha = 0.514; VE1V.delta = 0.329;
        VE1V.kappa = 0.514; VE1V.omicron = .3;

        VE2V.alpha = 0.661; VE2V.delta = 0.598;
        VE2V.kappa = 0.661; VE2V.omicron = .5;

        VES1V.alpha = 0.3; VES1V.delta = 0.25;
        VES1V.kappa = 0.3; VES1V.omicron = 0.2;

        VES2V.alpha = 0.3; VES2V.delta = 0.25;
        VES2V.kappa = 0.3; VES2V.omicron = .1;
    case "Coronavac"
        fixed_params.VE1 = 0.35;
        fixed_params.VE2 = 0.66;
        fixed_params.VES1 = 0.3;
        fixed_params.VES2 = 0.3;

        VE1V.gamma = 0.514; VE1V.delta = 0.329;
        VE1V.zeta = 0.514; VE1V.omicron = .3;

        VE2V.gamma = 0.661; VE2V.delta = 0.598;
        VE2V.zeta = 0.661; VE2V.omicron = .5;

        VES1V.gamma = 0.3; VES1V.delta = 0.25;
        VES1V.zeta = 0.3; VES1V.omicron = 0.2;

        VES2V.gamma = 0.3; VES2V.delta = 0.25;
        VES2V.zeta = 0.3; VES2V.omicron = .1;
end
fixed_params.VE1V  = arrayfun(@(x)(VE1V.(x)), fixed_params.var_names);
fixed_params.VE2V  = arrayfun(@(x)(VE2V.(x)), fixed_params.var_names);
fixed_params.VES1V  = arrayfun(@(x)(VES1V.(x)), fixed_params.var_names);
fixed_params.VES2V  = arrayfun(@(x)(VES2V.(x)), fixed_params.var_names);

% relative reinfection rate (0 = no RI, 1 = no infection-induced immunity)
k.orig = 0; kw.orig = 0;
k.alpha = 0; k.beta = 0; k.delta = 0; k.omicron = 0;
k.iota = 0; k.kappa = 0; k.gamma = 0; k.zeta = 0;
% waning asymptote
kw.alpha = 0.098; kw.beta = 0.143; kw.delta = 0.08; kw.omicron = 0.44; 
kw.iota = 0; kw.kappa = 0; kw.gamma = 0; kw.zeta = kw.alpha;

fixed_params.k  = arrayfun(@(x)(k.(x)),  ["orig",fixed_params.var_names]);
fixed_params.kw = arrayfun(@(x)(kw.(x)), ["orig",fixed_params.var_names]);
end