clc
clear

folder = 'C0.1R3Z1.csv';

T = [4 10 15 19];
FileN = dir('*.tif');


for i = 1:9 %length(FileN)
    
    FileName = FileN(i).name;
    
    fs = 8;
    A = imread(FileName);
    gr = rgb2gray(A);
    grfilt = imfilter(gr,ones(fs)/fs^2,'symmetric');
    BW = imbinarize(grfilt,'adaptive','ForegroundPolarity','dark','sensitivity',0.54);
    figure(2)
    imshow(1-BW)
    figure(1)
    imshow(A)
    
    
    
    [FD,B,C] = BoxCountfracDim(1-BW);
    imshow(A)
    
    FN(1,i) = {FileName};
    FN(2,i) = {FD};
    F(i) = FD;
    FN(3,i) = {sum(sum(1-BW))/(1024^2)};
    
    imwrite(1-BW,['BWimages/' FileName])
    
end

 fid = fopen(folder, 'w') ;
 fprintf(fid, '%s,', FN{1,1:end-1}) ;
 fprintf(fid, '%s\n', FN{1,end}) ;
 fclose(fid) ;

 dlmwrite(folder, FN(2:end,:), '-append') ;
