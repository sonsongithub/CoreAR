function [xn,dxdf,dxdc,dxdk,dxdalpha] = normalize2(x_kk,fc,cc,kc,alpha_c),

%normalize
%
%[xn] = normalize(x_kk,fc,cc,kc,alpha_c)
%
%Computes the normalized coordinates xn given the pixel coordinates x_kk
%and the intrinsic camera parameters fc, cc and kc.
%
%INPUT: x_kk: Feature locations on the images
%       fc: Camera focal length
%       cc: Principal point coordinates
%       kc: Distortion coefficients
%       alpha_c: Skew coefficient
%
%OUTPUT: xn: Normalized feature locations on the image plane (a 2XN matrix)
%
%Important functions called within that program:

k1 = kc(1);
k2 = kc(2);
k3 = kc(5);
p1 = kc(3);
p2 = kc(4);

N = size(x_kk,2);

% First: Subtract principal point, and divide by the focal length:
x_distort = [(x_kk(1,:) - cc(1))/fc(1);(x_kk(2,:) - cc(2))/fc(2)];


v1 = - x_distort(1,:) / fc(1);
v2 = - x_distort(2,:) / fc(1);

dx_distortdfc = zeros(2*N,2);
dx_distortdfc(1:2:end,1) = v1';
dx_distortdfc(2:2:end,2) = v2';

v1 = - x_distort(1,:) / fc(1);
v2 = - x_distort(2,:) / fc(1);

dx_distortdcc = zeros(2*N,2);
dx_distortdcc(1:2:end,1) = -(1/fc(1)) * ones(N,1);
dx_distortdcc(2:2:end,2) = -(1/fc(2)) * ones(N,1);

% Second: undo skew
x_distort(1,:) = x_distort(1,:) - alpha_c * x_distort(2,:);

dx_distort2dfc = [ dx_distortdfc(:,1)-alpha_c *dx_distortdfc(:,2)   dx_distortdfc(:,2)];
dx_distort2dcc = [ dx_distortdcc(:,1)-alpha_c *dx_distortdcc(:,2)   dx_distortdcc(:,2)];

dx_distort2dalpha_c = zeros(2*N,1);
dx_distort2dalpha_c(1:2:end) = -x_distort(2,:)';

x = x_distort; 				% initial guess

for kk=1:20,
    
    r_2 = sum(x.^2);
    k_radial =  1 + k1 * r_2 + k2 * r_2.^2 + k3 * r_2.^3;
    delta_x = [2*p1*x(1,:).*x(2,:) + p2*(r_2 + 2*x(1,:).^2); p1 * (r_2 + 2*x(2,:).^2)+2*p2*x(1,:).*x(2,:)];
    x = (x_distort - delta_x)./(ones(2,1)*k_radial);
    
end;


xn = x;


dxdk = zeros(2*N,5); % Approximation (no time)
dxdf = dx_distort2dfc;
dxdc = dx_distort2dcc;
dxdalpha = dx_distort2dalpha_c;
