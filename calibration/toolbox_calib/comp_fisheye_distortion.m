function [x] = comp_fisheye_distortion(xd,k)

%comp_fisheye_distortion.m
%
%[x] =  comp_fisheye_distortion(xd,k)
%
%Compensates for fisheye distortions
%
%INPUT: xd: distorted (normalized) point coordinates in the image plane (2xN matrix)
%       k: Fisheye distortion coefficients (5x1 vector)
%
%OUTPUT: x: undistorted (normalized) point coordinates in the image plane (2xN matrix)
%
%Method: Iterative method for compensation.
%
%NOTE: This compensation has to be done after the subtraction
%      of the principal point, and division by the focal length.

theta_d = sqrt(xd(1,:).^2 + xd(2,:).^2);
theta = theta_d;  % initial guess
for kk=1:20,
    theta = theta_d ./ (1 + k(1)*theta.^2 + k(2)*theta.^4 + k(3)*theta.^6 + k(4)*theta.^8);
end;
scaling = tan(theta) ./ theta_d;

x = xd .* (ones(2,1)*scaling);

return;

% Test

n = 4;
xxx = rand(2,n);

xxx = [[1.0840    0.3152    0.2666    0.9347 ];[ 0.7353    0.6101   -0.6415   -0.8006]];

k = 0.00 * randn(4,1);

[xd] = comp_fisheye_distortion(xxx,k);
x2 = apply_fisheye_distortion(xd,k);
norm(x2-xd)/norm(x2-xxx)


%[xd] = apply_fisheye_distortion(xxx,k);
%x2 = comp_fisheye_distortion(xd,k);
%norm(x2-xd)/norm(x2-xxx)



