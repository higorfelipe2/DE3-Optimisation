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


%% OPTIMISATION
%% optimise just for mass 

w1 = [1 0];
x0 = [70,100,6];
sigma = 225000000; %material yield strength
A = [0 0 -1; -1 0 -1];
b = [4, -37.9];
Aeq = [];
beq = [];
lb = [37.9 129 4]; %lowest rW, +lA-1.1(wD), wA
ub = [70 177 10]; %highest rW, +lA-1.1(wD), lowest rW
options = optimoptions('fmincon','Display','iter','Algorithm','SQP');
[xoptM,foptM] = fmincon(@(x)truckMDws(x, beta, w1), x0, A, b, Aeq, beq, lb, ub, @(x)mycon(x,beta,sigma), options);
%min_mass = EvaluatePolyfitN(xoptM, beta(:,1));

%% optimise just for displacement

w2 = [0 1];
[xoptD,foptD] = fmincon(@(x)truckMDws(x, beta, w2), x0, A, b, Aeq, beq, lb, ub, @(x)mycon(x,beta,sigma), options);
%min_disp = EvaluatePolyfitN(xoptD, beta(:,3));
min_massD = EvaluatePolyfitN(xoptD, beta(:,1));

%Since any point along pareto line of lowest D to highest D is valid, choose the one which gives the lowest Stress
min_stressM = EvaluatePolyfitN(xoptM, beta(:,2));
min_stressD = EvaluatePolyfitN(xoptD, beta(:,2));

%find minimum disp at the selected minimum
min_dispM = EvaluatePolyfitN(xoptM, beta(:,3));

%% Optimize with a weighted sum

%n = 104;     % Number of Pareto points to produce
%wsweights = linspace(0,1,n); %.995 arbitrarily chosen to normalise max volume to max force. 
                                  %Better to use method of multiplying by standard dev, then divide by mean,
                                  %or divide by range of the data (max-min).
%xws = zeros(n,3); 
%fws = zeros(n,3); % 1st col V, 2nd col F, 3rd col weighted obj
%for i = 1:n
%    w = [wsweights(i), 1-wsweights(i)];
%    [xopt,fopt] = fmincon(@(x) truckMDws(x,beta,w),x0,A,b,Aeq,beq,lb,ub,@(x)mycon(x,beta,sigma),options);
%    xws(i,:) = xopt;
%    fws(i,1) = EvaluatePolyfitN(xws(i,:), beta(:,1)); %Change this to fws(i,1) = fopt and follow instructions on line 166 for graph shown on report instead
%    fws(i,3) = EvaluatePolyfitN(xws(i,:), beta(:,3)); 
%    fws(i,2) = EvaluatePolyfitN(xws(i,:), beta(:,2));
%end
%for i = 1:14
%fws(1,:)=[];
%end
%figure('Name','Pareto points when optimising for mass')
%plot(fws(:,3),fws(:,1),'b.')
%title('Pareto points between optimal mass and displacement')
%xlabel('D (mm)'); ylabel('M (kg)');

%Part below used to plot in different colours for report, uncomment and
%follow comment on line 154 to show different colours
%hold on
%wsweights2 = linspace(0,1,n); % Note that this only results in 2 points...
%xws2 = zeros(n,3); 
%fws2 = zeros(n,3); % 1st col V, 2nd col F, 3rd col weighted obj
%for i = 1:n
%    w = [wsweights2(i), 1-wsweights2(i)];
%    [xopt2,fopt2] = fmincon(@(x) truckMDws(x,beta,w),x0,A,b,Aeq,beq,lb,ub,@(x)mycon(x,beta,sigma),options);
%    xws2(i,:) = xopt2;
%    fws2(i,1) = fopt2;
%    fws2(i,3) = EvaluatePolyfitN(xws2(i,:), beta(:,1)); 
%    fws2(i,2) = EvaluatePolyfitN(xws2(i,:), beta(:,2));
%end
%for i = 1:6
%fws2(end,:)=[];
%end
%figure('Name','Pareto when optimising for displacement')
%plot(fws2(:,1),fws2(:,3),'r.')
%legend({'Optimising for mass','Optimising for displacement'},'Location','NorthEast')

toc