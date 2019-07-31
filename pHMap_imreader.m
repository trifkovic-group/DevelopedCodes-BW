ch = [5 6 12 16]-1; 
A = zeros(512,512,4);
for i = 1:4
    if ch(i) < 10
        A(:,:,i) = imread(['Produced water Lyso NP.lif_Main Movie_Crop001_ch0' num2str(ch(i)) '.tif']);
    else
        A(:,:,i) = imread(['Produced water Lyso NP.lif_Main Movie_Crop001_ch' num2str(ch(i)) '.tif']);
    end
end

B = A(:,:,3) + A(:,:,4);
%B = A(:,:,2);
B(B>255) = 255;

%imshow(medfilt2(B,[5,5])/255)

a = ones(5,5)/(5*5);
C = imfilter(B,a);

D = imbinarize(B,50);
E = imfilter(double(D),ones(32,32)/(32*32),'symmetric');

figure(1)
imshow(B/255)

figure(2)
imshow(E*10)

B(E<max(max(E(:,460:end)))*1.1) = 0;

figure(3)
imshow(B/255)

F = imfilter(B,ones(32,32)/(32*32),'symmetric');

DMM = zeros(512,512);
DMM(160,400) = 1;
DM = bwdist(DMM);

bw = imbinarize(F,20);
CoS = DM(bw>0);
[y,x] = hist(CoS,100);
plot(diff(y))