clc
clear

start = 2040;
finish = 2040;
% ind = [1775 2779 3454 4173 4435 4696 4959 5221 5482 5744 6005 6245 6528];
% for i = 1:length(ind)
%    i
%     A = imread(['FD/' num2str(ind(i)) '.tif']);
%     [FD1(i-start+1),B,C] = BoxCountfracDim(A);
%     
%     A2 = importdata(['FD/' num2str(ind(i)) '.csv']);
%     FDA1(i-start+1) = A2.data;
%     
%     A2 = importdata(['VFFill/' num2str(ind(i)) '.csv']);
%     VFFill1(i-start+1) = A2.data(1);
%     
%     A2 = importdata(['VFPore/' num2str(ind(i)) '.csv']);
%     VFPore1(i-start+1) = A2.data(1);
%     
%     A2 = importdata(['VFBit/' num2str(ind(i)) '.csv']);
%     if isstruct(A2)
%         VFBit1(i-start+1) = A2.data(1);
%     else
%         VFBit1(i-start+1) = 0;
%     end
% end

for i = start:finish
    i
    A = imread(['CFD/' num2str(i) '.tif']);
    %A = A(1:300,513:1024);
    [FD(i-start+1),B,C] = BoxCountfracDim(A);
    
%     A2 = importdata(['FD/' num2str(i) '.csv']);
%     FDA(i-start+1) = A2.data;
%     
%     A2 = importdata(['VFFill/' num2str(i) '.csv']);
%     if isstruct(A2)
%         VFFill(i-start+1) = A2.data(1);
%     else
%         VFFill(i-start+1) = 0;
%     end
%     
%     A2 = importdata(['VFPore/' num2str(i) '.csv']);
%     if isstruct(A2)
%         VFPore(i-start+1) = A2.data(1);
%     else
%         VFPore(i-start+1) = 0;
%     end
%     
%     A2 = importdata(['VFBit/' num2str(i) '.csv']);
%     if isstruct(A2)
%         VFBit(i-start+1) = A2.data(1);
%     else
%         VFBit(i-start+1) = 0;
%     end
end

% X = (1:length(FD))/(length(FD)/145.6);
% figure(1)
% plot(X,FD)
% xlabel('Time (s)')
% ylabel('FD')
% title('FD')
% figure(2)
% plot(X,1 - VFPore./VFFill)
% title('Porosity')
% ylabel('Porosity')
% xlabel('Time (s)')
% figure(3)
% plot(X,VFBit./VFPore)
% title('Bitument Content')
% xlabel('Time (s)')
% ylabel('Bitument Content')

% FDAv = [];
% VFBAv = [];
% for i =1:19:6523-19
%     FDAv(length(FDAv)+1) = mean(FD(i:i+19));
%     VFBAv(length(VFBAv)+1) = mean(VFBit(i:i+19));
% end


% plot(abs(F(2:3261)))
% plot(X,FD)
% hist(FD,100)