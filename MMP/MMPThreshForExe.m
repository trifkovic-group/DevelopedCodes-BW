clc
clear

%Name of droplet data set
S1='Below MMP Figure ';
S3='.tif';

S1 = input('Enter file name up to number: ','s');
Nimages = input('Enter number of images being analyzed: ');
S3 = input('Enter file type (.tif,.jpg,etc..): ','s');

ImageStart = 1;
pixels = size(imread([S1 num2str(Nimages) S3]));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);
E = table();

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    S2=int2str(slice);
    S=[S1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice = imread(S);
    if min(size(thisSlice)) == 3
        thisSlice = rgb2gray(thisSlice);
    end
    thisSlice = imfilter(thisSlice,ones(5)/25);
    A(:,:,slice-(ImageStart-1)) = thisSlice;
    
    [N,C] = imhist(thisSlice);
    N = N - median(N);
    N(N<0) = 0;
    F = [];
    for i=1:255
        F(length(F)+1:length(F)+ceil(N(i))) = C(i);
    end
    level = (mean(F) + 3*std(F))/255;
    
    BW = imbinarize(thisSlice,level);
    CC = bwconncomp(BW);
    
    D = regionprops(CC,'Area','MinorAxisLength','MajorAxisLength','Extent','Centroid','BoundingBox');
    X = [];
    
    for i = 4:4:length([D.Area])*4
        Y = [D.BoundingBox];
        X(length(X)+1) =  Y(i);
    end
    
    X2 = ((X>max(X)*.7));
    X3 = ( [D.Area] > max([D.Area])/10);
    X4 = ( [D.Extent] > 0.7);
    X5 = X2.*X3.*X4;
    
    
    BW = double(BW);
    for i = 1:length(X5)
        if X5(i) == 1
            BW(CC.PixelIdxList{i}) = 1;
        else
            BW(CC.PixelIdxList{i}) = 0.5;
        end
    end
    imwrite(BW,['binary' num2str(slice) '.tiff'])
    
    D = D(logical(X5));
    
    
    if isempty(D) == 0
        FrameNumber = ones(length(D),1)*slice;
        BubbleNumber = [1:length(D)]';
        D = [table(FrameNumber) table(BubbleNumber) struct2table(D)];
        E = [E;D];
        
        
        
        G(slice) = {D};

    end
    
    
end

writetable(E,['Output.csv'])

if exist('G') == 0
    disp('No bubbles found')
    return
else
    G %xlswrite('Output',E)
end