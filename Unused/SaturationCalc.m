clc
clear

WCO = imread('EOR.UN.WATER.CRUDEOIL01.png');
CO = imread('EOR.UN.CrudeOIL04.png');
CO = double(CO);
WCO = double(WCO);

WB = WCO(:,:,3);
COB = CO(:,:,3);

h = ones(100)/100^2;
WBavg = imfilter(WB,h);
COBavg = imfilter(COB,h);

COB = COB - COBavg;
WB = WB - WBavg;

COB2 = COB(750:1925,650:2300);
WB2 = WB(750:1925,650:2300);

COB2(COB2 > 0) = 1;
COB2(COB2 < -70) = 1;
COB2(COB2 < 0) = 0;
WB2(WB2 > 0) = 1;
WB2(WB2 < -70) = 1;
WB2(WB2 < 0) = 0;

figure(1)
imshow(COB2)
figure(2)
imshow(WB2)
figure(3)
imshow(WCO(750:1925,650:2300,3)/255)

S = size(COB2);
S2 = size(WB2);
A = S(1)*S(2);
A2 = S2(1)*S2(2);
SATBase = A - sum(sum(COB2));
SATMeas = A2 - sum(sum(WB2));

OUT = SATMeas/SATBase

