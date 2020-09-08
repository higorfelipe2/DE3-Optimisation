function [f] = EvaluatePolyfitN(vars, beta)
    f = beta(1)+ beta(2)*vars(:,1) + beta(3)*vars(:,1).^2 + beta(4)*vars(:,2) + beta(5)*vars(:,2).^2 + beta(6)*vars(:,3) + beta(7)*vars(:,3).^2;
end