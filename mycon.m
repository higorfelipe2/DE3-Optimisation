function [c,ceq] = mycon(vars,beta,sigma)
c = EvaluatePolyfitN(vars,beta(:,2))-sigma; 
ceq = [];
end