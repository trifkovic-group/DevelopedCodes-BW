clc
clear

%Name of droplet data set
S1='Bound';
S3='.tif';

Nimages = 194;
ImageStart = 0;
pixels = size(imread([S1 num2str(Nimages) '.tif']));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);
E = table();

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    if slice < 10
        S2 = ['00' num2str(slice)];
    elseif slice < 100
        S2 = ['0' num2str(slice)];
    else
        S2 = num2str(slice);
    end
     S=[S1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice_d = imread(S);
    A(:,:,slice-(ImageStart-1)) = thisSlice_d;   
end

for i = 1: max(max(max(A)))
    ind = find(A == i);
    [X,Y,Z] = ind2sub(size(A),ind);
    %B = zeros(size(A));
    %B(ind) = i;
    Z = Z*0.148395/.0581753;
    [Center_LSE(i,:),Radius_LSE(i,:)] = sphereFit([X Y Z]);
    %fun = @(x)SSESpherEval(x,X,Y,Z);
    %x0 = [1 1 1 1];
    %bestx(i,:) = fminsearch(fun,x0);    
end
%bestx
Center_LSE(:,3) = Center_LSE(:,3)/5;
%Center_LSE