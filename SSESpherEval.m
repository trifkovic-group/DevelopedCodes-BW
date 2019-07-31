function sse = SSESpherEval(x,X,Y,Z)
a = x(1);
b = x(2);
c = x(3);
r = x(4);
sse = sum( ((X-a).^2 + (Y-b).^2 + (Z-c).^2 - r.^2).^2);
end