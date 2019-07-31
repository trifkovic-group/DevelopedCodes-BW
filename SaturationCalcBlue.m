clc
clear

WCO = imread('EOR.UN.WATER.CRUDEOIL01.png');
CO = imread('EOR.UN.CrudeOIL04.png');
CO = double(CO);
WCO = double(WCO);

figure(1)
[A1,B1] = imhist(WCO(:,:,3)/255);
[C1,D1,w1] = findpeaks(A1,'MinPeakWidth',10)
figure(2)
[A2,B2] = imhist(CO(:,:,3)/255);
[C2,D2,w2] = findpeaks(A2,'MinPeakWidth',10)

X = WCO(:,:,3);
X(X<(D1+2*w1)) = 0;

X2 = CO(:,:,3);
X2(X2<(D2+2*w2)) = 0;

figure(1)
imshow(X/255)
figure(2)
imshow(X2/255)

s1 = X(750:1925,650:2300);
s2 = X2(750:1925,650:2300);
s1(s1>0) = 1;
s2(s2>0) = 1;

figure(1)
imshow(s1)
figure(2)
imshow(s2)