function [m,s] = mean_std_robust(x);

x = x(:);

m = median(x);

s = median(abs(x - m))*1.4836;
