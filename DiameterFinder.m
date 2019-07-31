clc
clear

%Name of droplet data set
S1='DropletSizeFinder';
S3='.tif';

Nimages = 84; %Total number of images in a data set
% pixels = size(imread([S1,'000',S3])); % Read dimensions of images
pixels = [1024,1024];
array_d = zeros(pixels(1), pixels(2), Nimages);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = 1 : Nimages

    S2=int2str(slice);
    if slice<10;
        S=[S1,'0',S2,S3];
     elseif slice<100; 
        S=[S1,S2,S3];;
    end
    
%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
fullFileName_d = fullfile('DiameterData', S);
thisSlice_d = imread(fullFileName_d);
A(:,:,slice) = thisSlice_d;

end

S = size(A);
for i = 1:116
    i
B = A;
B(B~=i) = 0;
for j = 1:S(3)
    if sum(sum(B(:,:,j))) > 0
    F = regionprops(B(:,:,j),'MajorAxisLength');
    C(j) = max([F.MajorAxisLength]);
    end
D(i) = max(C);
end

end
E = D*.454545;