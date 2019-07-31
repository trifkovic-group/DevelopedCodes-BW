clc
clear

OriginalImage = imread('Project.lif_Series053_t0000_ch00.tif');
FilteredImage = imfilter(OriginalImage,ones(10)/10^2);

Walls = zeros(512,512,100);
for i = 1:100
    if i < 10 
        Walls(:,:,i) = imread(['Project.lif_Series053_t000' num2str(i) '_ch01.tif']);
    elseif i < 100
        Walls(:,:,i) = imread(['Project.lif_Series053_t00' num2str(i) '_ch01.tif']);
    else
        Walls(:,:,i) = imread(['Project.lif_Series053_t0' num2str(i) '_ch01.tif']);
    end
end

WallsStatic = mean(Walls,3);
WallsStaticFiltered = WallsStatic;

for i = 1:5
    WallsStaticFiltered = imfilter(WallsStaticFiltered,ones(20)/20^2,'symmetric');
end

imshow(WallsStatic)
hold on
% for i = 10
%     quiver(Data(1,i),Data(2,i),Data(3,i),Data(4,i))
% end