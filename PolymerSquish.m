%Script used to compensate for elongation in Z direction for size dependant
%elongation factors
clc
clear

%Name of droplet data set
S1='Label';
S3='.tif';

Nimages = 10;
ImageStart = 0;
pixels = size(imread([S1 num2str(Nimages) '.tif']));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);
E = table();

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    if slice < 10
        S2 = ['0' num2str(slice)];
%     elseif slice < 100
%         S2 = ['0' num2str(slice)];
    else
         S2 = num2str(slice);
   end
     S=[S1,S2,S3];
    
    %Save all .tif files generated in Avizo into a single matrix
    thisSlice_d = imread(S);
    A(:,:,slice-(ImageStart-1)) = thisSlice_d;   
end

%Sq is the Squish eQuation which was found in excel by plotting object
%equiv diameter vs expected squish factor.  Expected squish factor is
%calculated by dividing the height of an objects bounding box by the
%average of the bounding boxes width and length.  The data is then fit to
%an exponential function to generate Sq
Sq = @(x) 3.0596*exp(-0.041*x);
CC = bwconncomp(A);
RP = regionprops(CC,'Centroid','PixelList','Area'); 

Out = zeros(size(A)); %Output image, currently empty
for i = 1:length(RP)
    obn = RP(i);
    ed = 2*(3/4/pi*(.988143*.988143*2.1014*obn.Area))^(1/3); %Calculate equiv diameter, use voxel sizes from matlab
    SF = Sq(ed); %Squish Factor
    RPC = RP(i).Centroid(3);
    if SF > 1 %Only squish, don't elongate or risk exceeding matrix dimensions
        RPPL = [RP(i).PixelList(:,1:2), round((RP(i).PixelList(:,3)-RPC)/SF+RPC)];
        RPPI = sub2ind(size(Out),RPPL(:,1),RPPL(:,2),RPPL(:,3));
    else
        RPPL = [RP(i).PixelList(:,1:2), RP(i).PixelList(:,3)];
        RPPI = sub2ind(size(Out),RPPL(:,1),RPPL(:,2),RPPL(:,3));
    end    
    Out(RPPI) = i;
end

%Save Out as ImgOut.tif
for slice = ImageStart: Nimages
    if slice == 0
        imwrite(Out(:,:,slice+1)','ImgOut.tif');
    else
        imwrite(Out(:,:,slice+1)','ImgOut.tif','WriteMode','append','Compression','none');
    end
end

% for i = 1: max(max(max(Out)))
%     ind = find(Out == i);
%     [X,Y,Z] = ind2sub(size(Out),ind);
%     %B = zeros(size(A));
%     %B(ind) = i;
%     Z = Z*5;
%     [Center_LSE(i,:),Radius_LSE(i,:)] = sphereFit([X Y Z]);
%     %fun = @(x)SSESpherEval(x,X,Y,Z);
%     %x0 = [1 1 1 1];
%     %bestx(i,:) = fminsearch(fun,x0);    
% end
% %bestx
% Center_LSE(:,3) = Center_LSE(:,3)/5;
% %Center_LSE
