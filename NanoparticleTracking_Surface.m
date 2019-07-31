clc
clear

frames = 100; %Number of frames in image sequence

for k = 1:frames
    
    if k < 10
        CH0 = ['without Ca.lif_Series021_Crop001_t00' num2str(k) '_ch00.tif'];
    elseif k < 100
        CH0 = ['without Ca.lif_Series021_Crop001_t0' num2str(k) '_ch00.tif'];
    else
        CH0 = ['without Ca.lif_Series021_Crop001_t' num2str(k) '_ch00.tif'];
    end
    
    
    Ch0(:,:,k) = imread(CH0);
end

Ch0BF = imfilter(Ch0,ones(5)/25);

Ch0BW = imbinarize(Ch0BF,.4);
Parties = zeros(size(Ch0BW,1),size(Ch0BW,2),frames);

for i = 1:frames
    BW = Ch0BW(:,:,i);
    PKiller = zeros(size(Ch0BF,1),size(Ch0BF,2));
    DM = bwdist(1-BW);
    Psize = max(max(DM));
    Pinfo = [];
    Pcount = 1;
    Partie = zeros(size(Ch0BF,1),size(Ch0BF,2));
    while Psize > 1.1
        DM = bwdist(1-BW);
        Psize = max(max(DM));
        Pcent = min(find(DM == Psize));
        Pinfo(Pcount,:) = [Psize,Pcent];
        Pcount = Pcount + 1;
        PKiller(Pcent) = 1;
        PKDM = bwdist(PKiller);
        BW(PKDM<Psize*1.2) = 0;
        Partie(PKDM<Psize*1.2) = 1;
        DM = bwdist(1-BW);
        Psize = max(max(DM));
        %imshow(DM)
    end
    Pinfos(i) = {Pinfo};
    Parties(:,:,i) = Partie;
end


Ndrops = 0;

Nex = cell2mat(Pinfos(1));

for i = 1:frames-1
    Cur = Nex;
    Nex = cell2mat(Pinfos(i+1));
    
    if length(Nex) > 0
        Nex = [Nex (zeros(length(Nex(:,1)),1))];
    end
    
    if i == 1
        Cur = [Cur (1:length(Cur(:,1)))'];
        Ndrops = length(Cur(:,1));
    end
    
    if length(Cur) * length(Nex) > 0
        [NexX,NexY] = ind2sub(size(BW),Nex(:,2));
        for j = 1:length(Cur(:,1))
            [a,b] = ind2sub(size(BW),Cur(j,2));
            D = sqrt((a-NexX).^2 + (b-NexY).^2);
            matchi = find(D == min(D));
            if D(matchi) < 30
                Nex(matchi,3) = Cur(j,3);
            end
        end
    end
    
    for k = 1:size(Nex,1)
        if Nex(k,3) == 0
            Ndrops = Ndrops + 1;
            Nex(k,3) = Ndrops;
        end
    end
    Tracked(i) = {Cur};
end

D = [];
%imshow(ones(size(BW)))
hold on
for i = 1:length(Tracked)-1
    TrC = cell2mat(Tracked(i));
    TrN = cell2mat(Tracked(i+1));
    if length(TrN) * length(TrC) > 0
        for j = 1:length(TrC(:,1))
            M = min(find(TrN(:,3) == TrC(j,3)));
            [CX,CY] = ind2sub([512,512],TrC(j,2));
            [NX,NY] = ind2sub([512,512],TrN(M,2));
            
            if length(M) > 0
                D(length(D)+1) = sqrt((CX-NX)^2 + (CY-NY)^2);
                quiver(CX,CY,(NX-CX),(NY-CY),'color',[1-TrC(j,3)/150,TrC(j,3)/150,1-TrC(j,3)/150],'MaxHeadSize',1)
            end
        end
    end
end
hold off

h = zeros(size(BW,1),size(BW,2),frames);

for i = 1:length(Tracked)
    h2 = zeros(size(BW));
    PInfo = cell2mat(Tracked(i));
    for j = 1:size(PInfo,1)
        DM2 = zeros(size(BW));
        DM2(PInfo(j,2)) = 1;
        DM3 = bwdist(DM2);
        h2(DM3<PInfo(j,1)) = PInfo(j,3);
    end
    h(:,:,i) = h2;
end

h(1,1,:) = 1000;
for i = 1:frames
    hc(:,:,:,i) = label2rgb(h(:,:,i),'hsv','k','shuffle');
end
