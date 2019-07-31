clc
clear

frames = 7; %Number of frames in image sequence

for k = 1:frames
    k
    %Name of droplet data set, if loop needed due to how images are named
    %when saving in LASX
    S3='.tif';
    if k < 10
        SS1 = ['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t000_z' num2str(k-1) '_ch01'];
    end
    pixels = size(imread([SS1 '.tif'])); %number of pixels in image. ie image size
    
    OrigIm = zeros(pixels(1), pixels(2));
    
    %Load the 2 image sets, sections needs adjusting based on number of images
    
    SS=[SS1 S3];
    
    %Mirrors the frame and creates a grid of images, allowing for distance
    %mapping to better find the drops
    thisSlice_c = double(imread(SS));
    OrigIm(:,:) = thisSlice_c;
    O2 = flipdim(OrigIm,1);
    O3 = flipdim(OrigIm,2);
    O4 = flipdim(O2,2);
    OrigIm = [O4 O2 O4; O3 OrigIm O3; O4 O2 O4];
    
    %Applying an averaging filter to the image
    FiltIm(:,:,k) = OrigIm;
    for i = 1:5
        FiltIm(:,:,k) = imfilter(FiltIm(:,:,k),ones(5)/25);
    end

    %Binarize the image, generate a distance map
    BinIm = imbinarize(FiltIm(:,:,k)/max(max(FiltIm(:,:,k))));
    se = strel('disk',10);
    BinIm = imclose(BinIm,se);
    DM = bwdist(imcomplement(BinIm));
    DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2);
    DM2 = reshape(DM,pixels(1)*pixels(2),1);
    inx = 1; %Counter for indexing drops as the are found
    holycircles = zeros(pixels(1),pixels(2)); %initialize matrix droplet visualization
    spheres = [];
    while max(DM2>40) %Update the value being compared to 32 to choose a min drop size
        DM3 = zeros(pixels(1),pixels(2));
        DM2 = reshape(DM,pixels(1)*pixels(2),1);
        Cent = min(find(DM2 == max(DM2))); %Drops are found at the maximum value on the distance map first, finds largest drops first
        spheres(inx,1) = max(DM2); %drop size is stored
        
        [x,y] = ind2sub([pixels(1),pixels(2)],Cent);
        Y = [x y]; %x and y coordinates for the center of the current drop
        spheres(inx,2:3) = Y; %Drop location is stored
        
        DM3(Y(1),Y(2)) = 1; % New distance map used to find all pixels closer to the center of a drop than the radius of that drop
        bwdm = bwdist(DM3);
        DM(bwdm<spheres(inx,1)*1.05)= 0; %Set close pixels to 0
        holycircles(bwdm<spheres(inx,1)*1.05)= 1; %Add droplet to droplet visualization matrix
        inx = inx+1;
        
        DM = bwdist(imcomplement(imbinarize(DM))); %Recalculate distance map
        DM2 = reshape(DM,pixels(1)*pixels(2),1);
%         figure(1)
%         imshow(DM)
%         figure(2)
%         imshow(holycircles)
        %Update figures to show the dropls being found
        %                 figure(1)
        %                 imshow(holycircles)
        %                 figure(2)
        %                 imagesc(OrigIm(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2))
    end
    %Allowinng for multiple frames in droplet visualization
    hc(:,:,k) = holycircles;
    tspheres(k) = {spheres};
    holycircles = zeros(pixels(1),pixels(2));
end

