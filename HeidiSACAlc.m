clc
clear

%Name of image being loaded

SS = 'G2.lif_Series001_Crop001_ch00.tif';
%Initialize matrices
pixels = size(imread([SS1 '.tif'])); %Size of image
C = zeros(pixels(1), pixels(2));

se = strel('disk',10); %Structuring element for morpholigcal operations
thisSlice_c = double(imread(SS));%Load image
C(:,:) = thisSlice_c;

MFC = C;
for i = 1:5 %Apply a median filter
    MFC = medfilt2(MFC,[5,5],'symmetric');
end

%Mirror the matrix to improve distance mapping at edge of frame
MFC = [flipdim(flipdim(MFC,1),2) flipdim(MFC,1) flipdim(flipdim(MFC,1),2); flipdim(MFC,2) MFC flipdim(MFC,2); flipdim(flipdim(MFC,1),2) flipdim(MFC,1) flipdim(flipdim(MFC,1),2)];

C = imbinarize(uint8(MFC),.03); %Binarized the image
C = imclose(C,se); %Perform the morpholical operation closing
DM = bwdist(imcomplement(C)); %Generate distance map
DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:);%Crop out mirrored edges

DM2 = reshape(DM,pixels(1)*pixels(2),1);%Get total number of elements
inx = 1; %Initialize droplet index
DM3 = zeros(pixels(1),pixels(2));
hc = zeros(pixels(1),pixels(2)); %Used only for visualization
while max(DM2>30) %Set condition for minimum droplet size
    DM2 = reshape(DM,pixels(1)*pixels(2),1);
    Cent = min(find(DM2 == max(DM2))); %Find location of largest droplet
    spheres(inx,1) = max(DM2);%Record droplet size
    
    %Record droplet locations
    [x,y,z] = ind2sub([pixels(1),pixels(2)],Cent);
    Y = [x y z];
    spheres(inx,2:4) = Y;
    inx = inx+1; %Increase droplet index
    DM(Y(1),Y(2),Y(3)) = 0;
    
    X = zeros(pixels(1)*pixels(2),3);
    ind = 1;
    
    DM3(Y(1),Y(2)) = 1;
    bwdm = bwdist(DM3);
    DM(bwdm<max(DM2)*1.05)= 0; %Remove current droplet from image
    hc(bwdm<max(DM2)*1.05) = 1;
    
    %Recalculate distance map
    DM = [flipdim(flipdim(DM,1),2) flipdim(DM,1) flipdim(flipdim(DM,1),2); flipdim(DM,2) DM flipdim(DM,2); flipdim(flipdim(DM,1),2) flipdim(DM,1) flipdim(flipdim(DM,1),2)];
    DM = bwdist(imcomplement(imbinarize(DM)));
    DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:) ;
    hc(bwdm<max(DM2)*1) = 1;
end

spheres(:,1) = spheres(:,1) * 0.568; %Scale by pixel size
SpheresA = spheres(1:end-1,1).^2*pi; %Calculate area of droplets in frame
VF = sum(SpheresA)/(pixels(1)*pixels(2))/.568/.568; %Calculate area fraction
V = spheres(1:end-1,1).^3*pi*(4/3); %Using circle radii, calculate volume of droplets
SA = spheres(1:end-1,1).^2*4*pi; %Using circle radii, calculate surface area of droplets