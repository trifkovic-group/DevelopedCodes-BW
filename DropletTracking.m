clc
clear

%Empty matrix to speed up loop, size of (x,2) where x is number of time
%steps

Nim = 12;
Nst = 50;
%Loop through time steps
for t = 0:Nst
    t
    for im = 0:Nim
        if im < 10
            S = ['0' num2str(im)];
        else
            S = [num2str(im)];
        end
        Zslice = imread([num2str(t) '/S' S '.tiff']);
        Tslice(:,:,im+1) = Zslice;
    end
    CC = bwconncomp(Tslice);
    RP = regionprops(CC,'Centroid');
    Centers(t+1) = {cell2mat({RP.Centroid}')};
    AllSlices(:,:,:,t+1) = Tslice;
end

Centers(1) = {[cell2mat(Centers(1)) [1:length(cell2mat(Centers(1)))]']};
DI = length(cell2mat(Centers(1)))+1;

for i = 1:Nst
    i
    X1 = cell2mat(Centers(i));
    X2 = cell2mat(Centers(i+1));
    mdistI = [];
    for j = 1:size(X2)
        delta = X1(:,1:3) - X2(j,1:3);
        distance = sqrt(sum((delta.*delta)'));
        mdist(j) = min(distance);
        mdistI(j) = find(mdist(j) == distance);
    end
    
    for j = 1:size(X1)
        BM = min(mdist(find(mdistI == j)));
        if isempty(BM) == 0
            BMI = find(mdist == BM);
            X2(BMI,4) = X1(j,4);
        end
    end
    for j = 1:size(X2)
        if X2(j,4) == 0
            X2(j,4) = DI;
            DI = DI + 1;
        end
    end
    
    Centers(i+1) = {X2};

end

FrameCount = ones(1,1000);
DropGroup = [];

for i = 1:length(Centers)
    DI = cell2mat(Centers(i));
    for j = 1:size(DI)
        DropGroup(FrameCount(DI(j,4)),1:4,DI(j,4)) = DI(j,1:4);
        FrameCount(DI(j,4)) = FrameCount(DI(j,4)) + 1;
    end
end

DG = DropGroup;
for i = 1:length(DropGroup)
    SDG = size(DG);
    DG = DropGroup(:,:,i);
    DG(end+1,:,i) = 0;
    DG(DG == 0) = [];
    DG = reshape(DG,[length(DG)/4,4]);
    DGC(i) = {DG};
end