clc
clear

%Name of data set before index and file type
S1='S';
S3='.tiff';

Nimages = 25; %Total number of images in a data set
pixels = size(imread([S1,'00',S3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%S variables are the names of the data, updated each loop to load all files
C = zeros(30,4,415);
for tslice = 0:0
    S4 = int2str(tslice);
    for slice = 0 : Nimages
        
        S2=int2str(slice);
        if slice<10
            S=[S1,'0',S2,S3];
        elseif slice<100
            S=[S1,S2,S3];
            
        end
        
        
        %S4 is the folder name corresponding to the current time slice
        fullFileName = fullfile(S4, S);     
        thisSlice = imread(fullFileName);
        array(:,:,slice+1,tslice+1) = thisSlice;
    end
    
    %Get volume and center information on the droplets
    A = bwconncomp(array(:,:,:,tslice+1));
    B = regionprops('table',A,'centroid','area');
    C(1:height(B),1:4,tslice+1) = [B.Area,B.Centroid];
end

Dist = bwdist(1-array);
irm = imregionalmax(Dist);

[x,y] = find(irm>0);
coord = [x y];
[m,n] = size(coord);

for i = 1 : m 
  for j = 1 : m
      dist(i, j) = sqrt((coord(i, 1) - coord(j, 1)) ^ 2 + ...
                        (coord(i, 2) - coord(j, 2)) ^ 2);
  end     
end


for i = 1:m
    while j > 0
        currentdistance = coord(1,:)
    end
end
