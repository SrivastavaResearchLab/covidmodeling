function outflow = distribute_flows(y,threshold,nD)
    % distribute outflow from vaccination, etc. proportionally by layer
    % y: compartments
    % upflow: flow into higher compartment (S<-V1<-V2<-VS)
    % downflow: flow into lower compartment (S->V1->V2->VS)
    % threshold: if a compartment is below this amount, there will be no outflow
    % deceased compartment index
    
    outflow = y;
    outflow(sum(y,2)<=threshold,:) = 0; % compartments where there will be outflow
    outflow(:,nD) = 0; % no outflow from deceased compartment
    
    % sum of people on each immunity level
    sum_outflow = sum(outflow,2);
    sum_outflow = repmat(sum_outflow,1,size(outflow,2));
    
    % replace all 0's with 1's (to avoid NaN), then divide
    sum_outflow = sum_outflow + (sum_outflow==0);
    outflow = outflow./sum_outflow;
end