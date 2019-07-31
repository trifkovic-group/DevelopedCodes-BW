clc
clear

OrigIm = imread('Project_aerofel-line-average-8.tif');
se = strel('disk',2);
se2 = strel('disk',4);

BinIm = imbinarize(OrigIm);
BinAO = bwareaopen(BinIm,5);
IF = imfill(BinAO,'holes');
holes = IF & ~BinAO;
bigholes = bwareaopen(holes, 20);
smallholes = holes & ~bigholes;
BinAC = BinAO | smallholes;
BinACC = ~BinAC;
BinC = imopen(BinACC,se);
BinO = imopen(BinC,se2);
BinSkel = bwskel(BinO);
BinSkelRed = zeros([size(BinSkel) 3]);
BinSkelRed(:,:,1) = BinSkel;
OrigImRGB = zeros([size(OrigIm) 3]);
OrigImRGB(:,:,1) = OrigIm;
OrigImRGB(:,:,2) = OrigIm;
OrigImRGB(:,:,3) = OrigIm;
BinCRGB = zeros([size(OrigIm) 3]);
BinCRGB(:,:,1) = BinC;
BinCRGB(:,:,2) = BinC;
BinCRGB(:,:,3) = BinC;

figure(1)
imshow(OrigImRGB/255 + BinSkelRed)