function [H,Hnorm,inv_Hnorm] = compute_collineation (a00, a10, a11, a01);

% new formalism using homographies

a00 = a00 / a00(3);
a10 = a10 / a10(3);
a11 = a11 / a11(3);
a01 = a01 / a01(3);


% Prenormalization of point coordinates (very important):
% (Affine normalization)

ax = [a00(1);a10(1);a11(1);a01(1)];
ay = [a00(2);a10(2);a11(2);a01(2)];

mxx = mean(ax);
myy = mean(ay);
ax = ax - mxx;
ay = ay - myy;

scxx = mean(abs(ax));
scyy = mean(abs(ay));


Hnorm = [1/scxx 0 -mxx/scxx;0 1/scyy -myy/scyy;0 0 1];
inv_Hnorm = [scxx 0 mxx ; 0 scyy myy; 0 0 1];


a00n = Hnorm*a00;
a10n = Hnorm*a10;
a11n = Hnorm*a11;
a01n = Hnorm*a01;


% Computation of the vanishing points:

V1n = cross(cross(a00n,a10n),cross(a01n,a11n));
V2n = cross(cross(a00n,a01n),cross(a10n,a11n));

V1 = inv_Hnorm*V1n;
V2 = inv_Hnorm*V2n;


% Normalizaion of the vanishing points:

V1n = V1n/norm(V1n);
V2n = V2n/norm(V2n);


% Closed-form solution of the coefficients:

alpha_x = (a10n(2)*a00n(1) - a10n(1)*a00n(2))/(V1n(2)*a10n(1)-V1n(1)*a10n(2));

alpha_y = (a01n(2)*a00n(1) - a01n(1)*a00n(2))/(V2n(2)*a01n(1)-V2n(1)*a01n(2));


% Remaining Homography

Hrem = [alpha_x*V1n  alpha_y*V2n a00n];


% Final homography:

H = inv_Hnorm*Hrem;

