clc
clear

%%%%%%%%%%%%%%%%%%%%%%% This is the only section that should need editing.
%%%%%%%%%%%%%%%%%%%%%%% Change file name, the scale, and if necessary the
%%%%%%%%%%%%%%%%%%%%%%% cropping to take out the bottom SEM text
ScaleFactor = 200/(423-354); % X/(Y-Z) -- X is the scale bar physical size, Y and Z are the min and max coordinates of the scale bar, found using "imshow(InitIm)
InitIm = imread('SNP2_-W-L_2-72-28-50_FrDry 03.tif'); %Import Image
CropIm = double(InitIm(1:1420,1:2048))/255; %Crop out bottom text
%%%%%%%%%%%%%%%%%%%%%%% Outputs are in nm.
%%%%%%%%%%%%%%%%%%%%%%% EquiDia is the size of the pores
%%%%%%%%%%%%%%%%%%%%%%% Channel Width is the particle network width

FiltIm = imfilter(CropIm,ones(9)/81,'symmetric'); %Apply a box filter
for i = 1:2
    FiltIm = imfilter(FiltIm,ones(9)/81,'symmetric');
end

BW = imbinarize(FiltIm,graythresh(FiltIm)*1.2); %Binarize Image

se1 = strel('disk',20); %Perform closing to remove small black spots in the particle network
ClosedIm = imclose(BW,se1);

AreaOpenedIm = bwareaopen(ClosedIm,300); %Remove small pores
SkelIm = bwskel(AreaOpenedIm,'minbranchlength',75); %Generate a skeleton

skelim2 = zeros([size(SkelIm) 3]); %skelim2 is only used to visualize the skeleton
skelim2(:,:,1) = imdilate(SkelIm,strel('disk',2));
ImOut = CropIm+AreaOpenedIm/5+skelim2; %Image that shows the skeleton what is selected as the particle network

indexes = find(SkelIm > 0); %Use distance mapping in combination with the skeleton to find the particle channel width
BWDistanceMap = bwdist(1-AreaOpenedIm);
DistsPx = BWDistanceMap(indexes);
Dists = DistsPx*ScaleFactor*2;
ChannelWidth = mean(Dists);

Porosity = 1-sum(sum(AreaOpenedIm))/(size(AreaOpenedIm,1)*size(AreaOpenedIm,2)); %Calculate porosity

Pores = 1-AreaOpenedIm; %Inverse the image to perform analysis on the pores
PoresAreaOpen = bwareaopen(Pores,3000);

PorProps = regionprops('Table',bwconncomp(PoresAreaOpen),'Area','Perimeter','PixelIdxList'); %Isolate touching objects and calculate the area and perimeter of those objects

NewObs1 = zeros(size(BW)); %Initialize variables for loop
NewObs2 = zeros(size(BW));
J = 1;

for i = 1:height(PorProps)
    CurrentIndex = cell2mat(PorProps{i,2});
    CurrentObject = zeros(size(BW)); %Only on pore object is examind at a time
    CurrentObject(CurrentIndex) = 1;
    SECurrent = strel('Disk',round(PorProps{i,1}/PorProps{i,3})); %Create a strucutring element for erosion by calculating the characteristic length, which is used to isolate pores
    CurrentErode = imerode(CurrentObject,SECurrent);
    CC = bwconncomp(CurrentErode);
    NewObs1 = zeros(size(BW));
    for j = 1:length(CC.PixelIdxList)
        
        NewIndex = cell2mat(CC.PixelIdxList(j));
        NewObs1(NewIndex) = J;
        J = J + 1;
    end
    NewObs1 = imdilate(NewObs1,SECurrent);
    NewObs2 = NewObs2 + NewObs1;
end

ExtraFluff = (PoresAreaOpen) - NewObs2; %Add back in small features that were lost while isolating pores
ExtraFluff(ExtraFluff<1) = 0;

CCExtraFluff = bwconncomp(ExtraFluff);


for i = 1:CCExtraFluff.NumObjects
    EFIndex = cell2mat(CCExtraFluff.PixelIdxList(i));
    EFObs = zeros(size(ExtraFluff));
    EFObs(EFIndex) = 1;
    EFBord = imfilter(EFObs,ones(3));
    EFBord(EFBord>3) = 0;
    EFTouch = NewObs2(EFBord>0);
    MostTouch = mode(EFTouch(EFTouch>0));
    NewObs2(EFIndex) = MostTouch;
    
end    

IO = label2rgb(NewObs2,'hsv','k','shuffle'); %Outputs
RP = regionprops('Table',NewObs2,'Area','Perimeter','PixelIdxList');
imshow(IO)
EquivDiameter = sqrt(RP.Area/pi)*ScaleFactor*2;
EquDia = mean(EquivDiameter)
Porosity
ChannelWidth
figure(1)
imshow(ImOut)
figure(2)
imshow(IO)
figure(3)
histogram(Dists,'normalization','probability')
xlabel('Channel Width (nm)')
title('Particle Channel Width')
figure(4)
histogram(EquivDiameter,'normalization','probability')
xlabel('Equivalent Diameter (nm)')
title('Pore Size Distribution')


