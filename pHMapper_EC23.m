clc
clear

CH4_2 = [5.128381 4.950506 4.547366 3.902647 2.64706 1.934149 1.572804 0.635442 0.2852 0.186667 0.158165];
PH4_2 = [9.31 8.99 8.72 8.36 8.05 7.85 7.61 7.19 6.71 6.41 6.14];

p1 = 0.01767;
p2 = -0.2442;
p3 = 1.276;
p4 = -3.115;
p5 = 3.831;
p6 = 5.738;

f1 = @(x) p1*x.^5 + p2*x.^4 + p3*x.^3 + p4*x.^2 + p5*x + p6;

fname = 'EC23 Oct 21 2018 AL cathode PW 7.05.lif_16 mA-cm2_FR_Crop001_Crop001_t';
frames = 300;


sc = ones(512,512);
for i = 1:120
    sc(:,i+376,:) = sc(:,i+376,:) / (1-i/120/100);
end

for i = 10:50
    A(:,:,i-9) = imread([fname '0' num2str(i) '_ch01.tif']);
end

A2 = mean(A,3);
A3 = imfilter(double(A2),ones(150)/150^2,'symmetric');
A4 = A3./(max(A3)*.7);
A4(A4>1) = 1;

for i = 1:frames
    if i < 10
        Frame2(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
    elseif i < 100
        Frame2(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
    else
        Frame2(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        Frame4(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
    end
    
    Filt2 = imfilter(Frame2(:,:,i),ones(32)/32^2,'symmetric');
    Filt2(Filt2<11) = 11;
    Filt2 = Filt2.*sc;
    Filt4 = imfilter(Frame4(:,:,i),ones(32)/32^2,'symmetric');
    
    R = Filt4./Filt2;
    
    PHR = f1(R);
    
    PHRF = imfilter(PHR,ones(32)/32^2,'symmetric');
    
    PHOut(:,:,i) = PHRF;
    Filt4_all(:,:,i) = Filt4;

end 

% BW4 = imbinarize(Filt4_all/255);
% BW4(:,440:end,:) = 1;
% DM2 = zeros(size(BW4));
% for i = 1:frames
%     i
%     DM(:,:) = bwdist(BW4(:,:,i));
%     DM3 = zeros(size(DM));
%     DM5 = zeros(size(DM));
%     for j = 1:512
%         DM(j,1:min(find((DM(j,:)==1)))) = 0;
%     end
%     
%     while max(max(DM)) > 15
%         ind = min(find(DM == max(max(DM))));
%         DM3(ind) = 1;
%         DM4 = bwdist(DM3);
%         DM5(DM4<max(max(DM))) = 1;
%         DM(DM5 == 1) = 0;
%     end
%     DM6(:,:,i) = DM5;
%     DM2(:,:,i) = DM;
% end

BW4 = imbinarize(Filt4_all/255,0.05);
BW4(:,440:end,:) = 1;
se = strel('disk',5);
for i = 1:frames
    i
    BW42 = BW4(:,:,i);
    for j = 1:512
        BW42(j,1:min(find((BW42(j,:)==1)))) = 1;
    end
    BW4(:,:,i) = imclose(BW42,se);
end






%PHOut = PHOut.*sc;

PHFt2 = medfilt3(PHOut,[1 1 5],'symmetric');

% ma = zeros(size(PHFt2));
% ma(PHFt2 > 7.5) = 1;
% ma2 = zeros(size(PHFt2));
% ma2(Filt4_all < 5) = 1;
% ma3 = ma.*ma2;

PHFt = PHOut;

BW5 = BW4;
BW5(:,450:end,:) = 0;
se2 = strel('disk',10);
BW4 = imerode(BW4,se2);
CircFilt = 1-imfilter(1-BW5,ones(150)/150^2,'symmetric')/10;
PHFt = PHFt./CircFilt;
PHFt(PHFt<6.14) = 6.14;
PHFt(PHFt>9) = 9.31;
PHFt(isnan(PHFt)) = 9.31;
PHFt(1,1,:) = 0;
PHFt(end,end,:) = 9.31;
% PHFt(ma3==1) = 0;
% PHFt(DM6>0) = 0;

%BW4(:,:,1:70) = 1;

PHFt(BW4 == 0) = 0; 


X = [440 512 512 440];
Y = [1 1 512 512];

colormap('parula')
for i = 1:frames
    imagesc(PHFt(:,:,i))
    patch(X,Y,[0.5 0.5 0.5])
    colorbar
    axis off
    title(['t =' num2str(i*.174) '(s)'])
    saveas(gcf,[num2str(i) '.tif']);
    dlmwrite([num2str(i) '.txt'],PHFt(:,:,i))
end
