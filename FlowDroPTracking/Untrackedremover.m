lp = [{}]
for i = 1:length(paths)
if length(cell2mat(paths(i))) > 8
lp(length(lp)+1) = paths(i);
end
end
clear hc2
clear hc3
clear DM3
clear p
clear h
hc2 = zeros(pixels(1),pixels(2),frames);
for i = 1:length(lp)
    p = cell2mat(lp(i));
    
    for j = 1:length(p(:,1))
        hc3 = zeros(pixels(1),pixels(2));
        DM3 = zeros(pixels(1),pixels(2));
        DM3(p(j,2),p(j,3)) = 1; 
        DM3 = bwdist(DM3);
        hc3(DM3<p(j,1)*1.05) = p(j,4);
        hc2(:,:,p(j,5)) = hc2(:,:,p(j,5)) + hc3;
        hc2(1,1,p(j,5)) = 1000;
        
    end
end

for i = 1:frames
    h(:,:,:,i) = label2rgb(hc2(:,:,i),'hsv','k','shuffle');
end
figure(1)
hold on
figure(2)
hold on
for i = 1:length(lp)
    distrack = cell2mat(lp(i));
    for j = 1:length(distrack(:,1))-1
       xdis(j) = distrack(j,3) - distrack(j+1,3);
       ydis(j) = distrack(j,2) - distrack(j+1,2);
    end
    xdismean(i) = mean(xdis);
    ydismean(i) = mean(ydis);
    xstd(i) = std(xdis);
    ystd(i) = std(ydis);
    xnorm(:,i) = normpdf(0:1:100,xdismean(i),xstd(i));
    ynorm(:,i) = normpdf(-10:.1:10,ydismean(i),ystd(i));
    figure(1)
    plot(0:1:100,xnorm(:,i))
    figure(2)
    plot(-10:.1:10,ynorm(:,i))
end
figure(1)
hold off
figure(2)
hold off