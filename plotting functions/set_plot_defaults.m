function fixed_params = set_plot_defaults()
    % color scheme!
    brown = [78 54 41]/255;
    red   = [237 28 36]/255;
    gold  = [255 199 44]/255;
    black = [0 0 0];
    gray  = [152, 164, 174]/255;
    green = [101 166 102]/255;
    pink = [237 197 218]/255;
    blue = [179 231 255]/255;
    
    colors.brown=brown;colors.red=red;colors.gray=gray;
    colors.gold=gold;colors.black=black;colors.blue=blue;
    fixed_params.colors = colors;

    % set default plot settings
    set(groot,'defaultAxesFontSize',35)
    set(groot,'defaultLineLineWidth',8)
    set(groot,'defaultFigurePosition',[2 0.2 1000 754])
    set(groot,{'DefaultAxesXColor','DefaultAxesYColor','DefaultAxesZColor'},...
        {'k','k','k'})
    set(groot,'defaultAxesFontName','Times New Roman')
    set(groot,'defaultAxesColorOrder',[gold;pink;green;gray;brown;red]);
    set(groot,'DefaultFigureVisible','on');
    set(groot,'DefaultAxesLineStyleOrder',{'-','-.','--',':'})

    % option to display figures or just save
    set(groot,'DefaultFigureVisible','on')
end