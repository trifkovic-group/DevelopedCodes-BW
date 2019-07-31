clc
clear

frames = 100; %Number of frames in image sequence

for k = 1:frames
    k
    %Name of droplet data set, if loop needed due to how images are named
    %when saving in LASX
    S3='.tif';
    if k < 10
        SS1 = ['Morwet Hydrophobic.lif_middle narrow_Crop001_t00' num2str(k) '_ch01'];
    elseif k < 100
        SS1 = ['Morwet Hydrophobic.lif_middle narrow_Crop001_t0' num2str(k) '_ch01'];
    else
        SS1 = ['Morwet Hydrophobic.lif_middle narrow_Crop001_t' num2str(k) '_ch01'];
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
    OrigIm = imgaussfilt(OrigIm,4);
    
    %Applying an averaging filter to the image
    FiltIm(:,:,k) = OrigIm;
    for i = 1:15
        FiltIm(:,:,k) = imfilter(FiltIm(:,:,k),ones(5)/25);
    end
    
    %Binarize the image, generate a distance map
    BinIm = imbinarize(FiltIm(:,:,k)/max(max(FiltIm(:,:,k))));
    se = strel('disk',5);
    BinIm = imclose(BinIm,se);
    DM = bwdist(imcomplement(BinIm));
    DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2);
    DM2 = reshape(DM,pixels(1)*pixels(2),1);
    inx = 1; %Counter for indexing drops as the are found
    holycircles = zeros(pixels(1),pixels(2)); %initialize matrix droplet visualization
    spheres = [];
    while max(DM2>20) %Update the value being compared to 32 to choose a min drop size
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
        %imshow(DM)
        DM2 = reshape(DM,pixels(1)*pixels(2),1);
        %imshow(DM)
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

%Filter images, I beleive this helps match the drops between frames
for i = 1:2
    FiltIm = imfilter(FiltIm,ones(5,25)/125);
end
FiltIm = FiltIm(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:);


