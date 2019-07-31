clc
clear

%Load file
FileName = 'Freshly cleaved 1st area ed'; %Update to name of text
A = load([FileName '.txt']);
figure(1)
imshow(A/max(max(A)))

%set up band stop filter, may need to be changed to appropriate frequency
%range, which can be found by applying a fourier transform (fft function)
%and plotting the results
s = 256; %length of array
lowerf = 85;
upperf = 91;
[b,a] = butter(5,[lowerf*2/s upperf*2/s],'stop'); 

%Apply band stop filter
for i = 1:length(A)
    X = A(:,i);
    X3 = filtfilt(b,a,X);
    OUT(:,i) = X3;
end

%Save file
dlmwrite([FileName '_FT.txt'],OUT);