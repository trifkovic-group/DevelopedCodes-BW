clc
clear

yPH = [6.1 5.83 5.51 5.21 4.85 4.51 4.21 3.91 3.62 3.29 3.02 2.68 2.35 1.96 1.51 1.12 0.94 0.86];
yPH2 = [4.85 4.51 4.21 3.91 3.62 3.29 3.02 2.68 2.35 1.96];

Rcurve = [3.13 3.03 2.86 2.57 2.2 1.72 1.36 1.02 0.83 0.74];
ch3 = [2.05 2.64 3.5 4.17 5 5.73 6.56 7.23 7.82 8.45 9.1 9.71 10.73 11.91 12.91 13.57 13.78 13.88];

frames = 1000;
s = [512 512 frames];
Frame3 = zeros(s);
Filt3 = zeros(s);
fname = 'EC 11 Lyso 1in50 initial pH 7.25 July 7-2018.lif_4 mA-cm2_Crop001_t';

p1 = -0.4357;
p2 = 7.016;

f1 = @(x) p1*x + p2;

r1 = -0.2524;
r2 = 2.599;
r3 = -7.577;
r4 = 7.521;

f2 = @(x) r1*x.^3 + r2*x.^2 + r3*x + r4;

for i = 1:frames
    if i < 10
        Frame2(:,:,i) = double(imread([fname '000' num2str(i) '_ch00.tif']));
        Frame3(:,:,i) = double(imread([fname '000' num2str(i) '_ch01.tif']));
        Frame5(:,:,i) = double(imread([fname '000' num2str(i) '_ch02.tif']));
        Frame6(:,:,i) = double(imread([fname '000' num2str(i) '_ch03.tif']));
    elseif i < 100
        Frame2(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        Frame3(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
        Frame5(:,:,i) = double(imread([fname '00' num2str(i) '_ch02.tif']));
        Frame6(:,:,i) = double(imread([fname '00' num2str(i) '_ch03.tif']));
    elseif i < 1000
        Frame2(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        Frame3(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
        Frame5(:,:,i) = double(imread([fname '0' num2str(i) '_ch02.tif']));
        Frame6(:,:,i) = double(imread([fname '0' num2str(i) '_ch03.tif']));
    else
        Frame2(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        Frame3(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
        Frame5(:,:,i) = double(imread([fname num2str(i) '_ch02.tif']));
        Frame6(:,:,i) = double(imread([fname num2str(i) '_ch03.tif']));
    end
    
    Filt3(:,:,i) = imfilter(Frame3(:,:,i),ones(32)/32^2,'symmetric');    

end

FrameSum = Frame2+Frame3+Frame5+Frame6;
SumFilt = FrameSum;
for i = 1:1
    SumFilt = imfilter(SumFilt,ones(16)/16^2,'symmetric');
end


%Filt3 = imfilter(Filt3,ones(1,1,50)/50,'symmetric');
PHR1 = f1(Filt3);

PHR1 = imfilter(PHR1,ones(32)/32^2,'symmetric');
PHR1 = imfilter(PHR1,ones(1,1,50)/50,'symmetric');
% for i = s(3)
%     min(min(PHR1(:,:,i))
% end
PHR1(1,1,:) = 0;

BinFilt = ones(s);
BinFilt(SumFilt < 10) = 0;
se = strel('disk',15);
%BinFilt = imerode(BinFilt,se);
BinFilt(:,1:300,:) = 1;
PHR1 = PHR1.*BinFilt;
PHR1(end,end,:) = 9;

for i = 1:frames
    [C,h] = contourf(PHR1(:,:,i));
    clabel(C,h)
    axis off
    colorbar
    caxis([0 9])
    title(['t =' num2str(i*(165/1855)) '(s)'])
    %patch(X,Y,[0.5 0.5 0.5])
    saveas(gcf,[num2str(i) '.tif']);
end