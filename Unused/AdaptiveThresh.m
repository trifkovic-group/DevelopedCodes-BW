h = 1280;
w = 1024;
s = 1024/4
in = im2double(thisSlice_d);
t = .1;

for i = 1:w
    summ = 0;
    for j = 1:h
        summ = summ + in(i,j);
        if i == 1
            intImg(i,j) = summ;
        else
            intImg(i,j) = intImg(i-1,j) + summ;
        end
    end
end

for i = 1:w
    for j = 1:h
        if i - s/2 <= 1
            x1 = 2;
        else
            x1 = i-s/2;
        end
        
        if i + s/2 > w
            x2 = w;
        else
            x2 = i+s/2;
        end
        
        if j - s/2 <= 1
            y1 = 2;
        else
            y1 = j-s/2;
        end
        
        if j + s/2 > h
            y2 = h;
        else
            y2 = j+s/2;
        end
        
        counter = (x2 - x1) * (y2 - y1);
        summ = intImg(x2,y2) - intImg(x2,y1-1) - intImg(x1-1,y2) + intImg(x1-1,y1-1);
        
        if in(i,j)*counter <= summ*(100-t)/100
            out(i,j) = 0;
        else
            out(i,j) = 255;
        end
        
    end
end

imshow(out)


T = adaptthresh(thisSlice_d,.1);
bw = imbinarize(thisSlice_d,T);
imshow(bw);

I = thisSlice_d;
background = imopen(I,strel('disk',100));
Z = double(I - background) * 255/double(max(max(I-background)))
imshow(imbinarize(Z/255))
