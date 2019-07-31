clc
clear

%Name of droplet data set
S1='FlocSettle';
S3='.bmp';

ImageStart = 1;
Nimages = 300000;

SettleDepth = zeros(1,Nimages - ImageStart + 1);
pixels = size(imread([S1  num2str(Nimages) '.bmp']));
%A = zeros(pixels(1), pixels(2), Nimages-ImageStart+1);

%Load the 2 image sets, sections needs adjusting based on number of images
%A = zeros(pixels(1),pixels(2),Nimages-ImageStart+1);
for slice = ImageStart : Nimages
    slice

        S2 = [num2str(slice)];
    
     S=[S1,S2,S3];
    
    %_d is droplet, _p is particle, text value is the name of the folder in
    %which the data is stored
    thisSlice_d = imread(S);
    %A(:,:,slice-(ImageStart-1)) = rgb2gray(thisSlice_d);  
    A = rgb2gray(thisSlice_d);  
    CS = A(305:345,495:500);
    for i = 1:length(CS)
        HAvg(i) = mean(CS(i,:));
    end
    HAvgf = medfilt1(HAvg,15);
    %SettleDepth(slice-(ImageStart-1)) = min(find(abs(diff(HAvgf(5:end))) ==  max(abs(diff(HAvgf(5:end))))));
    %SettleDepth(slice-(ImageStart-1)) = min(find(diff(HAvgf(5:end)) == min(diff(HAvgf(5:end)))));
    SettleDepth(slice-(ImageStart-1)) = find(movingslope(HAvgf(3:end),5,1,1) == min(movingslope(HAvgf(3:end),5,1,1)),1)+2;
    
    
    
end

figure(1)
plot(HAvg)
figure(2)
imshow(CS)
figure(3)
plot(movingslope(HAvgf,5,1,1))
figure(4)
imshow(thisSlice_d)
figure(5)
plot(medfilt1(SettleDepth,5))

% SD = medfilt1(SettleDepth,5);
% X = 1:300000;
% plot(X/60/15,(min(SD(1:30000))-SD(1:300000))/4.1)