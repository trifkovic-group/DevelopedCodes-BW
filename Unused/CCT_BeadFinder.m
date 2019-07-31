clc
clear

%Load Templates for comparions during cross correlation 
A = imread('cropped/BoaL0725.tif');
A = imcomplement(A);
T = A(40:105,50:127);
T2 = A(137:195,47:130);
A = A(:,:,1);
bw2 = im2bw(A,.53);
%First and third pieces of the name of the dataset, middle piece is a
%changing number and requires a loop
N1='cropped/BoaL';
N3='.tif';

%Loop for looking at each image individually 
for n = 725:725
    %Middle peice of dataset name
    N2=int2str(n);
    if n<1000;
        N=[N1,'0',N2,N3]; 
    else
        N=[N1,N2,N3];
    end
        
    A = imread(N);
    A = imcomplement(A);
    A = A(:,:,1);
    
    % cross-correlation used to find regions of the image that match most
    % closely with the template loaded earlier
    cc = normxcorr2(T,A);
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [ (ypeak-size(A,1)) (xpeak-size(A,2)) ];
    
    cc2 = normxcorr2(T2,A);
    [max_cc2, imax2] = max(abs(cc2(:)));
    [ypeak2, xpeak2] = ind2sub(size(cc2),imax2(1));
    corr_offset2 = [ (ypeak2-size(A,1)) (xpeak2-size(A,2)) ];
    
%     figure(1)
%     imshow(T)
%     figure(2)
%     imshow(A)
    
    %Sizes of the image used, required for determining their locations
    %later
    S1 = size(T);
    S2 = size(T2);
    S3 = size(A);
    
    %Used for double checking corret location is being examined
    B = A(S3(1) + corr_offset(1) - S1(1) + 1 : S3(1) + corr_offset(1),S3(2) + corr_offset(2) - S1(2) + 1: S3(2) + corr_offset(2));
    B2 = A(S3(1) + corr_offset2(1) - S2(1) + 1 : S3(1) + corr_offset2(1),S3(2) + corr_offset2(2) - S2(2) + 1: S3(2) + corr_offset2(2));
    
    %threshold data
    bw = im2bw(A,.53);
    
    %Looks at where the template found the best match and uses this region
    %and assigns X/Y coordinates in those regions to the thresholded image
    A1 = bw(S3(1) + corr_offset(1) - S1(1) + 1: S3(1) + corr_offset(1),S3(2) + corr_offset(2) - S1(2) + 1: S3(2) + corr_offset(2));
    A2 = bw(S3(1) + corr_offset2(1) - S2(1) + 1 : S3(1) + corr_offset2(1),S3(2) + corr_offset2(2) - S2(2) + 1: S3(2) + corr_offset2(2));
    [I1,J1] = find(A1 == 1);
    [I2,J2] = find(A2 == 1);
    
    %Find the centers and radii of the circles by fitting the X/Y
    %coordinatse to a circle 
    [X1(n),Y1(n),R1(n)] = circfit(I1,J1);
    [X2(n),Y2(n),R2(n)] = circfit(I2,J2);
    y1(n) = S3(1) + corr_offset(1) - (S1(1) - X1(n));
    y2(n) = S3(1) + corr_offset2(1) - (S2(1) - X2(n));
end

y3 = y2(725:end) - y1(725:end);
x =[725:length(y3)+724];
plot(x,y3)
figure(2)
hist(y3,30)

% r1 = mean(R1(725:800));
% r2 = mean(R2(725:800));