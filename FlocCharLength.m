clc
clear

for i =0:8000
    i
    %A = importdata(['SAV2/' num2str(i) '.csv']);   
    
   % B = cell2mat(A(3));
   % B = strsplit(B,',');
   % CL(i+1) = str2num(cell2mat(B(4)))/str2num(cell2mat(B(3)));
  %  VF(i+1) = str2num(cell2mat(B(4)))/(474.848*730.142*20.8004);
    
    A2 = importdata(['FD/' num2str(i) '.csv']);
    FD(i+1) = A2.data;
    
    A3 = importdata(['VF/' num2str(i) '.csv']);
    VF(i+1) = A3.data(1);
end
x = (1:8000)*(70/2001);
% figure(1)
% plot(x,abs(CL))
% xlabel('Time (Seconds)')
% ylabel('Characteristic length (um)')
figure(2)
plot(x,FD)
xlabel('Time (Seconds)')
ylabel('2D Fractal Dimension')
figure(3)
plot(x,VF)
xlabel('Time (Seconds)')
ylabel('Volume Fraction')