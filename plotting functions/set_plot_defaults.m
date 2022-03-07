function fixed_params = set_plot_defaults(fixed_params)
    % color scheme!
%     brown = [78 54 41]/255;
%     red   = [237 28 36]/255;
%     gold  = [255 199 44]/255;
%     black = [0 0 0];
%     gray  = [152, 164, 174]/255;
%     green = [101 166 102]/255;
%     pink = [237 197 218]/255;
%     blue = [179 231 255]/255;

    colors.grayL = [135 160 178]/255;
    colors.gray = [92 107 109]/255;
    colors.grayD = [49 54 40]/255;
    colors.brown = [125 74 38]/255;
    colors.red = [244 91 105]/255;
    colors.orange = [243 146 55]/255;
    colors.yellow = [255 182 0]/255;
    colors.white = [249 234 225]/255;
    colors.sand = [244 209 174]/255;
    
%     colors.brown=brown;colors.red=red;colors.gray=gray;
%     colors.gold=gold;colors.black=black;colors.blue=blue;
    fixed_params.colors = colors;

    % set default plot settings
    set(groot,'defaultAxesFontSize',35)
    set(groot,'defaultLineLineWidth',8)
    set(groot,'defaultFigurePosition',[2 0.2 1000 754])
    set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},...
        {'k','k','k'})
    set(groot,'defaultAxesFontName','Times New Roman')
%     set(groot,'defaultAxesColorOrder',[gold;pink;green;gray;brown;red]);
    set(groot,'DefaultFigureVisible','on');
    set(groot,'DefaultAxesLineStyleOrder',{'-','-.','--',':'})

    % option to display figures or just save
    set(groot,'DefaultFigureVisible','on')
end