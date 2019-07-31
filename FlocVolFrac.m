% function [VFClay,VFBit,CL] = FlocVolFrac(fname,voxsize,stacksize)
clc
clear
voxsize = [0.481 0.481 0.09893];
stacksize = [1024 1024 99];

fname = 'Project day 1 1000 ppm HBfPE MA 42.lif_Series001_z';
hebitu = zeros(stacksize(1),stacksize(2),stacksize(3));
mfclay = hebitu;

for i = 1:stacksize(3)
     if i < 10
        claychan = double(imread([fname '00' num2str(i) '_ch01.tif']));
        bituchan = double(imread([fname '00' num2str(i) '_ch00.tif']));
    elseif i < 100
        claychan = double(imread([fname '0' num2str(i) '_ch01.tif']));
        bituchan = double(imread([fname '0' num2str(i) '_ch00.tif']));
    elseif i < 1000
        claychan = double(imread([fname num2str(i) '_ch01.tif']));
        bituchan = double(imread([fname num2str(i) '_ch00.tif']));
     end

     claychan = double(histeq(uint8(claychan)));
%      bituchan = double(histeq(uint8(bituchan)));
     for k = 1:3
        claychan = medfilt2(claychan);
     end
     
     hebitu(:,:,i) = bituchan;
     mfclay(:,:,i) = claychan;

end

% [c,x] = imhist(uint8(mfclay));
% c2 = c(c>max(c)/100);
% x2 = x(c>max(c)/100);
% CF = fit(x2,medfilt1(c2,5),'gauss2');
% CF = fit(x2,c2,'gauss2');
% y1 = max(CF.a1*exp(-((x2-CF.b1)/CF.c1).^2));
% y2 = max(CF.a2*exp(-((x2-CF.b2)/CF.c2).^2));
% %indexaroo = find([CF.a1 CF.a2] == max([CF.a1 CF.a2]));
% if y1 > y2
%     T = CF.b1-CF.c1/2;
% else
%     T = CF.b2-CF.c2/2;
% end

[c,x] = imhist(uint8(mfclay));
c = c(100:end);
x = x(100:end);
c2 = c(c>max(c)/100);
x2 = x(c>max(c)/100);
CF = fit(x2,medfilt1(c2,5),'gauss1');
CF = fit(x2,c2,'gauss1');

T = CF.b1-CF.c1/2;


bwclay = imbinarize(mfclay,T);
fm = zeros(3,3,3);
fm(1:end) =[0 0 0 0 voxsize(1)*voxsize(2) 0 0 0 0 0 voxsize(3)*voxsize(1) 0 voxsize(3)*voxsize(2) 0 voxsize(3)*voxsize(2) 0 voxsize(3)*voxsize(2) 0 0 0 0 0 voxsize(2)*voxsize(1) 0 0 0 0];
conm = imfilter(double(bwclay),fm,'symmetric');

bitfilt = imfilter(hebitu, ones(9)/9^2);
bitbw = imbinarize(bitfilt/255);

pe = conm.*bwclay;
out = zeros(size(conm));
out(pe>0) = sum(fm(:))-pe(pe>0);

VFClay = sum(bwclay(:))/(stacksize(1)*stacksize(2)*stacksize(3))
VFBit = sum(bitbw(:))/(stacksize(1)*stacksize(2)*stacksize(3))

SA = sum(out(:));
V = sum(bwclay(:))*voxsize(1)*voxsize(2)*voxsize(3);
CL = V/SA

figure(1)
plot(x2,c2)
hold on
plot(x2,CF.a1*exp(-((x2-CF.b1)/CF.c1).^2))
% plot(x2,CF.a2*exp(-((x2-CF.b2)/CF.c2).^2))
hold off
implay(bwclay)
