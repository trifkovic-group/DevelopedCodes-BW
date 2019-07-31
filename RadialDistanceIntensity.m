clc
clear

A2 = importdata('data.xlsx');
A2 = A2(2:end,2:end);

figure(1)
xcent = 283;
ycent = 283;
P = zeros(size(A2));
P(xcent,ycent) = 1;
DM = bwdist(P);

%A2 = medfilt2(A2,[10,10]);
imagesc(A2)
%viscircles([285 285], 248,'Color','r');

stepsize = 6;

for i = stepsize:stepsize:400
RadAvg(i/stepsize) = mean(A2(DM<i));
DM(DM<i) =  1000;
viscircles([xcent ycent], i,'Color','r');
end

figure(2)
loglog(RadAvg)
