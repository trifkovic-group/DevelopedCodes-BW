clc
clear

n = 199;
t = 7;
S1 = 'Oil-Water-10/';
S4 = '.tiff';

for i = 0:t
    
    for j = 0:n
        
        S2 = [num2str(i) '/F'];
        T2 = [num2str(i) '/T'];
        S3 = num2str(j);
        
        if j<10
            S=[S1,S2,'00',S3,S4];
            T=[S1,T2,'00',S3,S4];
        elseif j<100
            S=[S1,S2,'0',S3,S4];
            T=[S1,T2,'0',S3,S4];
        else
            S=[S1,S2,S3,S4];
            T=[S1,T2,S3,S4];
        end
        
        ThisSliceF(:,:,j+1) = imread(S);
        ThisSliceT(:,:,j+1) = imread(T);
        bot = ThisSliceT(1,:,j+1);
        top = ThisSliceT(end,:,j+1);
        
        topc = mean(find(top==1));
        botc = mean(find(bot==1));
        
        L = sqrt(abs(topc-botc)^2+512^2);
        th(i+1,j+1) = sum(sum(ThisSliceT(:,:,j+1)))/L;
        
    end
    
    
    Intensity(i+1) = sum(sum(sum(ThisSliceF(ThisSliceT>0))));
end

plot(0:9.5/7:9.5,Intensity)
xlabel('Time (minutes)')
ylabel('Total Intensity at Interface')
title('Air-Water 10 minutes')

% plot(0:9.75/7:9.75,Intensity)
% xlabel('Time (minutes)')
% ylabel('Total Intensity at Interface')
% title('Oil-Water 10 minutes')

% plot(0:29.35/21:29.35,Intensity)
% xlabel('Time (minutes)')
% ylabel('Total Intensity at Interface')
% title('Oil-Water 30 minutes')

% plot(0:8/10:8,Intensity)
% xlabel('Time (minutes)')
% ylabel('Total Intensity at Interface')
% title('CNC Pure-1')

% plot(0:8/3:8,Intensity)
% xlabel('Time (minutes)')
% ylabel('Total Intensity at Interface')
% title('NaOH First 10 minutes')
