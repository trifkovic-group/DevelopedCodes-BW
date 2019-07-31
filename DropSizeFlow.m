clc
clear

% SizeData = [];
% for j = 1:9
%     j
  %  InitialImage = double(imread(['Morwet Hydrophobic.lif_middle narrow_Crop001_t' num2str(j) '_ch01.tif']))/255;
  InitialImage = double(imread('Before flow.lif_Image005_ch00.tif'));
  % A = imread('2D.lif_After glass tube 3_ch02.tif');
  % InitialImage = double(A(3:416,3:416,2));
    FilteredImage = imfilter(InitialImage,ones(7)/7^2,'symmetric');
    for k = 1:2
        FilteredImage = imfilter(FilteredImage,ones(7)/7^2,'symmetric');
    end
    BlackWhite = imbinarize(FilteredImage/255,graythresh(FilteredImage/255));
    
    i = 1;
    DistMap = bwdist(1-BlackWhite);
    IsolatedCircles = zeros(size(InitialImage));
    
    
    while max(max(DistMap > 8))
        DistMap = bwdist(1-BlackWhite);
        LargestDropCenter = find(DistMap == max(max(DistMap)),1);
        DropSize(i) = DistMap(LargestDropCenter);
        DropCenter = zeros(size(InitialImage));
        DropCenter(LargestDropCenter) = 1;
        
        SingleDropDistMap = bwdist(DropCenter);
        BlackWhite(SingleDropDistMap<DropSize(i)) = 0;
        IsolatedCircles(SingleDropDistMap<DropSize(i)*1.04) = 1;
        i = i+1;
    end
%     SizeData = [SizeData DropSize];
% end