tdataprevbackup = cell2mat(tspheres(frames));
for l = frames:-1:2 %Going through frames
    l
    tdata = tdataprevbackup;
    tdatabackup  = tdata;
    tdataprev = [cell2mat(tspheres(l-1)) zeros(length(cell2mat(tspheres(l-1))),1)];
    tdataprevbackup = tdataprev;
    for j = 1:length(tdatabackup(:,1))
        
        if l == frames && j == 1
            tdata(:,4) = (1:length(tdata(:,1)));
            tdatabackup  = tdata;
            in = length(tdatabackup(:,1))+1;
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
    FI = FiltIm(:,:,l-1);
    for b = 1:length(tdatabackup(:,1))
        if tdatabackup(b,4) == 0
            tdatabackup(b,4) = in;
            tdata(b,4) = in;
            paths(in) = {[tdata(b,:) l]};
            in = in+1;
        end
    end
    
    for m = 1:min(length(tdataprevbackup(:,1)),length(tdatabackup(:,1)))
        BestCentDiffm = min(find(BestCentDiffBackup == min(BestCentDiff)));
        BestCentDiff(min(find(BestCentDiff==BestCentDiffBackup(BestCentDiffm)==1))) = [];
        
        A = FI;
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
        
        %         if tdata(BestCentDiffm,4) == 0
        %             tdata(BestCentDiffm,4) = in;
        %             tdatabackup(BestCentDiffm,4) = in;
        %             paths(in) = {[tdata(BestCentDiffm,:) l]};
        %             %tdata(maxyind,4) = in;
        %             tdataprevbackup(MatchIndexB,4) = in;
        %             in = in+1;
        %         end
        if abs(tdata(BestCentDiffm,2) - tdataprev(MatchIndexm,2)) < 50 && abs(tdata(BestCentDiffm,3) - tdataprev(MatchIndexm,3)) < 125
            tdataprev(MatchIndexm,4) = tdata(BestCentDiffm,4);
            %paths(tdata(maxyind,4)-1) = {tdata(maxyind,:)};
            pathcheck = cell2mat(paths(tdata(BestCentDiffm,4)));
            pathcheck = [pathcheck;tdataprev(MatchIndexm,:) l-1];
            paths(tdata(BestCentDiffm,4)) = {pathcheck};
            tdataprevbackup(MatchIndexB,4) = tdata(BestCentDiffm,4);
            
            DM3 = zeros(pixels(1),pixels(2));
            DM3(tdataprevbackup(MatchIndexB,2),tdataprevbackup(MatchIndexB,3)) = 1;
            DM3 = bwdist(DM3);
            FI(DM3<tdataprevbackup(MatchIndexB,1)/2) = 0;
            DM3 = zeros(pixels(1),pixels(2));
            DM3(tdata(BestCentDiffm,2),tdata(BestCentDiffm,3)) = 1;
            DM3 = bwdist(DM3);
            FI2 = FiltIm(:,:,l);
            FI2(DM3<tdata(BestCentDiffm,1)/2) = 0;
            FiltIm(:,:,l) = FI2;
        end
        
        
        %imagesc(FI)
        %pause(1)
        tdataprev(MatchIndexm,:) = [];
    end
    
    
    CheckThing = find((tdataprevbackup(:,4) == 0) == 1);
    CheckThing(CheckThing == 0) = [];
    
    for n = 1:length(CheckThing)
        n2 = CheckThing(n);
        A2 = FiltIm(:,:,l);
        indx = round([tdataprevbackup(n2,2) - tdataprevbackup(n2,1),tdataprevbackup(n2,2) + tdataprevbackup(n2,1)]);
        indy = round([tdataprevbackup(n2,3) - tdataprevbackup(n2,1),tdataprevbackup(n2,3) + tdataprevbackup(n2,1)]);
        indx(indx<1) = 1;
        indx(indx>pixels(1)) = pixels(1);
        indy(indy<1) = 1;
        indy(indy>pixels(2)) = pixels(2);
        T2 = FiltIm(indx(1):indx(2),indy(1):indy(2),l-1);
        
        cc = normxcorr2(T2,A2);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));
        corr_offset = [ (ypeak-size(T2,1)/2) (xpeak-size(T2,2)/2) ];
        
        CentDiffmr = ((tdatabackup(:,2)-corr_offset(1)).^2 + (tdatabackup(:,3)-corr_offset(2)).^2).^.5;
        MatchIndexmr = min(find(CentDiffmr == min(CentDiffmr)));
        %             CentDiffBr = ((tdataprevbackup(:,2)-corr_offset(1)).^2 + (tdataprevbackup(:,3)-corr_offset(2)).^2).^.5;
        %             MatchIndexBr = min(find(CentDiffB == min(CentDiffB)));
        FrameCompare = cell2mat(paths(MatchIndexmr));
        if length(FrameCompare) > 0 
        if abs(tdatabackup(MatchIndexmr,2) - tdataprevbackup(n2,2)) < 50 && abs(tdatabackup(MatchIndexmr,3) - tdataprevbackup(n2,3)) < 125 && l ~= FrameCompare(end,5)
            tdataprevbackup(n2,4) = tdatabackup(MatchIndexmr,4);
            %paths(tdata(maxyind,4)-1) = {tdata(maxyind,:)};
            pathcheck = cell2mat(paths(tdatabackup(MatchIndexmr,4)));
            pathcheck = [pathcheck;tdataprevbackup(n2,:) l-1];
            paths(tdatabackup(MatchIndexmr,4)) = {pathcheck};
            tdataprevbackup(n2,4) = tdatabackup(MatchIndexmr,4);
            
            DM3 = zeros(pixels(1),pixels(2));
            DM3(tdataprevbackup(n2,2),tdataprevbackup(n2,3)) = 1;
            DM3 = bwdist(DM3);
            FI(DM3<tdataprevbackup(n2,1)/2) = 0;
            DM3 = zeros(pixels(1),pixels(2));
            DM3(tdata(MatchIndexmr,2),tdata(MatchIndexmr,3)) = 1;
            DM3 = bwdist(DM3);
            FI2 = FiltIm(:,:,l);
            FI2(DM3<tdata(MatchIndexmr,1)/2) = 0;
            FiltIm(:,:,l) = FI2;
        end
        end
    end
