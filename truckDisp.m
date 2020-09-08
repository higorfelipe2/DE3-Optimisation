function [D] = truckDisp(vars, beta)
    D = beta(1)*vars(:,1)+beta(2)*vars(:,2)+beta(3)*vars(:,3);
end