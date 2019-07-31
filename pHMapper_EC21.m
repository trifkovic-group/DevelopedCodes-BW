clc
clear

PHCh4 = [8.19 7 6.69 6.35 5.77 5.41 5.02 4.61 4.2 3.8 3.4 3.01 2.6 2.2 1.8 1.4 1.14 1.01 0.77];
PHCh2_4 = [5.41 5.02 4.61 4.2 3.8 3.4 3.01 2.6 2.2 1.8 1.4 1.14 1.01 0.77];

Ch4 = [1.35 1.45 1.69 2.10 2.96 3.67 4.5 5.47 7.37 9.33 10.24 11.04 12.16 13.93 14.96 15.78 15.9 15.93 15.79];
Ch2_4 = [3.99 4.02 4.02 3.93 3.74 3.37 2.72 1.72 0.75 0.23 0.073 0.045 0.04 0.034];

%Rcurve = [3.13 3.03 2.86 2.57 2.2 1.72 1.36 1.02 0.83 0.74];
%ch3 = [2.05 2.64 3.5 4.17 5 5.73 6.56 7.23 7.82 8.45 9.1 9.71 10.73 11.91 12.91 13.57 13.78 13.88];

frames = 750;
s = [512 512 frames];
Frame2 = zeros(s);
Frame4 = zeros(s);
PHinit = zeros(s(1),s(2));
PHOut = zeros(s);
fname = 'EC21 October 20 2018 Al anode lyso 1in50 ipH 7.1.lif_2 mA-cm2_Crop001_t';


p1 = -8.358e-6;
p2 = 0.0005056;
p3 = -0.01246;
p4 = 0.1613;
p5 = -1.18;
p6 = 4.881;
p7 = -10.95;
p8 = 16.01;

f1 = @(x) p1.*x.^7 + p2.*x.^6 + p3.*x.^5 + p4.*x.^4 + p5.*x.^3 + p6.*x.^2 + p7.*x + p8;

r1 = 0.04885;
r2 = -0.705;
r3 = 4.126;
r4 = -12.53;
r5 = 20.92;
r6 = -18.73;
r7 = 8.8387;
r8 = 0.7074;


f2 = @(x) r1.*x.^7 + r2.*x.^6 + r3.*x.^5 + r4.*x.^4 + r5.*x.^3 + r6.*x.^2 + r7.*x + r8;
se = strel('disk',25);

for i = 10:50
    A(:,:,i-9) = imread(['EC21 October 20 2018 Al anode lyso 1in50 ipH 7.1.lif_2 mA-cm2_Crop001_t0' num2str(i) '_ch01.tif']);
end

A2 = mean(A,3);
A3 = imfilter(double(A2),ones(150)/150^2,'symmetric');
A4 = A3./(max(A3)*.7);
A4(A4>1) = 1;

for i = 1:frames
    if i < 10
        Frame2(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
    elseif i < 100
        Frame2(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
    else
        Frame2(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
    end
    
    Filt2 = imfilter(Frame2(:,:,i),ones(32)/32^2,'symmetric');
    Filt4 = imfilter(Frame4(:,:,i),ones(32)/32^2,'symmetric');
    
    Filt4(Filt4<1.35) = 1.35;
    Filt4 = Filt4./A4;
    
    NL2 = max(max(Filt2(:,500:end)));
    NL4 = max(max(Filt4(:,500:end)));
    
    %Filt2(Filt2 < NL2) = 0;
    %Filt4(Filt4 < NL4) = 0;
    %Filt6(Filt6 == 0) = NL6;
    
    R = Filt2./Filt4;
    
    PH4 = f1(Filt4);
    PHR = f2(R);
    
    PH4F = imfilter(PH4,ones(32)/32^2,'symmetric');
    %F3 = ones(1,1,5)/5;
    
%     PH = PHR;
%     PH(PHR<2) = PHR1(PHR<2);
%     PH(PHR>4.5) = PHR1(PHR>4.5);
%     
%     PHFill = PHR1;
%     PHFill(PHFill < 6) = 0;
%     
%     PHR1 = imfilter(PHR1,ones(32)/32^2,'symmetric');
%     
%     PHBW = zeros(s(1),s(2));
%     PHBW(PHFill > 0) = 1;
%     
%     PHBW = bwareaopen(PHBW,300);
%     
%     PHFill = PHR1;
%     PHFill(PHFill < 6) = 0;
     
%     se2 = strel('line',200,90);
%     %PHOpen = imopen(PHFill,se2);

 
     PHOut(:,:,i) = PH4F;
%     
    

end

sc = ones(size(PHOut));

for i = 1:120
    sc(:,i+376,:) = sc(:,i+376,:) * (1-i/120/3);
end
PHOut = PHOut.*sc;

PHFt = medfilt3(PHOut,[1 1 5],'symmetric');
PHOpen = imopen(PHFt,se);
PHOpen(PHOpen<0.77) = 0.77;
PHOpen(PHOpen>8.19) = 8.19;
PHOpen(1,1,:) = 0;
PHOpen(end,end,:) = 8.19;

X = [440 512 512 440];
Y = [1 1 512 512];


for i = 1:frames
    [C,h] = contourf(PHOpen(:,:,i));
    clabel(C,h)
    axis off
    colorbar
    caxis([0 9])
    title(['t =' num2str(i*.174) '(s)'])
    patch(X,Y,[0.5 0.5 0.5])
    saveas(gcf,[num2str(i) '.tif']);
    dlmwrite([num2str(i) '.txt'],PHOpen(:,:,i))
end
