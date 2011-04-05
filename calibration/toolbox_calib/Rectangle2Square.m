function [square] = Rectangle2Square(rectangle,L,W);

% Generate the square from a rectangle of known segment lengths
% from pt1 to pt2 : L
% from pt2 to pt3 : W

[u_hori,u_vert] = UnWarpPlane(rectangle);

coeff_x = sqrt(W/L);
coeff_y = 1/coeff_x;

x_coord = [ 0 coeff_x  coeff_x 0];
y_coord = [ 0 0 coeff_y coeff_y];


square = rectangle(:,1) * ones(1,4) + u_hori*x_coord + u_vert*y_coord;
square = square ./ (ones(3,1)*square(3,:));


