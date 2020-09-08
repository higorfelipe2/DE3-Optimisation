clear all
clc

%possible values
%hT values here are before dividing by sin45 to adjust for the
%angle of the truck
hT = 40:85;
lT = 70:220;
rT = 3:15;

%vars is the actual data you care about, that will be input as design
%variable in CAD
%vars_norm is the normalised data, between 0 and 1
[vars vars_norm] = lhsdesign_modified(20, [hT(1) lT(1) rT(1)], [hT(end) lT(end) rT(end)]);

%vars(:,1) = round(vars(:,1),3,'significant')
%vars(:,2) = round(vars(:,2),2,'significant')
%vars(:,3) = round(vars(:,3),0,'decimal')
%round(3132,2,'significant')