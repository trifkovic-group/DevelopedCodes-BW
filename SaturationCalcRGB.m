clc
clear

WCO = imread('EOR.UN.WATER.CRUDEOIL01.png');
%WCO = imread('EOR.UN.CRUDEOIL04.png');
WCO = double(WCO);

WB = WCO(:,:,3);
WR = WCO(:,:,1);
WG = WCO(:,:,2);

h = ones(100)/100^2;
WBavg = imfilter(WB,h);
WB = WB - WBavg;

WB = WB(750:1925,650:2300);
WG = WG(750:1925,650:2300);
WR = WR(750:1925,650:2300);

S1 = size(WCO);
S2 = size(WB);

ci = [round(S1(1)/2) round(S1(2)/2) round(S1(1)/2.5)];

[xx,yy] = ndgrid((1:S1(1))-ci(1),(1:S1(2))-ci(2));
mask = (xx.^2 + yy.^2)<ci(3)^2;

figure(1)
imshow(mask)
figure(2)
imshow(WCO/255)
figure(3)
imshow(WCO/255.*mask)

wat = zeros(size(WB));

wat(WR < 125) = 1;
%wat(WG < 50) = 1;

oil = zeros(size(WB));
oil(WB<=0) = 1;

oil = oil - wat;
oil(oil<0) = 0;

wl = sum(sum(wat));
ol = sum(sum(oil));

sat = ol/(ol+wl);


figure(1)
imshow(WCO(750:1925,650:2300,:)/255)
figure(2)
imshow(oil)
figure(3)
imshow(wat)



A2 = S2(1)*S2(2);

SATMeas = A2 - sum(sum(WB));


