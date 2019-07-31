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
    
end

% implay(A/255)
x1 = thisSlice_d(3:700,3);
x2 = thisSlice_d(3:700,1050);
runavg = ones(1,5)/5;
z1 = filter(runavg,1,double(x1));
z2 = filter(runavg,1,double(x2));
figure(1)
[P1,L1] = findpeaks(z1(5:end),'MinPeakProminence',10)
findpeaks(z1(5:end),'MinPeakProminence',10)
figure(2)
[P2,L2] = findpeaks(z2(5:end),'MinPeakProminence',13)
findpeaks(z2(5:end),'MinPeakProminence',13)
figure(3)
imshow(thisSlice_d)

start = floor(mean(L1))+4;
finish = floor(mean(L2))+4;

for i = 3:1050
    y(i-2) = thisSlice_d(round(start+i*(finish-start)/(1050-3)),i);
end
figure(4)
plot(y)