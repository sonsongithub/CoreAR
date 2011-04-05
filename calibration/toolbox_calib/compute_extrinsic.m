function [omckk,Tckk,Rckk,H,x,ex,JJ] = compute_extrinsic(x_kk,X_kk,fc,cc,kc,alpha_c,MaxIter,thresh_cond),

%compute_extrinsic
%
%[omckk,Tckk,Rckk,H,x,ex] = compute_extrinsic(x_kk,X_kk,fc,cc,kc,alpha_c)
%
%Computes the extrinsic parameters attached to a 3D structure X_kk given its projection
%on the image plane x_kk and the intrinsic camera parameters fc, cc and kc.
%Works with planar and non-planar structures.
%
%INPUT: x_kk: Feature locations on the images
%       X_kk: Corresponding grid coordinates
%       fc: Camera focal length
%       cc: Principal point coordinates
%       kc: Distortion coefficients
%       alpha_c: Skew coefficient
%
%OUTPUT: omckk: 3D rotation vector attached to the grid positions in space
%        Tckk: 3D translation vector attached to the grid positions in space
%        Rckk: 3D rotation matrices corresponding to the omc vectors
%        H: Homography between points on the grid and points on the image plane (in pixel)
%           This makes sense only if the planar that is used in planar.
%        x: Reprojections of the points on the image plane
%        ex: Reprojection error: ex = x_kk - x;
%
%Method: Computes the normalized point coordinates, then computes the 3D pose
%
%Important functions called within that program:
%
%normalize_pixel: Computes the normalize image point coordinates.
%
%pose3D: Computes the 3D pose of the structure given the normalized image projection.
%
%project_points.m: Computes the 2D image projections of a set of 3D points



if nargin < 8,
   thresh_cond = inf;
end;


if nargin < 7,
   MaxIter = 20;
end;


if nargin < 6,
   alpha_c = 0;
	if nargin < 5,
   	kc = zeros(5,1);
   	if nargin < 4,
      	cc = zeros(2,1);
      	if nargin < 3,
         	fc = ones(2,1);
         	if nargin < 2,
            	error('Need 2D projections and 3D points (in compute_extrinsic.m)');
            	return;
         	end;
      	end;
   	end;
	end;
end;

% Initialization:

[omckk,Tckk,Rckk] = compute_extrinsic_init(x_kk,X_kk,fc,cc,kc,alpha_c);

% Refinement:
[omckk,Tckk,Rckk,JJ] = compute_extrinsic_refine(omckk,Tckk,x_kk,X_kk,fc,cc,kc,alpha_c,MaxIter,thresh_cond);


% computation of the homography (not useful in the end)

H = [Rckk(:,1:2) Tckk];

% Computes the reprojection error in pixels:

x = project_points2(X_kk,omckk,Tckk,fc,cc,kc,alpha_c);

ex = x_kk - x;


% Converts the homography in pixel units:

KK = [fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2); 0 0 1];

H = KK*H;




return;


% Test of compte extrinsic:

Np = 4;
sx = 10;
sy = 10;
sz = 5;

om = randn(3,1);
T = [0;0;100];

noise = 2/1000;

XX = [sx*randn(1,Np);sy*randn(1,Np);sz*randn(1,Np)];
xx = project_points(XX,om,T);

xxn = xx + noise * randn(2,Np);

[omckk,Tckk] = compute_extrinsic(xxn,XX);

[om omckk om-omckk]
[T Tckk T-Tckk]

figure(3);
plot(xx(1,:),xx(2,:),'r+');
hold on;
plot(xxn(1,:),xxn(2,:),'g+');
hold off;
