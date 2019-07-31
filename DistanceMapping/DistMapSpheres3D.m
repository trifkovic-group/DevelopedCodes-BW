clc
clear

%Name of droplet data set
S1='Distance';
S3='.tif';
SS1 = 'BW';



Nimages = 119;
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

DM = bwdist(imcomplement(C));
%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2)*120,1);
inx = 1;

while max(DM2>5)
spheres(inx,1) = max(DM2);


%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2)*120,1);
Cent = min(find(DM2 == max(DM2)));
[x,y,z] = ind2sub([pixels(1),pixels(2),Nimages-ImageStart+1],Cent);
Y = [x y z];
spheres(inx,2:4) = Y
inx = inx+1;
DM(Y(1),Y(2),Y(3)) = 0;

X = zeros(pixels(1)*pixels(2)*(Nimages-ImageStart+1),3);
ind = 1;

tic
% for i = 1:512
%     for j = 1:512
%         for k = 1:120
%                 X(ind,:) = [i j k/3];
%                 ind = ind+1;
%         end
%     end
% end

for i = max([1,floor(Y(1)-max(DM2))]):min([512,ceil(Y(1)+(max(DM2)))])
    for j = max([1,floor(Y(2)-max(DM2))]):min([512,ceil(Y(2)+max(DM2))])
        for k = max([1,floor(Y(3)-max(DM2)/3)]):min([120,ceil(Y(3)+(max(DM2)/3))])
                X(ind,:) = [i j k/3];
                ind = ind+1;
        end
    end
end

X(X==0) = [];
if min(size(X)) == 1
    X = reshape(X,length(X)/3,3);
end
Z = rangesearch(X,Y,max(DM2)*1.1);
Z2 = cell2mat(Z);

X2 = X(Z2,:);
s = size(X2);
for i = 1:s(1)
    X3 = sub2ind([pixels(1),pixels(2),Nimages-ImageStart+1],X2(i,1),X2(i,2),X2(i,3)*3);
    DM(floor(X3)) = 0;
end
toc
DM = bwdist(imcomplement(imbinarize(DM)));
imshow(DM(:,:,1))
end

