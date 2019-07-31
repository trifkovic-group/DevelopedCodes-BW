clc
clear
tic
xPH = [7.38 6.87 6.62 6.32 5.79 5.38 5.08 4.86 4.55 4.28 4.03 3.75 3.45 3.07 2.5 2.21 1.96 1.58 1.31 1.11 0.95];

R1curve = [2.062081762 2.297072148 2.415370017 2.58519989 2.922849508 3.173214053 3.390199288 3.53154562 3.572325708 3.645223973 3.806457465 3.890302064 3.880679244 3.88750912 3.428749044 2.777686378 1.982224322 1.036436883 0.778400333 0.729282836 0.725368176];
R2curve = [0.591564811 0.583276732 0.568050355 0.553644069 0.532809441 0.519470966 0.508974973 0.504738524 0.507182092 0.529510556 0.564138915 0.652450509 0.837870451 1.350530928 3.828729906 6.676436415 9.8863383 13.89975419 15.08614866 15.57400225 15.60991985];

frames = 400;
s = [512 512 frames];
Frame2 = zeros(s);
Frame6 = zeros(s);
Frame8 = zeros(s);
PHinit = zeros(s(1),s(2));
PHoutfilt = zeros(s);
fname = 'EC8 Lyso Al anode Iron cathode pH6.lif_1mA-cm2_Crop001_t';

% p1 =      -1.006;
% p2 =       17.74;
% p3 =      -129.6;
% p4 =       501.6;
% p5 =       -1082;
% p6 =        1229;
% p7 =        -566;
% 
% p1 =     -0.8065  ;
% p2 =       14.24  ;
% p3 =      -104.2  ;
% p4 =         404  ;
% p5 =      -873.1  ;
% p6 =       993.9  ;
% p7 =      -456.3  ;

p1 = -0.4167;
p2 = 4.151;
p3 = -14.89;
p4 = 20.8;
p5 = -1.081;

f1 = @(x) p1*x.^4 + p2*x.^3 + p3*x.^2 + p4.*x + p5;
% f1 = @(x) p1*x.^6 + p2*x.^5 + p3*x.^4 + p4*x.^3 + p5*x.^2 + p6*x + p7;

r1 =     -0.1802;
r2 =       1.704;
r3 =      -5.722;
r4 =       8.328;
r5 =      -2.561;

f2 = @(x) r1*x.^4 + r2*x.^3 + r3*x.^2 + r4*x + r5;

% p1 = -4.03e-05;
% p2 = 0.001624;
% p3 = -0.02524;
% p4 = 0.1911;
% p5 = -0.8003;
% p6 = 3.86;
% 
% r1 = -1.006;
% r2 = 17.74;
% r3 = -129.6;
% r4 = 501.6;
% r5 = -1082;
% r6 = 1229;
% r7 = -566;

for i = 1:frames
    if i < 10
        Frame2(:,:,i) = double(imread([fname '000' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '000' num2str(i) '_ch01.tif']));
        Frame8(:,:,i) = double(imread([fname '000' num2str(i) '_ch02.tif']));
    elseif i < 100
        Frame2(:,:,i) = double(imread([fname '00' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '00' num2str(i) '_ch01.tif']));
        Frame8(:,:,i) = double(imread([fname '00' num2str(i) '_ch02.tif']));
    elseif i < 1000
        Frame2(:,:,i) = double(imread([fname '0' num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname '0' num2str(i) '_ch01.tif']));
        Frame8(:,:,i) = double(imread([fname '0' num2str(i) '_ch02.tif']));
    else
        Frame2(:,:,i) = double(imread([fname num2str(i) '_ch00.tif']));
        Frame6(:,:,i) = double(imread([fname num2str(i) '_ch01.tif']));
        Frame8(:,:,i) = double(imread([fname num2str(i) '_ch02.tif']));
    end
    
    Filt2 = imfilter(Frame2(:,:,i),ones(32)/32^2,'symmetric');
    Filt6 = imfilter(Frame6(:,:,i),ones(32)/32^2,'symmetric');
    Filt8 = imfilter(Frame8(:,:,i),ones(32)/32^2,'symmetric');
    
    NL2 = max(max(Filt2(:,500:end)));
    NL6 = max(max(Filt6(:,500:end)));
    NL8 = max(max(Filt8(:,500:end)));
    
    Filt2(Filt2 < NL2) = 0;
    Filt6(Filt6 < NL6) = 0;
    Filt8(Filt8 < NL8) = 0;
    Filt6(Filt6 == 0) = NL6;
    
    R1 = Filt2./Filt6;
    R2 = Filt8./Filt6;
    
%     PHR1 = r1.*R1.^6 + r2.*R1.^5 + r3.*R1.^4 + r4.*R1.^3 + r5.*R1.^2 + r6.*R1 + r7;
%     PHR2 = p1.*R2.^5 + p2.*R2.^4 + p3.*R2.^3 + p4.*R2.^2 + p5.*R2 + p6;
%     %PHR3 = 
    PHR1 = f1(R1);
    PHR2 = f2(R1);
     

%     PHinit(PHinit == p6) = 0;
%     PHinit(PHinit<2 & PHinit ~= 0) = 2;
%     PHinit(PHinit>5) = 5;
    PHR2(PHR2<1) = 1;
    PHR2(PHR2>3) = 3;
    PHR1(PHR1<3) = 3;
    PHR1(PHR1>7) = 7;
    
    PHinit(R2>1.35) = PHR2(R2>1.35);
    PHinit(R2<=1.35) = PHR1(R2<=1.35);
    PHoutfilt(:,:,i) = imfilter(PHinit,ones(25)/25^2,'symmetric');
    c(i) = max(find(diff(mean(PHoutfilt(:,:,i)))==max(diff(mean(PHoutfilt(:,:,i))))));
    PHfiller = PHoutfilt(:,abs(c(i)-50):end,i);
    PHfiller(PHfiller > (mean(PHoutfilt(:,c(i),i)))) = 0;
    se = strel('disk',20);
    se2 = strel('disk',30);
    
    PHoutfilt(:,abs(c(i)-50):end,i) = PHfiller;
    PHoutfilt(:,:,i) = imclose(PHoutfilt(:,:,i),se);
    PHoutfilt(:,c+30:end,i) = 0;
    PHfiller = PHoutfilt(:,:,i);
    PHfiller(PHfiller < 4) = 0;
    PHfiller(PHfiller > 0) = 1;
    PHfiller2 = imopen(PHfiller,se);
    PHoutfilt(:,:,i) = imclose(PHoutfilt(:,:,i) - PHoutfilt(:,:,i).*(PHfiller-PHfiller2),se);
    PHoutfilt(:,:,i) = imopen(PHoutfilt(:,:,i),se);
end
toc
X = [445 512 512 445];
Y = [512 512 1 1];

PHoutfilt(PHoutfilt == 0) = -Inf;
PHoutfilt(1,1,:) = 0;
for i = 1:frames
    [C,h] = contourf(PHoutfilt(:,:,i));
    clabel(C,h)
    axis off
    colorbar
    caxis([0 7])
    title(['t =' num2str(i*(165/1855)) '(s)'])
    patch(X,Y,[0.5 0.5 0.5])
    saveas(gcf,[num2str(i) '.tif']);
end