clear
clc

%Gregory Lazaris, Friday May 19th 2017                                        
                                                                           %Number of Droplets - m
m=200                                                %Droplet Size Distribution - dsd

mhalf = m/2;

sf_s = [];
vol_s = [];
d_s = [];

d = normrnd(20, 10,1,m); %randi([10,30],1,m) ;
dintial = d;
sf = randi([10, 50],1,m)/100; %ones(1,m)*.25;                                              %generates random array from 10 - 50 for radii
vol = [];
iter = 1;
iter_s = 1;
itera = 1

for i = 1:length(d)                                                       %generates array of volume values using previous radii array
    vol(iter) = (4/3)*pi*((d(iter))/2)^3;
    iter = iter + 1;
end

% vols = sort(vol);
% vmin1 = vols(1);
% vmin2 = vols(end);
% phimax = (vmin1^(1/3)+vmin2^(1/3))*((1/vmin1^(1/3))+(1/vmin2^(1/3)));      %maximun value of phi using the two smallest droplets in sys.
counter=0
while mean(sf) <= 0.95
    %pause
    counter=counter+1
i = randi([1, m],1);                                                        %selects random value for i and k from 10 - 50
k = randi([1, m],1);
if i ~= k                                                                  %if i and k are different, continue
    z = rand;                                                              %random value between 0 and 1
    phi =((vol(i))^(1/3)+(vol(k))^(1/3))*((1/(vol(i))^(1/3))+(1/(vol(k))^(1/3))); %phi magnitude using volume values from above array vol
    vols = sort(vol);
    vmin1 = vols(end);
    vmin2 = vols(1);
    phimax = (vmin1^(1/3)+vmin2^(1/3))*((1/vmin1^(1/3))+(1/vmin2^(1/3)));
    id(itera) = i;
    is(itera) = k;
    itera = itera + 1;
    if (z*phimax) <= phi                                                    %Droplets Collide
        w = rand;
        if w > (1-sf(i))*(1-sf(k))                                        %Droplets Coalesce
            vol_tot = vol(i) + vol(k);
            sf_tot = (sf(i)*(vol(i)/vol_tot)^(2/3)) + ...
            (sf(k)*(vol(k)/vol_tot)^(2/3));
            if sf_tot >= 1                                                 %if the total surface coverage is > = 1 subtract 2 droplets
                m = m - 2;
                d(max([i k])) = [];
                d(min([i k])) = [];
                sf(max([i k])) = [];
                sf(min([i k])) = [];
                vol(max([i k])) =[];
                vol(min([i k])) = [];
                sf_s(iter_s) = sf_tot;
                vol_s(iter_s) = vol_tot;
                d_s(iter_s) = 2*(((3*vol_tot)/(4*pi))^(1/3));
                iter_s = iter_s + 1;        
            else
                m = m - 1;                                                  % if the total surface coverage is < 1 subtract 1 droplet
                d(i) = 2*(((3*vol_tot)/(4*pi))^(1/3));
                d(k) = [];
                sf(i) = sf_tot;
                sf(k) = [];
                vol(i) =vol_tot;
                vol(k) = [];
             end
%             s1 = mean(sf)
%             if s1 == s2
%               break
%             end
%             s2 = mean(sf);
        end
    end
end
if m <= mhalf 
    m = m*2; 
    d = [d d];
    sf = [sf sf];
    vol = [vol vol];
else
end



end

%Title - Droplet Size Distribution  
%colour code, x - droplet size, y - density/frequency
    