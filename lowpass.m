clc
clear

%Name of droplet data set
S1='Below MMP Figure ';
S3='.jpg';

ImageStart = 1;
Nimages = 4; %Total number of images in a data set
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

d = fdesign.lowpass('Fp,Fst,Ap,Ast',3,5,.5,5,100);
Hd = design(d,'equiripple');
output = filter(Hd,x2);

z1 = filter(Hd,x1);
z2 = filter(Hd,x2);

figure(1)

d1 = designfilt('lowpassiir','FilterOrder',12, ...
'HalfPowerFrequency',0.15,'DesignMethod','butter');
y1 = filtfilt(d1,double(x1));
findpeaks(y1,'MinPeakProminence',(max(double(x1)-y1) - min(double(x1)-y1))*1.15)
[P1,L1] = findpeaks(y1,'MinPeakProminence',(max(double(x1)-y1) - min(double(x1)-y1))*1.15)

figure(2)

d1 = designfilt('lowpassiir','FilterOrder',12, ...
'HalfPowerFrequency',0.15,'DesignMethod','butter');
y2 = filtfilt(d1,double(x2));
findpeaks(y2,'MinPeakProminence',(max(double(x2)-y2) - min(double(x2)-y2))*1.15)
[P2,L2] = findpeaks(y2,'MinPeakProminence',(max(double(x2)-y2) - min(double(x2)-y2))*1.15)

figure(3)

imshow(thisSlice_d)

start = floor(mean(L1));
finish = floor(mean(L2));

for i = 3:1050
    y(i-2) = thisSlice_d(round(start+i*(finish-start)/(1050-3)),i);
end
figure(4)
plot(y)