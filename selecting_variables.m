clear all
clc

%possible values
hT = 0.050:0.002:0.072
lT = 0.09:0.01:0.2
rT = 0.006:0.001:0.015

no_inp = 3
pre_final=combvec(rT,lT,hT)';
final=zeros(size(pre_final));
for i=1:no_inp
    final(:,i)=pre_final(:,no_inp-i+1);
end
final

%select 16 random permutations of the 
n = final(randperm((length(hT)*length(lT)*length(rT)),16),:)