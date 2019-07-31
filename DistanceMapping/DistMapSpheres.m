clc
clear

%Name of droplet data set
%S1='Ch1'; %Original
SS = 'SAGD emulsions-Aseem.lif_HPB-1 ml-min-new sample_ch00.tif'; %Thresholded

pixels = size(imread(SS));
C = zeros(pixels(1), pixels(2));
DM = C;


    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice_c = double(imread(SS));
    %thisSlice_c = rgb2gray(double(imread(SS))/255);
    %OI = double(imread(S));
    %DM(:,:) = thisSlice_d;  
    %C(:,:) = thisSlice_c;
    MF = thisSlice_c;
for i = 1:3
    MF = imfilter(MF,ones(3)/3^2,'symmetric');
end

%C = C(:,:,1);
BW = imbinarize(1-MF/255,graythresh((1-MF/255))*1.35);
DM = bwdist(imcomplement(BW));
%DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
DM2 = reshape(DM,pixels(1)*pixels(2),1);
inx = 1;
DM3 = zeros(pixels(1),pixels(2));
hc = zeros(pixels(1),pixels(2));
% % while max(DM2>2) %LOWER THRESHOLED ON DROPLET SIZE
% %     DM2 = reshape(DM,pixels(1)*pixels(2),1);
% % Cent = min(find(DM2 == max(DM2)));
% % spheres(inx,1) = max(DM2);
% % 
% % 
% % %DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
% % 
% % [x,y,z] = ind2sub([pixels(1),pixels(2)],Cent);
% % Y = [x y z];
% % spheres(inx,2:4) = Y;
% % inx = inx+1;
% % DM(Y(1),Y(2),Y(3)) = 0;
% % 
% % X = zeros(pixels(1)*pixels(2),3);
% % ind = 1;
% % 
% % DM3(Y(1),Y(2)) = 1;
% % bwdm = bwdist(DM3);
% % DM(bwdm<max(DM2)*1.05)= 0; 
% % hc(bwdm<max(DM2)*1.05) = 1;
% % 
% % % X(X==0) = [];
% % % X = reshape(X,length(X)/3,3);
% % % Z = rangesearch(X,Y,max(DM2)*1.1);
% % % Z2 = cell2mat(Z);
% % % 
% % % X2 = X(Z2,:);
% % % s = size(X2);
% % % for i = 1:s(1)
% % %     X3 = sub2ind([pixels(1),pixels(2),Nimages-ImageStart+1],X2(i,1),X2(i,2),X2(i,3)*3);
% % %     DM(X3) = 0;
% % % end
% % 
% % DM = bwdist(imcomplement(imbinarize(DM)));
% % figure(1)
% % imshow(DM)
% % end
% % 
% % radius = spheres(:,1);
% % conn = zeros(length(radius),1);
% % for i = 1:length(radius)
% %    Dropi =  spheres(i,:);
% %    DropDist = Dropi - spheres;
% %    for j = i+1:length(radius)
% %        DropDist2(i,j) = sqrt(DropDist(j,2)^2 + DropDist(j,3)^2);
% %        if DropDist2(i,j) < (spheres(i,1) + spheres(j,1))*1.05+5
% %            touching(i,j) = 1;
% %            conn(i) = conn(i) + 1;
% %        else
% %            touching(i,j) = 0;
% %        end  
% %    end
% % end
% % 
% % diam = radius * 2 * 0.481; % Last number is voxel size
% % sdiam = mean(diam.^3)/mean(diam.^2);
figure(1)
imshow(thisSlice_c/255)
figure(2)
imshow(BW)
VF = sum(sum(BW))/(size(BW,1)*size(BW,2))

