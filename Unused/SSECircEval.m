function sse = SSECircEval(x,X,Y)
a = x(1);
b = x(2);
r = x(3);
sse = sum( ((X-a).^2 + (Y-b).^2 - r.^2).^2);
end