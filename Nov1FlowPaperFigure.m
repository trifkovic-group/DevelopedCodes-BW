clc
clear
for j = 0:9
    A = imread(['CNC Hydrophobic.lif_narrow not bidrectional_Crop001_t' num2str(j) '_z05_ch00.tif']);
    B = A;
    for k = 1:5
        B = imfilter(B,ones(5)/25,'symmetric');
    end
    
    Z(:,:,j+1) = B;
end