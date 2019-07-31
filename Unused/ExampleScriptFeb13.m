clc
clear

for i = 0:24
   A = importdata(['volume' num2str(i) '.csv']);   
   VF(i+1) = A.data(1);
end

plot(VF)