function [M] = truckMass(vars, beta2)
    M = beta2(1)*vars(:,1)+beta2(2)*vars(:,2)+beta2(3)*vars(:,3);
end