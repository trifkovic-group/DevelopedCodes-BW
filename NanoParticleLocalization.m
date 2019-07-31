clc
clear

frames = 55;
fname = '181207.lif_## Phob all x5_z';
F = [1 1 1;1 10 1;1 1 1];

for i = 0:frames
    if i < 10
        NPFrame(:,:,i+1) = imread([fname '0' num2str(i) '_ch00.tif']);
        PFrame(:,:,i+1) = imread([fname '0' num2str(i) '_ch01.tif']);
    else
        NPFrame(:,:,i+1) = imread([fname num2str(i) '_ch00.tif']);
        PFrame(:,:,i+1) = imread([fname num2str(i) '_ch01.tif']);
    end
end

PFrameF = imfilter(PFrame,ones(15)/15^2,'symmetric');
PBW = imbinarize(PFrameF,graythresh(PFrameF));
BWBord = imfilter(double(PBW),F);
BWBord(BWBord<10) = 0;
BWBord(BWBord>17) = 0;

DMall = zeros(size(BWBord));
for i = 1:size(BWBord,3)
    DM = bwdist(BWBord(:,:,i));
    DMall(:,:,i) = DM;
end
DMMask = zeros(size(DMall));
DMMask(DMall<5) = 1;

NPatI = double(NPFrame).*DMMask;
NPnotatI = double(NPFrame).*(1-DMMask);

NPP = sum(sum(sum(NPatI)))/sum(sum(sum(NPnotatI+NPatI)));

MIatI = sum(sum(sum(PBW.*DMMask.*double(NPFrame))))/sum(sum(sum(PBW.*DMMask)))
MInotatI = sum(sum(sum(PBW.*(1-DMMask).*double(NPFrame))))/sum(sum(sum(PBW.*(1-DMMask))))



I = 1;
DMMapE = DMall;
DMMapE(PBW == 0) = -1;

while max(max(max(DMMapE))) > -1
    D(I) = max(max(max(DMMapE)));
    atD = find(DMMapE == D(I));
    MatD(I) = mean(NPFrame(atD));
    M2atD(I) = mean(PFrame(atD));
    I = I+1;
    DMMapE(atD) = -1;

end

% M = MatD-median(MatD);
% M2 = M2atD-median(M2atD);
% plot(D(D<10),M(D<10)./M2(D<10))
figure(1)
plot(D(D<20),MatD(D<20))
xlabel('Distance From Interface','FontSize', 20)
ylabel('Average Intensity','FontSize', 20)
title('Hydrophilic PP','FontSize', 20)
ylim([10 70])
set(gca,'FontSize',20)
% figure(2)
% plot(D(D<20),M2atD(D<20))

se = strel('disk',15);
A = PBW(:,:,1);
B = imclose(A,se);
AA = (1-A);
C = bwareaopen(AA,100);