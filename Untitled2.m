clc
clear

InitialImage = double(imread('3+4 emulsions.lif_3+4_1wt%_emulsion_11.jpg'))/255;
%InitialImage = InitialImage(:,:,2); To isolate green channel in colored
%images
FilteredImage = imfilter(InitialImage,ones(5)/5^2,'symmetric'); %Change the 5 for larger filter window (more blurry, higher number)
for j = 1:3 %May change second number for filter iterations (More blurry, higher number)
    FilteredImage = imfilter(FilteredImage,ones(5)/5^2,'symmetric');
end
BlackWhite = imbinarize(FilteredImage,0.1);
%BlackWhite = imbinarize(FilteredImage,'adaptive');
%BlackWhite = imbinarize(FilteredImage)

i = 1;
DistMap = bwdist(1-BlackWhite);
IsolatedCircles = zeros(size(InitialImage));
while max(max(DistMap > 30)) %Change number for minimum dorp size
    DistMap = bwdist(1-BlackWhite);
    LargestDropCenter = find(DistMap == max(max(DistMap)),1);
    DropSize(i) = DistMap(LargestDropCenter);
    DropCenter = zeros(size(InitialImage));
    DropCenter(LargestDropCenter) = 1;
    
    SingleDropDistMap = bwdist(DropCenter);
    BlackWhite(SingleDropDistMap<DropSize(i)) = 0;
    IsolatedCircles(SingleDropDistMap<DropSize(i)) = 1;
    i = i+1;
    imshow(BlackWhite) %Remove to speed up
end


%DropSize = DropSize'*0.1812*2;
%histogram(DropSize,20)