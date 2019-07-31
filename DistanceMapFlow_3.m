clc
clear

frames = 9; %Number of frames in image sequence

for k = 1:frames
    k
    %Name of droplet data set, if loop needed due to how images are named
    %when saving in LASX
    S3='.tif';
    if k < 10
        SS1 = ['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t00' num2str(k) '_z2_ch01'];
    elseif k < 100
        SS1 = ['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t0' num2str(k) '_z2_ch01'];
    else
        SS1 = ['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t' num2str(k) '_z2_ch01'];
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
    DM = bwdist(imcomplement(BinIm));
    DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2);
    DM2 = reshape(DM,pixels(1)*pixels(2),1);
    inx = 1; %Counter for indexing drops as the are found
    holycircles = zeros(pixels(1),pixels(2)); %initialize matrix droplet visualization
    spheres = [];
    while max(DM2>32) %Update the value being compared to 32 to choose a min drop size
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

%Filter images, I beleive this helps match the drops between frames
% for i = 1:2
%     FiltIm = imfilter(FiltIm,ones(5,25));
% end
FiltIm = FiltIm(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:);


tdataprevbackup = cell2mat(tspheres(9));
for l = frames:-1:8 %Going through frames
    tdata = tdataprevbackup;
    tdatabackup  = tdata;
    tdataprev = [cell2mat(tspheres(l-1)) zeros(length(cell2mat(tspheres(l-1))),1)];
    tdataprevbackup = tdataprev;
    for j = 1:length(tdatabackup)
        
        if l == frames && j == 1
            tdata(:,4) = (1:length(tdata(:,1)));
            tdatabackup  = tdata;
            in = length(tdatabackup)+1;
        end
        
        A = FiltIm(:,:,l-1);
        indx = round([tdata(j,2) - tdata(j,1),tdata(j,2) + tdata(j,1)]);
        indy = round([tdata(j,3) - tdata(j,1),tdata(j,3) + tdata(j,1)]);
        indx(indx<1) = 1;
        indx(indx>pixels(1)) = pixels(1);
        indy(indy<1) = 1;
        indy(indy>pixels(2)) = pixels(2);
        T = FiltIm(indx(1):indx(2),indy(1):indy(2),l);
        
        %perfrom cross correlation, finding how far the template has moved over
        %one time step, effectively finding the velocity in pixels of the
        %entire image
        cc = normxcorr2(T,A);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));
        corr_offset = [ (ypeak-size(T,1)/2) (xpeak-size(T,2)/2) ];
        
        CentDiff = ((tdataprev(:,2)-corr_offset(1)).^2 + (tdataprev(:,3)-corr_offset(2)).^2).^.5;
        MatchIndex = min(find(CentDiff == min(CentDiff)));
        BestCentDiff(j) = CentDiff(MatchIndex);
    end
    BestCentDiffBackup = BestCentDiff;
    for m = 1:min(length(tdataprevbackup),length(tdatabackup))
        BestCentDiffm = min(find(BestCentDiffBackup == min(BestCentDiff)))
        BestCentDiff(BestCentDiff==BestCentDiffBackup(BestCentDiffm)) = [];
        
        A = FiltIm(:,:,l-1);
        indx = round([tdata(BestCentDiffm,2) - tdata(BestCentDiffm,1),tdata(BestCentDiffm,2) + tdata(BestCentDiffm,1)]);
        indy = round([tdata(BestCentDiffm,3) - tdata(BestCentDiffm,1),tdata(BestCentDiffm,3) + tdata(BestCentDiffm,1)]);
        indx(indx<1) = 1;
        indx(indx>pixels(1)) = pixels(1);
        indy(indy<1) = 1;
        indy(indy>pixels(2)) = pixels(2);
        T = FiltIm(indx(1):indx(2),indy(1):indy(2),l);
        
        %perfrom cross correlation, finding how far the template has moved over
        %one time step, effectively finding the velocity in pixels of the
        %entire image
        cc = normxcorr2(T,A);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));
        corr_offset = [ (ypeak-size(T,1)/2) (xpeak-size(T,2)/2) ];
        
        CentDiffm = ((tdataprev(:,2)-corr_offset(1)).^2 + (tdataprev(:,3)-corr_offset(2)).^2).^.5;
        MatchIndexm = min(find(CentDiffm == min(CentDiffm)));
        CentDiffB = ((tdataprevbackup(:,2)-corr_offset(1)).^2 + (tdataprevbackup(:,3)-corr_offset(2)).^2).^.5;
        MatchIndexB = min(find(CentDiffB == min(CentDiffB)));
        if l == frames
            paths(tdata(BestCentDiffm,4)) = {[tdata(BestCentDiffm,:) l]};
        end
        
        if tdata(BestCentDiffm,4) == 0
            tdata(BestCentDiffm,4) = in;
            paths(in) = {[tdata(BestCentDiffm,:) i]};
            %tdata(maxyind,4) = in;
            %tdataprevbackup(MatchIndexB,4) = in;
            in = in+1;
        end
        tdataprev(MatchIndexm,4) = tdata(BestCentDiffm,4);
        %paths(tdata(maxyind,4)-1) = {tdata(maxyind,:)};
        pathcheck = cell2mat(paths(tdata(BestCentDiffm,4)));
        pathcheck = [pathcheck;tdataprev(MatchIndexm,:) l-1];
        paths(tdata(BestCentDiffm,4)) = {pathcheck};
        tdataprevbackup(MatchIndexB,4) = tdata(BestCentDiffm,4);
        
    end
end