function [omckk,Tckk,Rckk,JJ] = compute_extrinsic_refine_fisheye(omc_init,Tc_init,x_kk,X_kk,fc,cc,kc,alpha_c,MaxIter,thresh_cond)

%compute_extrinsic
%
%[omckk,Tckk,Rckk] = compute_extrinsic_refine_fisheye(omc_init,x_kk,X_kk,fc,cc,kc,alpha_c,MaxIter)
%
%Computes the extrinsic parameters attached to a 3D structure X_kk given its projection
%on the image plane x_kk and the intrinsic camera parameters fc, cc and kc.
%Works with planar and non-planar structures.
%
%INPUT: x_kk: Feature locations on the images
%       X_kk: Corresponding grid coordinates
%       fc: Camera focal length
%       cc: Principal point coordinates
%       kc: Fisheye Distortion coefficients
%       alpha_c: Skew coefficient
%       MaxIter: Maximum number of iterations
%
%OUTPUT: omckk: 3D rotation vector attached to the grid positions in space
%        Tckk: 3D translation vector attached to the grid positions in space
%        Rckk: 3D rotation matrices corresponding to the omc vectors

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


if nargin < 10,
   thresh_cond = inf;
end;


if nargin < 9,
   MaxIter = 20;
end;

if nargin < 8,
    alpha_c = 0;
    if nargin < 7,
        kc = zeros(5,1);
        if nargin < 6,
            cc = zeros(2,1);
            if nargin < 5,
                fc = ones(2,1);
                if nargin < 4,
                    error('Need 2D projections and 3D points (in compute_extrinsic_refine.m)');
                    return;
                end;
            end;
        end;
    end;
end;


% Initialization:

omckk = omc_init;
Tckk = Tc_init;


% Final optimization (minimize the reprojection error in pixel):
% through Gradient Descent:

param = [omckk;Tckk];

change = 1;

iter = 0;

%keyboard;

%fprintf(1,'Gradient descent iterations: ');

while (change > 1e-10)&(iter < MaxIter),
    
    %fprintf(1,'%d...',iter+1);
    
    [x,dxdom,dxdT] = project_points_fisheye(X_kk,omckk,Tckk,fc,cc,kc,alpha_c);
    
    ex = x_kk - x;
    
    %keyboard;
    
    JJ = [dxdom dxdT];
    
    if cond(JJ) > thresh_cond,
        change = 0;
    else
        
        JJ2 = JJ'*JJ;
        
        param_innov = inv(JJ2)*(JJ')*ex(:);
        param_up = param + param_innov;
        change = norm(param_innov)/norm(param_up);
        param = param_up;
        iter = iter + 1;
        
        omckk = param(1:3);
        Tckk = param(4:6);
        
    end;
    
end;

%fprintf(1,'\n');

Rckk = rodrigues(omckk);
