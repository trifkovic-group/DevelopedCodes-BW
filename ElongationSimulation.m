% clc
% clear
% 
% DropVelocity = 10;
% PixelsPerSecond = 1000;
% 
% EmptyM = zeros(1000);
% InitLocation = [500 500];
% CenterPoint = zeros(size(EmptyM));
% for i = 1:45
%     CenterPoint(InitLocation(1)+i*DropVelocity,InitLocation(2)) = 1;
%     DM = bwdist(CenterPoint);
%     EmptyM(DM<10) = 1;
%     imshow(EmptyM)
%     pause(0.2)
%     EmptyM = zeros(1000);
%     CenterPoint = zeros(1000);
% end 

clc
clear

for a = 0:pi/20:2*pi

DropVelocity = .004;
DropAngle = a;
vx = cos(DropAngle)*DropVelocity;
vy = sin(DropAngle)*DropVelocity;

PixelsPerSecond = 1000;

EmptyM = zeros(100);
EmptyM2 = zeros(100);
InitLocation = [50 50];
CenterPoint = zeros(size(EmptyM));
for i = 1:100*100

    CenterPoint(round(InitLocation(1)-i*vx),round(InitLocation(2)-i*vy)) = 1;
    DM = bwdist(CenterPoint);
    EmptyM(DM<10) = 1;
    EmptyM2(i) = EmptyM(i);
    EmptyM = zeros(100);
    CenterPoint = zeros(100);
end 
    
imshow(EmptyM2)

stats = regionprops(EmptyM2,'MajorAxisLength','MinorAxisLength');

ai = round(a*20/pi+1)
imwrite(EmptyM2,[num2str(ai) '.tif'])
ang(ai) = a;
elongation(ai) = stats.MajorAxisLength/stats.MinorAxisLength;

end