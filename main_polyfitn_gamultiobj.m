%Multivariate polynomial regression to find objective functions
clc
clear all
tic

%% Data formatting

%extract and format data, remove unnecessary columns and sort
data = readtable('Dataset.xlsx');
data.fatigue = []; %remove fatigue data, not gonna be used
raw_data = sortrows(data,'displacement_mm_','ascend');
data = table2array(raw_data);
data(:,1) = data(:,1)*sin(45); %measured height is straight up to the deck (truck is at an angle)

%separate test data
split = round(length(data)*0.2);
data(end-split:end,:) = [];
test = data(end-split:end,:);

%% Variables

%independant variables
hT = data(:,1); 
lT = data(:,2);
rT = data(:,3);
vars = [hT lT rT];

%dependant variables
mass = data(:,4);
stress = data(:,5);
disp = data(:,6);

%% Preliminary checks

% Check for multicollinearity (values below 5 show little to no
% multicollinearity)
% Standardisation is required when there are high levels of
% multicollinearity
% https://statisticsbyjim.com/regression/standardize-variables-regression/
% The low vif values shows a low level of
% multicollinearity between independant variables (as expected), so standardisation of
% the variables isn't required.
V = vif([hT lT rT]);

%----------------------
%cftool to check linearity showed nonlinear with dimishing returns after
%second order apporximation
cftool

%% BUILD METAMODEL

modelterms = 'constant, hT, hT^2, lT, lT^2, rT, rT^2';

%% perform multivariate regression to find objective function for mass

Y = data(:,4);
x = data(:,1:end-3);
betaM = polyfitn(x, Y, modelterms);
%Eavg = E/length(Y); %average errors

%% perform multivariate regression to find objective function for stress

Y2 = data(:,5);
betaS = polyfitn(x, Y2, modelterms);

%% perform multivariate regression to find objective function for displacement

Y3 = data(:,6);
betaD = polyfitn(x, Y3, modelterms);

beta = [betaM.Coefficients' betaS.Coefficients' betaD.Coefficients'];

%% Model predictions using regression functions 

mass_pred = EvaluatePolyfitN([test(:,1) test(:,2) test(:,3)], beta(:,1));
stress_pred = EvaluatePolyfitN([test(:,1) test(:,2) test(:,3)], beta(:,2));
disp_pred = EvaluatePolyfitN([test(:,1) test(:,2) test(:,3)], beta(:,3));

%% model accuracy checks

means = [mean(mass_pred) mean(test(:,4));
         mean(stress_pred) mean(test(:,5));
         mean(disp_pred) mean(test(:,6))];

r2_mass_model = betaM.R2;
r2_stress_model = betaS.R2;
r2_disp_model = betaD.R2;

RMSEpc_mass_model = betaM.RMSEpc;
RMSEpc_stress_model = betaS.RMSEpc;
RMSEpc_disp_model = betaD.RMSEpc;


%% OPTIMISATION - Check pareto front figure for results

w1 = [1 0];
sigma = 225000000; %material yield strength
A = [0 0 -1; -1 0 -1];
b = [4, -37.9];
Aeq = [];
beq = [];
lb = [37.9 129 4]; %lowest rW, +lA-1.1(wD), wA
ub = [70 177 10]; %highest rW, +lA-1.1(wD), lowest rW
options = optimoptions('fmincon','Display','iter','Algorithm','SQP');

fitnessfcn = @(xp)[EvaluatePolyfitN_mass(xp),EvaluatePolyfitN_disp(xp)];

xp = gamultiobj(fitnessfcn,3,A,b,Aeq,beq,lb,ub,@(xp)mycon(xp,beta,sigma));
plot(EvaluatePolyfitN_mass(xp),EvaluatePolyfitN_disp(xp),'r*')
xlabel('M(hT,lT,rT) (kg)')
ylabel('D(hT,lT,rT) (mm)')
title('Pareto Front - Tradeoff Between Minimum Mass and Deflection ')
legend('Pareto front')
toc