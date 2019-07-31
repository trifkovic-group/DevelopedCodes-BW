clc
clear

InitialImage = double(imread('DropSize.tif'))/255;

FilteredImage = imfilter(InitialImage,ones(3)/3^2,'symmetric');
BlackWhite = imbinarize(FilteredImage,'adaptive');

i = 1;
DistMap = bwdist(1-BlackWhite);
IsolatedCircles = zeros(size(InitialImage));
while max(max(DistMap > 2))
    DistMap = bwdist(1-BlackWhite);
    LargestDropCenter = find(DistMap == max(max(DistMap)),1);
    DropSize(i) = DistMap(LargestDropCenter);
    DropCenter = zeros(size(InitialImage));
    DropCenter(LargestDropCenter) = 1;
    
    SingleDropDistMap = bwdist(DropCenter);
    BlackWhite(SingleDropDistMap<DropSize(i)) = 0;
    IsolatedCircles(SingleDropDistMap<DropSize(i)) = 1;
    i = i+1;
end