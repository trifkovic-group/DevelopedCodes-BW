clc
clear

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
%B = A(:,:,1);
B(B>255) = 255;

%imshow(medfilt2(B,[5,5])/255)

a = ones(5,5)/(5*5);
C = imfilter(B,a);

D = imbinarize(B,50);
E = imfilter(double(D),ones(32,32)/(32*32),'symmetric');

B(E<max(max(E(:,460:end)))*1.1) = 0;

F = imfilter(B,ones(32,32)/(32*32),'symmetric');
bw = imbinarize(F,20);

circ = zeros(size(B));
for i = 1:512
    i
    for j = 300:450
        DMM = zeros(512,512);
        DMM(i,j) = 1;
        DM = bwdist(DMM);
        

        CoS = DM(bw>0);
        [y,x] = hist(CoS,100);
        dy = diff([0 y]);
        circ(i,j) = mean(dy(1:5));
    end
end

circ2 = circ;
circ2(bw>0) = 0;
bw2 = bw;
if max(max(circ2>100))
while max(max(circ2)) > max(max(circ))*.825
    in = find(circ2 == max(max(circ2)));
    [I J] = ind2sub(size(circ2),in);
    i = round(mean(I));
    j = round(mean(J));
    
    DMM = zeros(512,512);
    DMM(i,j) = 1;
    DM = bwdist(DMM);
    CoS = DM(bw>0);
    [y,x] = hist(CoS,100);
    dy = diff([0 y]);
    circ2(i,j) = mean(dy(1:5));
    
    circ2(DM<x(find(dy(1:5) == max(dy(1:5))))) = 0;
    bw2(DM<x(find(dy(1:5) == max(dy(1:5))))) = 0;
    
end
end