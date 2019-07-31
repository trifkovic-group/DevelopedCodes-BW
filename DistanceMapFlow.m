clc
clear

for k = 1:9
%Name of droplet data set
%S1='FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t010_z2_ch01.tif';
S3='.tif';
SS1 = ['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t00' num2str(k) '_z2_ch01'];

pixels = size(imread([SS1 '.tif']));
OrigIm = zeros(pixels(1), pixels(2));

%Load the 2 image sets, sections needs adjusting based on number of images


%S=[S1 S3];
SS=[SS1 S3];

%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
%thisSlice_d = double(imread(S));
thisSlice_c = double(imread(SS));
%DM(:,:) = thisSlice_d;
OrigIm(:,:) = thisSlice_c;
O2 = flipdim(OrigIm,1);
O3 = flipdim(OrigIm,2);
O4 = flipdim(O2,2);
OrigIm = [O4 O2 O4; O3 OrigIm O3; O4 O2 O4];
FiltIm = OrigIm;
for i = 1:10
    FiltIm = imfilter(FiltIm,ones(5)/25);
end
BinIm = imbinarize(FiltIm/max(max(FiltIm)));

DM = bwdist(imcomplement(BinIm));
DM = DM(257:512,513:1024);
%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2),1);
inx = 1;
holycircles = zeros(256,512);

while max(DM2>32)
    DM3 = zeros(pixels(1),pixels(2));
    
    DM2 = reshape(DM,pixels(1)*pixels(2),1);
Cent = min(find(DM2 == max(DM2)));
spheres(inx,1) = max(DM2);


%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);

[x,y,z] = ind2sub([pixels(1),pixels(2)],Cent);
Y = [x y z];
spheres(inx,2:4) = Y;

DM(Y(1),Y(2),Y(3)) = 0;

X = zeros(pixels(1)*pixels(2),3);
ind = 1;

DM3(Y(1),Y(2)) = 1;
bwdm = bwdist(DM3);
DM(bwdm<spheres(inx,1)*1.05)= 0; 
holycircles(bwdm<spheres(inx,1)*1.05)= 1; 
inx = inx+1;

DM = bwdist(imcomplement(imbinarize(DM)));
DM2 = reshape(DM,pixels(1)*pixels(2),1);
figure(1)
imshow(DM)
figure(2)
imagesc(OrigIm(257:512,513:1024))

end


hc(:,:,k) = holycircles;
tspheres(k) = {spheres};

holycircles = zeros(256,512);
end