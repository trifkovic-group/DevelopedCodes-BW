%Import (copy/paste) Centrifugation Time and Speed in to separate arrays
%Import Data into array (This will leave three arrays, in first data set
%they were 12x1 arrays.
%Turn into nxm matrices, where n and m are the number of different speeds
%and times used when making measurements
Data = [Data1(1:4)';Data1(5:8)';Data1(9:12)'];
x = [1 3 5 10];
y = [50 515 3220];
[X,Y] = meshgrid(x,y);
PlotData = griddata(x,y,Data,X,Y);
contour(X,Y,PlotData)
contour(X,Y,PlotData,[30,30],'g')

 
