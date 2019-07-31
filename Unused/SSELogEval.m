function sse = SSELogEval(x,X,Y)
a = x(1);
b = x(2);
c = x(3);
sse = sum( (a.*log(X+b) + c - Y).^2 );
end