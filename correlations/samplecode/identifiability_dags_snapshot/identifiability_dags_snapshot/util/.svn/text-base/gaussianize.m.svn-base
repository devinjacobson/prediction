function y = gaussianize(x);
% performs Gaussianization of x, such that each column of y follows the
% standard Gaussian distribution.
% The dimentionality of x is T (the sample size) * N (the variable number).
[T,N] = size(x);

cdf = (1:T)/(T+1);
for i=1:N
    [x_temp, I] = sort(x(:,i) , 'ascend');
    y(I,i) = norminv(cdf);
end
