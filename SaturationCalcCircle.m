clc
clear
%Naming Convention for variables - C: CrudeOil, W: Water, B: Blue, R: Red,
%G: Green
WFileName = input('Input name of pre flooded image: ','s');
CFileName = input('Input name of oil flooded image: ','s');
ci = input('Input center and radius of circular mask in format [VerticalCenter HorizontalCenter Radius], suggested values are [1354 1592 1083]:');
CO = imread(CFileName);
WCO = imread(WFileName);
CO = double(CO);
WCO = double(WCO);

%Separate RGB values into separate matrices
CB = CO(:,:,3);
CR = CO(:,:,1);
CG = CO(:,:,2);

WB = WCO(:,:,3);
WR = WCO(:,:,1);
WG = WCO(:,:,2);

%apply a 100x100 averaging filter to account for changes in brightness
% h = ones(100)/100^2;
% CBavg = imfilter(CB,h);
% CB = CB - CBavg;
% CRavg = imfilter(CR,h);
% CR = CR - CRavg;
% CGavg = imfilter(CG,h);
% CG = CG - CGavg;
% 
% WBavg = imfilter(WB,h);
% WB = WB - WBavg;
% WRavg = imfilter(WR,h);
% WR = WR - WRavg;
% WGavg = imfilter(WG,h);
% WG = WG - WGavg;

%create a circular mask to only look at more central region
S1 = size(CO);
S2 = size(CB);

%ci = [round(S1(1)/2) round(S1(2)/2-100) round(S1(1)/2.5)];

[xx,yy] = ndgrid((1:S1(1))-ci(1),(1:S1(2))-ci(2));
mask = (xx.^2 + yy.^2)<ci(3)^2;

%Find oil but comparing red and blue channels and apply mask
CCOM = CO.*mask;

RB = CR-CB;
RB = RB.*mask;
RB(RB<50) = 0;
RB(RB>0) = 1;

RB2 = WR-WB;
RB2(RB2<50) = 0;
RB2(RB2>0) = 1;
RB2 = RB2.*mask;

RB3 = WB./(WR+.001);
RB3 = RB3.*mask;
RB3(RB3>.75) = 0;
RB3(RB3>0) = 1;

CO2 = CO;
CO2(:,:,1) = CO2(:,:,1).*RB;
CO2(:,:,2) = CO2(:,:,2).*RB;
CO2(:,:,3) = CO2(:,:,3).*RB;

WCO2 = WCO;
WCO2(:,:,1) = WCO2(:,:,1).*RB2;
WCO2(:,:,2) = WCO2(:,:,2).*RB2;
WCO2(:,:,3) = WCO2(:,:,3).*RB2;

%Apply linear opening operations to remove thin features that appear due to
%reflection 
se = strel('line',5,45);
se2 = strel('line',5,135);
CO3 = imopen(CO2,se);
CO3 = imopen(CO3,se2);
WCO3 = imopen(WCO2,se);
WCO3 = imopen(WCO3,se);

%Count pixels
Oil = WCO3(:,:,1);
Oil(Oil>0) = 1;
OilCount = sum(sum(Oil));
Flooded = CO3(:,:,1);
Flooded(Flooded>0) = 1;
FloodedCount = sum(sum(Flooded));
Sat = FloodedCount/OilCount;

%Save test file
if exist('OilSaturation.txt','file') == 2
    fid=fopen('OilSaturation.txt','a');
    fprintf(fid, '%s\r\n', [CFileName ': ' num2str(Sat)]);
    fclose(fid);
else
    fid=fopen('OilSaturation.txt','w');
    fprintf(fid, '%s\r\n', [CFileName ': ' num2str(Sat)]);
    fclose(fid);
end
imwrite(CO3/255,[CFileName 'Output.png'])

figure(1)
imshow(WCO3/255)
figure(2)
imshow(CO3/255)
figure(3)
imshow(CCOM/255)