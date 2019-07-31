clc
clear

frames = 55;
filename = '181207.lif_## Phob all x5_z';

for i = 0:frames
    if i < 10
        Nanoparticles(:,:,i+1) = imread([filename '0' num2str(i) '_ch00.tif']);
        Polymer(:,:,i+1) = imread([filename '0' num2str(i) '_ch01.tif']);
    else
        Nanoparticles(:,:,i+1) = imread([filename num2str(i) '_ch00.tif']);
        Polymer(:,:,i+1) = imread([filename num2str(i) '_ch01.tif']);
    end
end



PolymerFilter = imfilter(Polymer,ones(15)/15^2,'symmetric');
PolymerBW = imbinarize(PolymerFilter);

FilterMatrix = [1 1 1;1 10 1;1 1 1];
BWBorder = imfilter(double(PolymerBW),FilterMatrix);
BWBorder(BWBorder<10) = 0;
BWBorder(BWBorder>17) = 0;

DistMapAllSlices = zeros(size(BWBorder));
for i = 1:size(BWBorder,3)
    DistMapCurrentSlice = bwdist(BWBorder(:,:,i));
    DistMapAllSlices(:,:,i) = DistMapCurrentSlice;
end

DistMapAllSlices(PolymerBW == 0) = -1;
I = 1;
while max(max(max(DistMapAllSlices))) > -1
    Distance(I) = max(max(max(DistMapAllSlices)));
    IndexAtDistance = find(DistMapAllSlices == Distance(I));
    MeanAtDistance(I) = mean(Nanoparticles(IndexAtDistance));
    I = I+1;
    DistMapAllSlices(IndexAtDistance) = -1;
end

figure(1)
plot(Distance(Distance<20),MeanAtDistance(Distance<20))
xlabel('Distance From Interface','FontSize', 20)
ylabel('Average Intensity','FontSize', 20)
title('Hydrophilic PP','FontSize', 20)
ylim([10 70])
set(gca,'FontSize',20)