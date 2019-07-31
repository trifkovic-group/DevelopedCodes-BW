clc
clear

xpHC=[3.86 4.73 5.29 5.67 5.89 6.12 6.38 6.72 6.96 7.34 7.71 7.99 8.34 8.63 8.87 9.22 9.61 9.99 10.33 10.66 10.99];
ratioCNF=[-13.51 -13.19 -12.56 -11.59 -10.40 -8.95 -6.45 -3.36 -1.70 0.33 3.86 8.56 17.28 23.29 26.42 30.10 34.86 41.23 49.37 58.11 65.91];

for i = 1:200
    i
    if i < 10
        FrameG(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t000' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t000' num2str(i) '_ch01.tif']));
    elseif i < 100
        FrameG(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t00' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t00' num2str(i) '_ch01.tif']));
    elseif i < 1000
        FrameG(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t0' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t0' num2str(i) '_ch01.tif']));
    else
        FrameG(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread(['EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t' num2str(i) '_ch01.tif']));
    end
    
    FrameG(FrameG < 0.5) = 0.5;
    GFilt = imfilter(FrameG(:,:,i),ones(17)/17^2,'symmetric');
    BFilt = imfilter(FrameB(:,:,i),ones(17)/17^2,'symmetric');
    
    %GFilt = GFilt * max(max(FrameG(:,:,i))) / max(max(GFilt));
    %BFilt = BFilt * max(max(FrameB(:,:,i))) / max(max(BFilt));
    
    %GFilt(GFilt < max(max(GFilt(:,440:end)))) = 0;
    BFilt(BFilt < max(max(BFilt(:,440:end)))) = 0;
    
    %GFilt(GFilt < 0.5) = 0.5;
    BFilt(BFilt < 0) = 0;
    
    BFiltVid(:,:,i) = BFilt;
    GFiltVid(:,:,i) = GFilt;
    
    PHMap = GFilt./BFilt - BFilt./GFilt;
    PHMap(isnan(PHMap)) = 0;
    PHMap(PHMap == Inf) = 0;
    PHMap(PHMap == -Inf) = 0;
    PHMapt(:,:,i) = -PHMap;
    
%     PHMap2 = BFilt./GFilt - GFilt./BFilt;
%     PHMap2(isnan(PHMap2)) = 0;
%     PHMap2(PHMap2 == Inf) = 0;
%     PHMap2(PHMap2 == -Inf) = 0;
end

for j = 1:512
    j
    for k = 1:512
        PHMFilt(j,k,:) = medfilt1(PHMapt(j,k,:),3);
    end
end
       p1 =  -5.284e-10;
       p2 =    1.11e-07;
       p3 =  -8.634e-06;
       p4 =   0.0002932;
       p5 =   -0.003894;
       p6 =     0.07322;
       p7 =       7.302;
PHOut = p1.*PHMFilt.^6 + p2.*PHMFilt.^5 + p3.*PHMFilt.^4 + p4.*PHMFilt.^3 + p5.*PHMFilt.^2 + p6.*PHMFilt + p7;
PHOut(PHOut == p7) = 0;
PHOutFilt = imfilter(PHOut,ones(17)/17^2,'symmetric');
implay(PHOutFilt)