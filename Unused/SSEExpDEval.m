function sse = SSEExpDEval(x,X,Y)
a = x(1);
b = x(2);
c = x(3);
sse = sum( (c - a.*exp(-b.*X) - Y).^2 );
end