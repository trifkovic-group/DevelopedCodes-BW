clc
clear

%Name of droplet data set
S1='Below MMP Figure ';
S3='.jpg';

S1 = input('Enter file name up to number: ','s');
Nimages = input('Enter number of images being analyzed: ');

ImageStart = 1;
pixels = size(imread([S1 num2str(Nimages) '.jpg']));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);
E = table();

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    S2=int2str(slice);
    S=[S1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice_d = imread(S);
    thisSlice_d = imfilter(thisSlice_d,ones(5)/25);
    A(:,:,slice-(ImageStart-1)) = thisSlice_d;
    
    [N,C] = imhist(thisSlice_d);
    F = [];
    for i=1:245
        F(length(F)+1:length(F)+N(i)) = C(i);
    end
    level = (mean(F) + 2.5*std(F))/255;
    
    BW = imbinarize(thisSlice_d,level);
    imwrite(BW*255,['binary' num2str(slice) '.tiff'])
    CC = bwconncomp(BW);
    D = regionprops(CC,'Area','MinorAxisLength','MajorAxisLength','Extent','Centroid','BoundingBox');
    X = [];
    
    for i = 4:4:length([D.Area])*4
        Y = [D.BoundingBox];
        X(length(X)+1) =  Y(i);
    end
    
    X2 = ((X>max(X)*.8));
    X3 = ( [D.Area] > max([D.Area])/3);
    X4 = ( [D.Extent] > 0.8);
    X5 = X2.*X3.*X4;
    
    D = D(logical(X5));
    
    
    if isempty(D) == 0
        %[H(1,:,slice),H(2,:,slice)] = D.Centroid;
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