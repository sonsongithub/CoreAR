function [xd] = apply_fisheye_distortion(x,k)

%apply_fisheye_distortion.m
%
%[x] =  apply_fisheye_distortion(xd,k)
%
%Apply the fisheye distortions
%
%INPUT: x: undistorted (normalized) point coordinates in the image plane (2xN matrix)
%       k: Fisheye distortion coefficients (5x1 vector)
%
%OUTPUT: xd: distorted (normalized) point coordinates in the image plane (2xN matrix)

r = sqrt(x(1,:).^2 + x(2,:).^2);

theta = atan(r);
theta_d = theta .* (1 + k(1)*theta.^2 + k(2)*theta.^4 + k(3)*theta.^6 + k(4)*theta.^8);

scaling = ones(1,length(r));

ind_good = find(r > 1e-8);

scaling(ind_good) = theta_d(ind_good) ./ r(ind_good);

xd = x .* (ones(2,1)*scaling);
