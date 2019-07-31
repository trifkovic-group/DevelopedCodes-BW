clc
clear

%Name of droplet data set
S1='Droplets';
S3='.tif';

%Name of particle data set
N1='Particles';
N3='.tif';

Nimages = 51; %Total number of images in a data set
pixels = size(imread([S1,'00',S3])); % Read dimensions of images
array_p = zeros(pixels(1), pixels(2), Nimages); 
array_d = zeros(pixels(1), pixels(2), Nimages);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = 1 : Nimages

    S2=int2str(slice);
    if slice<10
        S=[S1,'0',S2,S3];
%      elseif slice<100; 
%         S=[S1,'0',S2,S3];
    else slice>100;
        S=[S1,S2,S3];
    end
    
        N2=int2str(slice);
    if slice<10
        N=[N1,'0',N2,N3];
%      elseif slice<100;
%         N=[N1,'0',N2,N3];
    else slice>100;
        N=[N1,N2,N3];
    end
    
%_d is droplet, _p is particle, text value is the name of the folder in
%which the data is stored
fullFileName_d = fullfile('Droplets', S);
fullFileName_p = fullfile('Particles', N);

thisSlice_d = imread(fullFileName_d);
thisSlice_p = imread(fullFileName_p);
array_p(:,:,slice) = thisSlice_p;
array_d(:,:,slice) = thisSlice_d;

end
check = 0;
FreeVox = 0;

%Checks if each particle voxels has a straight line connection to droplet
%voxel without passing through empty space.  If so, that voxels is free
%floating
for n = 1:Nimages
    n
    for j = 1:pixels(2)
        for i = 2:pixels(1)-2
            
            if array_p(i,j,n) == 1
                    %Check in negative x direction
                    for x = i:-1:1
                        if array_d(x,j,n) == 1
                            break                            
                        elseif array_p(x,j,n) == 0
                            check = check + 1;
                            break
                        end
                    end
                    %Check in positive x direction
                    if check == 1 %Loop will not continue if already found a connection to a droplet voxel
                    for x = i:pixels(1)
                        if array_d(x,j,n) == 1
                            break                            
                        elseif array_p(x,j,n) == 0
                            check = check + 1;
                            break
                        end
                    end
                    
                    
                    if check == 2
                    for y = j:-1:1
                        if array_d(i,y,n) == 1
                            break                            
                        elseif array_p(i,y,n) == 0
                            check = check + 1;
                            break
                        end
                    end
                    
                    
                    if check == 3
                    for y = j:pixels(2)
                        if array_d(i,y,n) == 1
                            break                            
                        elseif array_p(i,y,n) == 0
                            check = check + 1;
                            break
                        end
                    end
                    
                    if check == 4
                    for z = n:-1:1
                        if array_d(i,j,z) == 1
                            break                            
                        elseif array_p(i,j,z) == 0
                            check = check + 1;
                            break
                        end
                    end
                    
                    if check == 5
                    for z = n:Nimages
                        if array_d(i,j,z) == 1
                            break                            
                        elseif array_p(i,j,z) == 0
                            check = check + 1;
                            break
                        end
                    end
                    %Ending if statements that check if a droplet voxels
                    %has already been found
                    end
                    end
                    end
                    end
                    end
                    %if no droplet was found in any direction, that voxels
                    %is free floating
                if check == 6
                    FreeVox = FreeVox + 1;
                end
                check = 0;
            end
        end
    end
end

%Calculate % volume at interface
volcov = 1 - FreeVox/sum(sum(sum(array_p)))
