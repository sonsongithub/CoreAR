function test = is3D(X),


Np = size(X,2);

%% Check for planarity of the structure:

X_mean = mean(X')';

Y = X - (X_mean*ones(1,Np));

YY = Y*Y';

[U,S,V] = svd(YY);

r = S(3,3)/S(2,2);

test = (r > 1e-3);

