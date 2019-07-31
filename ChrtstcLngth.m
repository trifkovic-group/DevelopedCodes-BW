clc
clear
start = 30;
finish = 443;

for i = start:finish
    A = importdata(['S14Data/area' num2str(i) '.csv']);
    Ar(i+1) = A.data;
    
    V = importdata(['S14Data/volume' num2str(i) '.csv']);
    Vo(i+1) = V.data(2);
    
    CL(i-start+1) = Vo(i+1)/Ar(i+1);
end

for i = start:finish
    A = importdata(['S14Hist/MCurv' num2str(i) '.csv']);
    
    B = str2double(A.textdata(2:257,1));
    C = str2double(A.textdata(2:257,2));
    
    D(i-start+1) = sum(B.*C)/sum(C);

end

% plot(D(60:end))
% xlabel('time step')
% ylabel('average mean curvature')
x = (start:finish)*(70/finish);
figure(1)
plot(x,CL)
xlabel('Time (minutes)')
ylabel('Characteristic Length (um)')
figure(2)
plot(x,D)
xlabel('Time (minutes)')
ylabel('Average Mean Curvature')
