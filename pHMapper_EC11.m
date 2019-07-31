clc
clear

yPH = [6.1 5.83 5.51 5.21 4.85 4.51 4.21 3.91 3.62 3.29 3.02 2.68 2.35 1.96 1.51 1.12 0.94 0.86];
yPH2 = [4.85 4.51 4.21 3.91 3.62 3.29 3.02 2.68 2.35 1.96];

Rcurve = [3.13 3.03 2.86 2.57 2.2 1.72 1.36 1.02 0.83 0.74];
ch3 = [2.05 2.64 3.5 4.17 5 5.73 6.56 7.23 7.82 8.45 9.1 9.71 10.73 11.91 12.91 13.57 13.78 13.88];

frames = 100;
s = [512 512 frames];
Frame3 = zeros(s);
Frame6 = zeros(s);
PHinit = zeros(s(1),s(2));
PHOut = zeros(s);
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
        Frame3(:,:,i) = double(imread([fname '000' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '000' num2str(i) '_ch01.tif']));
    elseif i < 100
        Frame3(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
    elseif i < 1000
        Frame3(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
    else
        Frame3(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
    end
    
    Filt3 = imfilter(Frame3(:,:,i),ones(32)/32^2,'symmetric');
    Filt6 = imfilter(Frame6(:,:,i),ones(32)/32^2,'symmetric');
    
    NL3 = max(max(Filt3(:,500:end)));
    NL6 = max(max(Filt6(:,500:end)));
    
    Filt3(Filt3 < NL3) = 0;
    Filt6(Filt6 < NL6) = 0;
    %Filt6(Filt6 == 0) = NL6;
    
    R = Filt3./Filt6;
    
    PHR1 = f1(Filt3);
    PHR2 = f2(R);
    
    PH = PHR2;
    PH(PHR2<2) = PHR1(PHR2<2);
    PH(PHR2>4.5) = PHR1(PHR2>4.5);
    
    PHFill = PHR1;
    PHFill(PHFill < 6) = 0;
    
    PHR1 = imfilter(PHR1,ones(32)/32^2,'symmetric');
    
    PHBW = zeros(s(1),s(2));
    PHBW(PHFill > 0) = 1;
    
    PHBW = bwareaopen(PHBW,300);
    
    PHFill = PHR1;
    PHFill(PHFill < 6) = 0;
    se = strel('disk',25);
    se2 = strel('line',200,90);
    %PHOpen = imopen(PHFill,se2);
    PHOpen = imopen(PHFill,se);
    
    PHOut(:,:,i) = PHR1 - PHOpen;
    
    

end

PHOut(1,1,:) = 0;

for i = 1:frames
    [C,h] = contourf(PHOut(:,:,i));
    clabel(C,h)
    axis off
    colorbar
    caxis([0 9])
    title(['t =' num2str(i*(165/1855)) '(s)'])
    %patch(X,Y,[0.5 0.5 0.5])
    saveas(gcf,[num2str(i) '.tif']);
end