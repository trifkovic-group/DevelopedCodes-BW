clc
clear

%Name of droplet data set
S1='Below MMP Figure ';
S3='.jpg';

ImageStart = 1;
Nimages = 5; %Total number of images in a data set
% pixels = size(imread([S1,'000',S3])); % Read dimensions of images
pixels = size(imread('At MMP Figure 6.jpg'));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    S2=int2str(slice);
    S=[S1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    fullFileName_d = fullfile('Below', S);
    thisSlice_d = imread(fullFileName_d);
    thisSlice_d = imfilter(thisSlice_d,ones(5)/25);
    %thisSlice_d = imbinarize(thisSlice_d,.8);
    A(:,:,slice-(ImageStart-1)) = thisSlice_d;
    level = graythresh(thisSlice_d);
    level = 0.82;
    BW = imbinarize(thisSlice_d,level);
    imshow(BW)
    CC = bwconncomp(BW);
    D = regionprops(CC,'Area','Centroid','MinorAxisLength');
    D = D( [D.Area] > 1000);
    D = D( [D.MinorAxisLength] > 100);
    if isempty(D) == 0
        E(slice) = {D};
    end
    
    
end

if exist('E') == 0
    disp('No bubbles found')
    return
else
    E
end
% level = graythresh(thisSlice_d);
% level = 0.82;
% BW = imbinarize(thisSlice_d,level);
% imshow(BW)