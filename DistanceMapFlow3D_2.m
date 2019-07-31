clc
clear

S1=['FlowForDistanceMap.lif_2ulpermin_Crop_GS_001_t000_z0_ch01'];
S3='.tif';

Nimages = 20;
ImageStart = 0;
tStart = 1;
tImages = 10;
pixels = size(imread([S1 '.tif']));
C = zeros(pixels(1)*3, pixels(2)*3, Nimages-ImageStart+1);
DM = C;

%Load the 2 image sets, sections needs adjusting based on number of images
for t = tStart : tImages
    t
    for slice = ImageStart : Nimages
        if t < 10
            if slice < 10
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t00' num2str(t) '_z0' num2str(slice) '_ch00'];
            elseif slice < 100
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t00' num2str(t) '_z' num2str(slice) '_ch00'];
            end
        elseif t < 100
            if slice < 10
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t0' num2str(t) '_z0' num2str(slice) '_ch00'];
            elseif slice < 100
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t0' num2str(t) '_z' num2str(slice) '_ch00'];
            end
        elseif t < 1000
            if slice < 10
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t' num2str(t) '_z0' num2str(slice) '_ch00'];
            elseif slice < 100
                S2 = ['CNC Hydrophilic.lif_middle narrow 512 by 256 1 step size_t' num2str(t) '_z' num2str(slice) '_ch00'];
            end
        end
        
        S=[S2,S3];
        thisSlice = imread(S);
        OrigIm = thisSlice;
        O2 = flipdim(OrigIm,1);
        O3 = flipdim(OrigIm,2);
        O4 = flipdim(O2,2);
        OrigIm = [O4 O2 O4; O3 OrigIm O3; O4 O2 O4];
        FiltIm(:,:,slice-(ImageStart-1)) = OrigIm;
        FiltSize = 5;
        for i = 1:5
            FiltIm(:,:,slice-(ImageStart-1)) = imfilter(FiltIm(:,:,slice-(ImageStart-1)),ones(FiltSize)/FiltSize^2);
        end
        A(:,:,:,slice-(ImageStart-1)) = FiltIm(:,:,slice-(ImageStart-1));
    end
    B(:,:,:,t) = A;
    
    BW = imbinarize(FiltIm);
    se = strel('disk',6);
    BW = imclose(BW,se);
    
    di = [0.455 0.455 1];
    DM = bwdistsc(imcomplement(BW),di);
    DM = DM(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:);
    
    DM2 = reshape(DM,pixels(1)*pixels(2)*(slice-ImageStart+1),1);
    inx = 1;
    DM3 = zeros(pixels(1),pixels(2),(Nimages-ImageStart+1));
    hc = zeros(pixels(1),pixels(2),(Nimages-ImageStart+1));
    spheres = [];
    while max(DM2>10)
        spheres(inx,1) = max(DM2);
        
        
        DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
        Cent = min(find(DM2 == max(DM2)));
        [x,y,z] = ind2sub([pixels(1),pixels(2),Nimages-ImageStart+1],Cent);
        Y = [x y z];
        spheres(inx,2:4) = Y;
        inx = inx+1;
        
        DM3(Y(1),Y(2),Y(3)) = 1;
        bwdm = bwdistsc(DM3,di);
        DM(bwdm<max(DM2)*1)= 0;
        hc(bwdm<max(DM2)*1) = 1;
        
        DM = bwdistsc(imcomplement(imbinarize(DM,1/255)),di);
        imshow(DM(:,:,(Nimages-ImageStart+1)))
        DM2 = reshape(DM,pixels(1)*pixels(2)*(Nimages-ImageStart+1),1);
    end
    hc2(:,:,:,t) = hc;
    tspheres(t) = {spheres};
end
B = double(B);
for i = 1:2
    B = imfilter(B,ones(5,25)/125);
end

B = B(pixels(1)+1:pixels(1)*2,pixels(2)+1:pixels(2)*2,:,:);
tdataprev = cell2mat(tspheres(t));
in =  1;
paths = {};
for i = tImages:-1:tStart+1
    tdata = tdataprev;
    tdataprev = [cell2mat(tspheres(i-1)) zeros(length(cell2mat(tspheres(i-1))),1)];
    for j = 1:length(tdata(:,1))
        if i == tImages && j == 1
            tdata(:,5) = (1:length(tdata(:,1)));
            in = length(tdata(:,1))+1;
        end
        
        if i == tImages
            paths(j) = {[tdata(j,:) i]};
        end
        
        %A = FiltIm(:,:,i-1);
        indx = round([tdata(j,2) - tdata(j,1)/di(1),tdata(j,2) + tdata(j,1)/di(1)]);
        indy = round([tdata(j,3) - tdata(j,1)/di(1),tdata(j,3) + tdata(j,1)/di(1)]);
        indx(indx<1) = 1;
        indx(indx>pixels(1)) = pixels(1);
        indy(indy<1) = 1;
        indy(indy>pixels(2)) = pixels(2);
        T = B(indx(1):indx(2),indy(1):indy(2),:,i);
        A = B(:,:,:,i-1);
        
        cc = template_matching(T,A);
        imax = min(find(cc == max(max(max(abs(cc))))));
        [ypeak(j),xpeak(j),zpeak(j)] = ind2sub(size(cc),imax);
        
        CentDiff = ((tdataprev(:,2) - ypeak(j)).^2 + (tdataprev(:,3) - xpeak(j)).^2).^0.5;
        BestMatch(j) = min(CentDiff);
        MatchIndex(j) = min(find(CentDiff == min(CentDiff)));
        for b = 1:length(tdata(:,1))
            if tdata(b,5) == 0
                tdata(b,5) = in;
                paths(in) = {[tdata(b,:) i]};
                in = in+1;
            end
        end
        
    end
    BestMatch
    for k = 1:length(tdata)
        if min(BestMatch) < 30
            DropIndex = min(find(BestMatch == min(BestMatch)));
            if ((tdataprev(MatchIndex(DropIndex),2) - tdata(DropIndex,2)).^2 + (tdataprev(MatchIndex(DropIndex),3) - tdata(DropIndex,3)).^2).^(1/2) < 200
                tdataprev(MatchIndex(DropIndex),5) = tdata(DropIndex,5);
                pathtemp = cell2mat(paths(tdata(DropIndex,5)));
                pathtemp = [pathtemp;tdataprev(MatchIndex(DropIndex),:) i-1];
                paths(tdata(DropIndex,5)) = {pathtemp};
                %BestMatch(find(BestMatch == min(BestMatch))) = 10000;
                BestMatch(DropIndex) = 10000;
            end
        end
        
    end
    BestMatch = [];
end



