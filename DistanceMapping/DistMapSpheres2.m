clc
clear

%Name of droplet data set
S1='Distance';
S3='.tif';
SS1 = 'BW';



Nimages = 1;
ImageStart = 0;
pixels = size(imread([S1 num2str(Nimages) '.tif']));
C = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);
DM = C;

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    if slice < 10
        S2 = ['00' num2str(slice)];
    elseif slice < 100
        S2 = ['0' num2str(slice)];
    else
        S2 = num2str(slice);
    end
     S=[S1,S2,S3];
     SS=[SS1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice_d = imread(S);
    thisSlice_c = imread(SS);
    DM(:,:,slice-(ImageStart-1)) = thisSlice_d;  
    C(:,:,slice-(ImageStart-1)) = thisSlice_c;
end

C = C(:,:,1);
DM = bwdist(imcomplement(C));
%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2),1);
inx = 1;
DM3 = zeros(pixels(1),pixels(2));
while max(DM2>5)
spheres(inx,1) = max(DM2);


%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2),1);
Cent = min(find(DM2 == max(DM2)));
[x,y,z] = ind2sub([pixels(1),pixels(2),Nimages-ImageStart+1],Cent);
Y = [x y z];
spheres(inx,2:4) = Y
inx = inx+1;
DM(Y(1),Y(2),Y(3)) = 0;

X = zeros(pixels(1)*pixels(2)*(Nimages-ImageStart+1),3);
ind = 1;

tic
DM3(Y(1),Y(2)) = 1;
bwdm = bwdist(DM3);
DM(bwdm<max(DM2))= 0; 

% X(X==0) = [];
% X = reshape(X,length(X)/3,3);
% Z = rangesearch(X,Y,max(DM2)*1.1);
% Z2 = cell2mat(Z);
% 
% X2 = X(Z2,:);
% s = size(X2);
% for i = 1:s(1)
%     X3 = sub2ind([pixels(1),pixels(2),Nimages-ImageStart+1],X2(i,1),X2(i,2),X2(i,3)*3);
%     DM(X3) = 0;
% end
toc
DM = bwdist(imcomplement(imbinarize(DM)));
imshow(DM)
end

