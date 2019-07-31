

clc
clear
tic
xpHC=[3.86 4.73 5.29 5.67 5.89 6.12 6.38 6.72 6.96 7.34 7.71 7.99 8.34 8.63 8.87 9.22 9.61 9.99 10.33 10.66 10.99];
ratioCNF=[-13.51 -13.19 -12.56 -11.59 -10.40 -8.95 -6.45 -3.36 -1.70 0.33 3.86 8.56 17.28 23.29 26.42 30.10 34.86 41.23 49.37 58.11 65.91];
se = strel('disk',20);
se2 = strel('disk',75);

frames = 100;
s = [512 512 frames];
FrameG = zeros(s);
FrameB = zeros(s);
BFiltVid = zeros(s);
GFiltVid = zeros(s);
PHFin= zeros(s);
PHOutFilt = zeros(s);

p1 =  -5.284e-10;
p2 =    1.11e-07;
p3 =  -8.634e-06;
p4 =   0.0002932;
p5 =   -0.003894;
p6 =     0.07322;
p7 =       7.302;

fname = 'EC7 Al Cathode CNF March 30.lif_2mA-cm2_Crop001_t';

for i = 1:frames
    if i < 10
        FrameG(:,:,i) = double(imread([fname '000' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread([fname '000' num2str(i) '_ch01.tif']));
    elseif i < 100
        FrameG(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
    elseif i < 1000
        FrameG(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
    else
        FrameG(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        FrameB(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
    end
    
    
    GFilt = imfilter(FrameG(:,:,i),ones(17)/17^2,'symmetric');
    BFilt = imfilter(FrameB(:,:,i),ones(17)/17^2,'symmetric');
    
    %GFilt = GFilt * max(max(FrameG(:,:,i))) / max(max(GFilt));
    %BFilt = BFilt * max(max(FrameB(:,:,i))) / max(max(BFilt));
    
    GFilt(GFilt < max(max(GFilt(:,440:end)))) = 0;
    BFilt(BFilt < max(max(BFilt(:,440:end)))) = 0;
    
    GFilt(GFilt < 0.5) = 0.5;
    BFilt(BFilt < 0) = 0;
    
    BFiltVid(:,:,i) = BFilt;
    GFiltVid(:,:,i) = GFilt;
    
    PHMap = -(GFilt./BFilt - BFilt./GFilt);
    PHMap(isnan(PHMap)) = 0;
    PHMap(PHMap == Inf) = 0;
    PHMap(PHMap == -Inf) = 0;
    
    PHOut = p1.*PHMap.^6 + p2.*PHMap.^5 + p3.*PHMap.^4 + p4.*PHMap.^3 + p5.*PHMap.^2 + p6.*PHMap + p7;
    PHOut(PHOut == p7) = 0;
    PHOutFilt = imfilter(PHOut,ones(17)./17^2,'symmetric');
    PHMid = imfilter(PHOutFilt,ones(25)/25^2,'symmetric');
    PHSides = PHMid;
    PHMid(PHMid < 8) = 0;
    PHSides(PHSides >= 8) = 0;
    PHSidesO = imopen(PHSides,se2);
    PHSides(PHSidesO< 1) = 0;
    
    PHM = PHMid + PHSides;
    
    
    PHMC = imclose(PHM,se);
    if sum(sum(PHMC>8 & PHMC < 9)) > 20000
        [xx,~] = find(PHMC > 8 & PHMC < 9);
        xavg = round(mean(xx)*(5/6));
        PH9 = PHMC(:,xavg:end);
        PH9(PH9>8) = 9;
        PHMC(:,xavg:end) = PH9;
    end
    PHFin(:,:,i) = PHMC;
    thic(i) = sum(sum(PHMC>8));
end

toc
PHFin(PHFin < 5.6 & PHFin > 0) = 5.6;
PHFin(PHFin == 0) = -Inf;
PHFin(1,1,:) = 0;
X = [422 512 512 422];
Y = [512 512 1 1];

% for i = 1:frames
%     [C,h] = contourf(PHFin(:,:,i));
%     clabel(C,h)
%     axis off
%     colorbar
%     caxis([0 10])
%     title(['t =' num2str(i*(98/1096)) '(s)'])
%     patch(X,Y,[0.5 0.5 0.5])
%     saveas(gcf,[num2str(i) '.tif']);
% end
