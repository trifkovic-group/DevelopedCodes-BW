clc
clear 

A = imread('NaOHSeries7.tif'); %Load labeled image of droplets
B = imread('Betweens.tif'); %Load labeled image of bridges between droplets

imshow(A*1000)
ObCount = max(max(A)); %Number of Objects
ConCount = max(max(B)); %Number of Bridges

Connections = zeros(ObCount,1); %How many connections each droplet has

for i = 1:ConCount %For each bridge, check what droplets it is briding
    [ConInda,ConIndb] = ind2sub([1024 1024],find(B == i));
    Adjacent = [];
    for j = 1:length(ConInda) %Check droplet pixels adjacent to bridge pixels
        if ConInda(j) > 1
            Adjacent(1,j) = A(ConInda(j)-1,ConIndb(j));
        end
        if ConInda(j) < 1024
            Adjacent(2,j) = A(ConInda(j)+1,ConIndb(j));
        end
        if ConIndb(j) > 1
            Adjacent(3,j) = A(ConInda(j), ConIndb(j)-1);
        end
        if ConIndb(j) < 1024
            Adjacent(4,j) = A(ConInda(j), ConIndb(j)+1);
        end
        
    end
    ConDrops(i,:) = unique(Adjacent(Adjacent>0));
    for k = 1:2
        Connections(ConDrops(i,k)) = Connections(ConDrops(i,k))+1;
    end
end