function total_immunity = calc_immunity(yt,fixed_params)
    % calculate weighted population immunity over time

    n_var = length(fixed_params.dbeta);
    
    yix = fixed_params.yix;
    nD = yix.nD; nI = yix.nI; nR = yix.nR; nRW = yix.nRW;

    VE1 = fixed_params.VE1; VE2 = fixed_params.VE2;
    VE1V = fixed_params.VE1V'; VE2V = fixed_params.VE2V';
    VES1 = fixed_params.VES1; VES1V = fixed_params.VES1V';
    VES2 = fixed_params.VES2; VES2V = fixed_params.VES2V';
    k = fixed_params.k; kw = fixed_params.kw;

    % VE(immunity #, variant #)
    % immunity #: unvaccinated, first dose, second dose, waning1, waning2
    VE = [zeros(1,1+n_var) ; [VE1 VE1V'] ; [VE2 VE2V'] ; [VES1 VES1V'] ; [VES2 VES2V']];

    total_immunity =  zeros(1,size(yt,1));
    for tidx = 1:size(yt,1)
        y = squeeze(yt(tidx,:,:));
        % vaccine-mediated immunity for each compartment
        vacc_immunity = VE*sum(y(:,nI),1)'./sum(y(:,nI),'all');
        vacc_immunity = repmat(vacc_immunity,[1,size(y,2)]);
        vacc_immunity(:,nD) = 0;

        % infection-mediated immunity for each compartment
        inf_immunity = ones(size(y));
        inf_immunity(:,nR) = repmat((1-k)*sum(y(:,nI),1)'/sum(y(:,nI),'all') - (1-k).*sum(y(:,nI),1),[size(y,1),1]);
        inf_immunity(:,nRW) = repmat((1-kw)*sum(y(:,nI),1)'/sum(y(:,nI),'all') - (1-kw).*sum(y(:,nI),1),[size(y,1),1]);
        
        total_immunity(tidx) = sum(y.*vacc_immunity.*inf_immunity,'all');
    end
end