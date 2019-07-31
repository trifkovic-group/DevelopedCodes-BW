clc
clear

%Name of droplet data set
S1='Mask2';
S3='.tif';

%Name of particle data set
N1='Particles2';
N3='.tif';

Nimages = 155; %Total number of images in a data set
pixels = size(imread([S1,'000',S3])); % Read dimensions of images
array_p = zeros(pixels(1), pixels(2), Nimages+1); 
array_m = zeros(pixels(1), pixels(2), Nimages+1);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = 0 : Nimages

    S2=int2str(slice);
    if slice<10
        S=[S1,'00',S2,S3];
     elseif slice<100
        S=[S1,'0',S2,S3];
    else slice>100;
        S=[S1,S2,S3];
    end
    
        N2=int2str(slice);
    if slice<10
        N=[N1,'00',N2,N3];
     elseif slice<100
        N=[N1,'0',N2,N3];
    else slice>100;
        N=[N1,N2,N3];
    end
    
%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
fullFileName_m = fullfile('NaOHS9', S);
fullFileName_p = fullfile('NaOHS9', N);

thisSlice_m = imread(fullFileName_m);
thisSlice_p = imread(fullFileName_p);
array_p(:,:,slice+1) = thisSlice_p;
array_m(:,:,slice+1) = thisSlice_m;
end

AtI = array_p(array_m > 0);
AtI = sum(array_p(array_m > 0));
Tot = sum(sum(sum(array_p)));
PercentAtI = AtI/Tot

NPVF = mean(array_p(array_m==0))/255
