%Multivariable regression to find objective functions
clc
clear all
tic
%extract and format data, remove unnecessary columns and sort
data = readtable('Dataset.xlsx');
data.fatigue = []; %remove fatigue data, not gonna be used
raw_data = sortrows(data,'displacement_mm_','ascend');
data = table2array(raw_data);
data(:,1) = data(:,1)*sin(45); %measured height is straight up to the deck (truck is at an angle)

%----------------------
%separate test data
split = round(length(data)*0.3);
data(end-split:end,:) = [];
test = data(end-split:end,:);

%----------------------
%independant variables
hT = data(:,1);
lT = data(:,2);
rT = data(:,3);
vars = [hT lT rT];

%dependant variables
mass = data(:,4);
stress = data(:,5);
disp = data(:,6);

%----------------------
% Check for multicollinearity (values below 5 show little to no
% multicollinearity)
% Standardization is required when there are high levels of
% multicollinearity
% https://statisticsbyjim.com/regression/standardize-variables-regression/
% The low vif values shows a low level of
% multicollinearity between independant variables (as expected), so standardisation of
% the variables isn't required.
V = vif([hT lT rT]);

%----------------------
%Linearity check
cftool

%----------------------
%perform multivariable regression to find objective function for
%mass
Y = data(:,4);
x = data(:,1:end-3);
betaM = mvregress(x,Y);

%perform multivariate regression to find objective function for
%stress
Y2 = data(:,5);
betaS = mvregress(x,Y2);

%perform multivariable regression to find objective function for
%displacement
Y3 = data(:,6);
betaD = mvregress(x,Y3);

%----------------------
%Model predictions using regression functions truckDisp and
%truckMass
mass_pred = truckMass([test(:,1) test(:,2) test(:,3)], betaM);
stress_pred = truckMass([test(:,1) test(:,2) test(:,3)], betaS);
disp_pred = truckDisp([test(:,1) test(:,2) test(:,3)], betaD);

%model accuracy checks
means = [mean(mass_pred) mean(test(:,4));
         mean(stress_pred) mean(test(:,5));
         mean(disp_pred) mean(test(:,6))];
     
r2_mass_model = rsquare(mass_pred, test(:,4));
r2_stress_model = rsquare(stress_pred, test(:,5));
r2_disp_model = rsquare(disp_pred, test(:,6));

RMSEpc_mass_model = (sqrt(mean((mass_pred-test(:,4)).^2))/mean(test(:,4)))*100;
RMSEpc_stress_model = (sqrt(mean((stress_pred-test(:,5)).^2))/mean(test(:,5)))*100;
RMSEpc_disp_model = (sqrt(mean((disp_pred-test(:,6)).^2))/mean(test(:,6)))*100;

%----------------------
%OPTIMISATION
xMD = [[test(:,1) test(:,2) test(:,3)] mass_pred disp_pred];

%sanity check, Check1 and Check 2 should give last column and second to 
%last column of xMD respectively 
w1 = [0 1];
Check1 = truckMDws(xMD, w1);
w2 = [1 0];
Check2 = truckMDws(xMD, w2);

toc