end
colorVal = 0;
hc2 = zeros(pixels(1),pixels(2),frames);
figure(2)
hold on
AngCount = 1;
for i = 1:length(paths)
    if length(cell2mat(paths(i))) > 0
    p = cell2mat(paths(i));
    if length(p(:,1)) > 2 && length(p(:,1)) < 25
        for m = length(p(:,1)):-1:2
            if p(m,3)<p(m-1,3) && p(m-1,3) - p(m,3) < 80 && abs(p(m,2) - p(m-1,2)) < 20
            quiver(p(m,3)/2,p(m,2)/2,-(p(m,3)-p(m-1,3))/2,-(p(m,2)-p(m-1,2))/2,'Color',[abs(1-colorVal) 0 colorVal])
            Angs(AngCount) = atan((p(m,2)-p(m-1,2))/(p(m,3)-p(m-1,3)));
            AngCount = AngCount+1;
            end
        end
        colorVal = colorVal+.007;
        for j = 1:length(p(:,1))
            hc3 = zeros(pixels(1),pixels(2));
            DM3 = zeros(pixels(1),pixels(2));
            DM3(p(j,2),p(j,3)) = 1;
            DM3 = bwdist(DM3);
            hc3(DM3<p(j,1)*1.05) = p(j,4);
            hc2(:,:,p(j,5)) = hc2(:,:,p(j,5)) + hc3;
            hc2(1,1,p(j,5)) = 1000;
        end
    end
    end
end
hold off
for i = 1:frames
    h(:,:,:,i) = label2rgb(hc2(:,:,i),'hsv','k','shuffle');
end

% CD = cell(1,98);
% for i = 1:length(paths)
%     P = cell2mat(paths(i));
%     if length(P) > 0
%     for j = 1:length(P(:,1))
%         CD(P(j,end)) = {[cell2mat(CD(P(j,end))) ; P(j,:)]};
%     
%     end
%     end
%     
% end
% 
% for i = 1:length(CD)-1
%     
%    F1 = cell2mat(CD(i));
%    F2 = cell2mat(CD(i+1));
%    if length(F1) > 0
%        if length(F2) > 0
%    k = 1;
%    oind = [];
%    Cdists = [];
%    for j = 1:length(F1(:,1))
%       oind = min(find(F1(j,4) == F2(:,4)));
%       if length(oind) > 0
%           Cdists(k,:) = F1(j,2:3) - F2(oind,2:3);
%           k = k + 1;
%       end
%    end
%    C(i) = {Cdists};
%        end
%    end
% end
% D = [];
% for i = 1:length(C)
% 
% C2 = cell2mat(C(i));
%     for j = 1:length(C2(:,1))
%         for k = j+1:size(C2,1)
%             D(length(D)+1) = sqrt( (C2(j,1) - C2(k,1))^2  +  (C2(j,2) - C2(k,2))^2);
%         end
%     end
% end
figure(1)
histogram(Angs,15)
xlim([-pi/2,pi/2])

h = histfit(HBCM,15);
hold on
h2 = histfit(HLCM,15);
h(2).Color = [.2 .2 .8];
h(1).FaceAlpha = 0.4;
h2(1).FaceAlpha = 0.4;
set(gca,'FontSize',20)
xlim([-pi/2,pi/2])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.15, 0.25, 0.3, 0.6]);
hold off

x1 = HBM(:,1);
y1 = HBM(:,2);
er1 = HBM(:,3);
x2 = HLM(:,1);
y2 = HLM(:,2);
er2 = HLM(:,3);

errorbar(x1,y1,er1/2,'bo')
hold on

xlim([0,120])
ylim([0,40])
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.15, 0.25, 0.3, 0.6]);
P1 = polyfit(x1,y1,1);
P2 = polyfit(x2,y2,1);
yfit = P1(1)*x1+P1(2);
yfit2 = P2(1)*x2+P2(2);
plot(x1,yfit,'b');
errorbar(x2,y2,er2/2,'ro')
plot(x2,yfit2,'r')
xlabel('Depth (?m)')
ylabel('Velocity (?m/s)')
set(gca,'FontSize',20)
hold off