function  [u_hori,u_vert] = UnWarpPlane(x1,x2,x3,x4);

% Recovers the two 3D directions of the rectangular patch x1x2x3x4
% x1 is the origin point, ie any point of planar coordinate (x,y) on the
% rectangular patch will be projected on the image plane at:
% x1 + x * u_hori + y * u_vert
%
% Note: u_hori and u_vert are also the two vanishing points.


if nargin < 4,
   
   x4 = x1(:,4);
   x3 = x1(:,3);
   x2 = x1(:,2);
   x1 = x1(:,1);
   
end;


% Image Projection:
L1 = cross(x1,x2);
L2 = cross(x4,x3);
L3 = cross(x2,x3);
L4 = cross(x1,x4);

% Vanishing point:
V1 = cross(L1,L2);
V2 = cross(L3,L4);

% Horizon line:
H = cross(V1,V2);

if H(3) < 0, H  = -H; end;


H = H / norm(H);


X1 = x1 / dot(H,x1);
X2 = x2 / dot(H,x2);
X3 = x3 / dot(H,x3);
X4 = x4 / dot(H,x4);

scale = X1(3);

X1 = X1/scale;
X2 = X2/scale;
X3 = X3/scale;
X4 = X4/scale;


u_hori = X2 - X1;
u_vert = X4 - X1;
