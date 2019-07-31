clc
clear

for i = 1:255
   i
   A = importdata(['VAF/' num2str(i) '.csv']);   
    
   B = cell2mat(A(3));
   B = strsplit(B,',');
   V(i) = str2num(cell2mat(B(4)));
   CL(i) = str2num(cell2mat(B(4)))/str2num(cell2mat(B(3))); 
   
   A2 = importdata(['SAV/' num2str(i) '.csv']);   
    
   B2 = cell2mat(A2(3));
   B2 = strsplit(B2,',');
   V2(i) = str2num(cell2mat(B2(4)));
   AR(i) = str2num(cell2mat(B2(3)));
    
   A3 = importdata(['VF/' num2str(i) '.csv']);
   VF(i) = A3.data(1);
end

figure(1)
plot(VF./AR)
ylabel('Characteristic length (um)')
