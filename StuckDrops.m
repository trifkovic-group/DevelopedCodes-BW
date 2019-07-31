clc
clear

fname = 'CNC Hydrophobic.lif_xyt after_t';

for i = 0:231
    if i < 10
        A(:,:,i+1) = imread([fname '00' num2str(i) '_ch01.tif']);
    elseif i < 100
        A(:,:,i+1) = imread([fname '0' num2str(i) '_ch01.tif']);
    else
        A(:,:,i+1) = imread([fname num2str(i) '_ch01.tif']);
    end
end

B = mean(A,3);
C = mean(B,3);
D = imfilter(C,ones(5)/5^2,'symmetric');
E = imbinarize(D/255,'adaptive');
BlackWhite = imbinarize(D/255,0.08);

i = 1;
    DistMap = bwdist(1-BlackWhite);
    IsolatedCircles = zeros(size(BlackWhite));
    
    
    while max(max(DistMap > 6))
        DistMap = bwdist(1-BlackWhite);
        LargestDropCenter = find(DistMap == max(max(DistMap)),1);
        DropSize(i) = DistMap(LargestDropCenter);
        DropCenter = zeros(size(BlackWhite));
        DropCenter(LargestDropCenter) = 1;
        
        SingleDropDistMap = bwdist(DropCenter);
        BlackWhite(SingleDropDistMap<DropSize(i)) = 0;
        IsolatedCircles(SingleDropDistMap<DropSize(i)*1.04) = 1;
        i = i+1;
    end