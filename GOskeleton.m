clc
clear

%Name of droplet data set
S1='Grey';
S3='.tif';

Nimages = 20; %Total number of images in a data set
pixels = size(imread([S1,'00',S3])); % Read dimensions of images

array_m = zeros(pixels(1), pixels(2), Nimages+1);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = 0 : Nimages

    S2=int2str(slice);
    if slice<10
        S=[S1,'0',S2,S3];
    else slice>100;
        S=[S1,S2,S3];
    end
    
    
%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
fullFileName_m = fullfile('StackAvg', S);

thisSlice_m = imread(fullFileName_m);

array_m(:,:,slice+1) = thisSlice_m;
end

