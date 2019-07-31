clc
clear

%Name of data set before index and file type
S1='S';
S3='.tiff';

Nimages = 10; %Total number of images in a data set
pixels = size(imread([S1,'00',S3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%S variables are the names of the data, updated each loop to load all files
C = zeros(30,3,1053);
for i = 0:1

I = imread(['Slice1/' num2str(i) '.tiff']);
I = imfilter(I,ones(5)/25);

% figure(1)
% imshow(I)

se = strel('disk', 5);
Io = imopen(I, se);

% figure(2)
% imshow(Io)

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);

% figure(3)
% imshow(Ie)

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

% figure(4)
% imshow(Iobrcbr)

fgm = imregionalmax(Iobrcbr);
figure(i+1)
imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

A = bwconncomp(fgm(:,:,:));
B = regionprops('table',A,'centroid','area');
C(1:height(B),1:3,i+1) = [B.Area,B.Centroid];

end

