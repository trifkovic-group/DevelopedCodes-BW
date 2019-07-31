clc
clear

%Empty matrix to speed up loop, size of (x,2) where x is number of time
%steps
corr_offset = zeros(1054:2);

%Loop through time steps CNC Hydrophobic.lif_wide bidrectional_t000_z0_ch00.tif

for Z = 0:0
Z    
z= num2str(Z);
A = imread(['CNC-Morwet Hydrophobic.lif_middle wide_t000_z0_ch02.tif']);
for i = 1:5
    A = imfilter(A,ones(5)/25,'symmetric');
end

for t = 1:1
    %t %update on how many time steps are completed
    %read images
    if t < 9
        ns = ['00'];
    elseif t < 99
        ns = ['0'];
    else
        ns = [];
    end
    
    T = A;
    A = imread(['CNC-Morwet Hydrophobic.lif_middle wide_t' ns num2str(t+1) '_z' z '_ch02.tif']);
    AP = A;
    %averaging filtr on images
    for i = 1:5
        A = imfilter(A,ones(5)/25,'symmetric');
    end
    AP = T;
    %crop template (current slice image)
    T = T(15:end-15,10:end-100);
    
    %perfrom cross correlation, finding how far the template has moved over
    %one time step, effectively finding the velocity in pixels of the
    %entire image
    cc = normxcorr2(T,A);
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset(t+1,:) = [ (ypeak-size(A,1)) (xpeak-size(A,2)) ];
end

D(:,Z+1) = corr_offset(:,2)+75;

end


% PixelOffset = corr_offset+50;
% Vel = PixelOffset*0.284/0.053; %us/s

% co2 = corr_offset;
% dx = co2(:,2);
% dy = co2(:,1);
% dx2 = dx;
% dy2 = dy;
% meddx = median(dx);
% meddy = median(dy);
% 
% dy2(dx<-25) = meddy;
% dx2(dx<-25) = meddx;
% dy2(dx>5) = meddy;
% dx2(dx>5) = meddx;