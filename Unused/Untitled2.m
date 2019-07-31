for i = min(SD(1:200000)):max(SD(1:200000))
    j = find( SD(1:200000) == i);
    x2(i - min(SD(1:200000)) + 1) = median(j);
    y2(i - min(SD(1:200000)) + 1) = i;
end

fun = @(x)SSEExpDEval(x,x2,y2);

fun = @(x)SSEExpEval(x,x2,y2);

fun = @(x)SSELogEval(x,x2,y2);

fun = @(x)SSEExpDEval(x,(1:200000),SD(1:200000));

fun = @(x)SSELogEval(x,(1:200000),SD(1:200000));

fun = @(x)SSEExpEval(x,(1:200000),SD(1:200000));

x0 = [10 1/100 190];

x0 = [1 1 1];

plot(X,ans(1)*log(X+ans(2)) + ans(3))

plot(X,ans(3) - ans(1) * exp(-ans(2)*X))

plot(X,ans(1)*exp(-X/ans(2))+ans(3))

plot(SD(1:200000))

sse = sum( (a.*exp(-X./b)+c - Y).^2 );