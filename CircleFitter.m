clc
clear

%Name of droplet data set
S1='EMU_0_ch1.boundary';
S3='.tif';

Nimages = 50;
ImageStart = 0;
pixels = size(imread([S1 num2str(Nimages) '.tif']));
A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);

%Load the 2 image sets, sections needs adjusting based on number of images
for slice = ImageStart : Nimages
    
    if slice < 10
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


x0 = [1 1 1];

for i = 1:max(max(max(A)))
%for i = 1:1
    ind = find(A == i);
    [X,Y,Z] = ind2sub(size(A),ind);
    bestx = [];
    Ej = [];
    for j = min(Z):max(Z)
      fun = @(x)SSECircEval(x,X(Z==j),Y(Z==j));
%     Z = Z*1.5;
%     [Center_LSE(i,:),Radius_LSE(i,:)] = sphereFit([X Y Z]);
%     x0 = [1 1 1 1];

    [bestx(j-min(Z)+1,:),Ej(j-min(Z)+1)] = fminsearch(fun,x0);    
    end
    bestx2(i) = {[bestx Ej'/length(X)]};
    
    bestx3(i,:) = [mean(bestx(:,1)) mean(bestx(:,2)) max(abs(bestx(:,3)))];
end

% bestx
% Radius_LSE
% Center_LSE
bestx3