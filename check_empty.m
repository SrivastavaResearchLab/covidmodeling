function [upflow,downflow] = check_empty(y,upflow,downflow,threshold,nD)
    % y: compartments, upflow: flow into higher compartment (S<-V1<-V2<-VS)
    % downflow: flow into lower compartment (S->V1->V2->VS)
    % threshold: if a compartment is below this amount, there will be no outflow
    % deceased compartment index
    
    outflow = y.*(y >= threshold); % compartments where there will be outflow
    outflow(nD,:) = 0; % no outflow from deceased compartment
    
    sum_outflow = sum(outflow,2);
    sum_outflow = repmat(sum_outflow,1,size(outflow,2));
    
    % replace all 0's with 1's (to avoid NaN), then divide
    sum_outflow = sum_outflow + (sum_outflow==0);
    outflow = outflow./sum_outflow;
    
    upflow = outflow.*upflow;
    downflow = outflow.*downflow;
end