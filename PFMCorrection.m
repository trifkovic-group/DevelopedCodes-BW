clc
clear
FileName = 'Freshly cleaved 1st area ed';
A = load([FileName '.txt']);
figure(1)
imshow(A/max(max(A)))

% for i = pi/4/50:(pi/4)/50:pi/4-pi/4/50
%     for j = 1:256
%         Y(j,round(i/pi*4*50)) = A(j,ceil(tan(i)*j)); 
% 
%     end
% end
% 
% for i = 1:min(size(Y))
%     F = fft(Y(:,i));
%     F2 = abs(F);
%     fre(i) = max(find(F2 > mean(F2)*5));
% end

% for i = pi/4/45:(pi/4)/45:pi/4-pi/4/45
%     for j = 1:256
%         j2 = tan(i)*j;
%         Y(j,round(i/pi*4*45)) = A(ceil(j2),j);
%         
%     end
%     z(round(i/pi*4*45)) = 256+round(j2);
% end

% for i = 1:min(size(Y))
%     F = fft(Y(:,i));
%     F2 = abs(imag(F));
%     F3 = min(find(F2==max(F2)));
%     fre(i) = F3 * z(i)/256;
% end

%set up band stop filter
lowerf = 75;
upperf = 81;
[b,a] = butter(5,[lowerf*2/256 upperf*2/182],'stop');


% t = 20/360*2*pi;
% B = imrotate(A,14);
% C = B(66:247,66:247);

% for i = 1:182
%     X = C(:,i);
%     F = fft(C(:,i));
%     F2 = abs(F);
%     F3 = find(F2 > median(F2)*5);
%     Fre(i) = F3(2);
%     X3 = filtfilt(b,a,X);
%     OUT(:,i) = X3;
%     
% end

for i = 1:length(A);
    X = A(:,i);
    X3 = filtfilt(b,a,X);
    OUT(:,i) = X3;
end

% 
% for i = 255:-1:1
%     for j = 1:156
%         OUT(i,j) = A(i,ceil(j+.3*(255-i)));
%     end
% end
% figure(2)
% imshow(OUT/max(max(OUT)))

dlmwrite([FileName '_FT.txt'],OUT);