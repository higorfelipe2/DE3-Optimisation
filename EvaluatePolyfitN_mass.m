function [f] = EvaluatePolyfitN_mass(vars)
    f = 0.0189 + 0.0080*vars(:,1) + -5.52252330184672e-05*vars(:,1).^2 + -0.00122794297352350*vars(:,2) + 6.86477623770676e-06*vars(:,2).^2 + -0.0417482506990372*vars(:,3) + 0.00350681478105935*vars(:,3).^2;
end