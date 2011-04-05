function [XX,H] = projectedGrid ( P1, P2, P3, P4 , nx, ny);

% new formalism using homographies

a00 = [P1;1];
a10 = [P2;1];
a11 = [P3;1];
a01 = [P4;1];

% Compute the planart collineation:

[H] = compute_collineation (a00, a10, a11, a01);


% Build the grid using the planar collineation:

x_l = ((0:(nx-1))'*ones(1,ny))/(nx-1);
y_l = (ones(nx,1)*(0:(ny-1)))/(ny-1);

pts = [x_l(:) y_l(:) ones(nx*ny,1)]';

XX = H*pts;

XX = XX(1:2,:) ./ (ones(2,1)*XX(3,:));
