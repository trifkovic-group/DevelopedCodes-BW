clc
clear

folder = 'April20-C6°Cmin-1Run2(12-21-45).csv';

T = [4 10 15 19];
FileN = dir('*.tif');

mkdir('BWimages')

for i = 1:length(FileN)-4
    
    FileName = FileN(i).name;
    
    fs = 8;
    A = imread(FileName);
    gr = rgb2gray(A);
    grfilt = imfilter(gr,ones(fs)/fs^2,'symmetric');
    BW = imbinarize(grfilt,'adaptive','ForegroundPolarity','dark','sensitivity',0.54);



    MF = imfilter(1-BW,ones(3));
    MF(MF>3) = 0;
    
    [FD,B,C] = BoxCountfracDim(MF);
    
    figure(2)
    imshow(MF)
    
    figure(1)
    imshow(A)
    
    FN(1,i) = {FileName};
    FN(2,i) = {FD};
    F(i) = FD;
    FN(3,i) = {sum(sum(1-BW))/(1024^2)};
    
    imwrite(MF,['BWimages/' FileName])
    
end

 fid = fopen(folder, 'w') ;
 fprintf(fid, '%s,', FN{1,1:end-1}) ;
 fprintf(fid, '%s\n', FN{1,end}) ;
 fclose(fid) ;

 dlmwrite(folder, FN(2:end,:), '-append') ;
