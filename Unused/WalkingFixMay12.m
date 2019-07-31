%Note: Images used are exported from LAS X and unedited

%Name of data set before index and file type
a1 = 'Project001.lif_4D_t';%update for project number
a2 = '_z';
a3='.tif';


Nimages = 26; %Total number of images in a data set
Ntslices = 100; %Total number of time slices
pixels = size(imread([a1,'000',a2,'00',a3])); % Read dimensions of images
array = zeros(pixels(1), pixels(2), Nimages); 

%a variables are the names of the data, updated each loop to load all files
for tslice = 0:(Ntslices-1)
    tslice
    S4 = int2str(tslice);
    for slice = 0 : (Nimages-1)
        
        S2=int2str(slice);
        
        if slice<10
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,'0',int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,'0',int2str(slice),a3];
            end
        elseif slice<100
            if tslice < 10
                a = [a1,'00',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<100
                a = [a1,'0',int2str(tslice),a2,int2str(slice),a3];
            elseif tslice<1000
                a = [a1,int2str(tslice),a2,int2str(slice),a3];
            end
            
        end
        
        %a contains the full file name for each image
        fullFileName = fullfile(a);     
        thisSlice = imread(a);
        thisSlice = thisSlice(:,:,1:3);%change .tif file to rgb
        array(:,:,slice+1,tslice+1) = rgb2gray(thisSlice); %change rgb to grayscale
        
    end

end

dispx = zeros(Nimages,Ntslices-1);
dispy = zeros(Nimages,Ntslices-1);

for tslice = 0:(Ntslices-2)
    for slice = 0:(Nimages-1)
        slice %update on how many time steps are completed

        %read images
        A = array(:,:,slice+1,tslice+2);
        T = array(:,:,slice+1,tslice+1);

        %averaging filtr on images
        A = imfilter(A,ones(5)/25);
        T = imfilter(T,ones(5)/25);

        h = fspecial('prewitt');

        A = imfilter(A,h);
        T = imfilter(T,h);

        %crop template (current slice image)
        T = T(6:26,25:end);

        %perfrom cross correlation, finding how far the template has moved over
        %one time step, effectively finding the velocity in pixels of the
        %entire image
        cc = normxcorr2(T,A);
        [max_cc, imax] = max(abs(cc(:)));
        [ypeak, xpeak] = ind2sub(size(cc),imax(1));

        xoffset = (xpeak-size(A,2));
        yoffset = (ypeak-size(A,1));

        %displacement between current and next timeslice in x direction
        dispx(slice+1,tslice+1) = xoffset;
        dispy(slice+1,tslice+1) = yoffset+5;

      
    end
end


corrVec = zeros(Nimages,Ntslices-1);
velshift = zeros(Nimages,Ntslices-1);

for slice = 1:Nimages
    tslice = 1;
    
    while tslice < Ntslices-1
        
        %find the average velocity between 2 time steps of an image and 
        %determine the translation needed to correct every second time step
        velshift(slice,tslice) = (dispx(slice,tslice) + dispx(slice,tslice+1))/2;
        corrVec(slice,tslice+1) = velshift(slice,tslice) - dispx(slice,tslice);
        
        tslice = tslice + 2;
    end

end

newImages = zeros(pixels(1),pixels(2),Ntslices,Nimages);
break;

for tslice = 1:(Ntslices-1)
    for slice = 1:Nimages-1
        %translate each image individually in the x direction
        newImages(:,:,tslice,slice) = imtranslate(array(:,:,slice,tslice),[corrVec(slice,tslice),0]);
        
        name = ['TS',int2str(tslice),'.tiff'];
        pathway = ['TestOutput/',name];%modify to put in different folder
        file = fullfile(pathway);
        image = uint8(newImages(:,:,tslice,slice)*2); %change to 8 bit unsigned integers

        %create 3d .tiff file of new images for each time step
        if slice == 1
            imwrite(image,file);
        else
            imwrite(image,file,'WriteMode','append','Compression','none');
        end

    end
end

