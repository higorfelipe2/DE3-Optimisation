function [f] = truckMDws(vars,beta,w)
    M = EvaluatePolyfitN(vars,beta(:,1));
    D = EvaluatePolyfitN(vars,beta(:,3));
    f = (w(1)*M + w(2)*D);
end