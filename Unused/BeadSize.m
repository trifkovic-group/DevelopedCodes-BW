clc
clear

A = imread('BeadSep\Beads1.tif');
A = A(:,:,1);

level = isodata(A);
bw = im2bw(A,.23);
% imshow(bw)
A1 = bw(70:160,84:210);
A2 = bw(182:298,84:210);
[I1,J1] = find(A1 == 1);
[I2,J2] = find(A2 == 1);

[X1,Y1,R1] = circfit(I1,J1)
[X2,Y2,R2] = circfit(I2,J2)