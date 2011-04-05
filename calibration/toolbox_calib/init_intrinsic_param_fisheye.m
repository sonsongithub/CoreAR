%init_intrinsic_param_fisheye
%
%Initialization of the intrinsic parameters.
%Runs as a script.
%
%INPUT: x_1,x_2,x_3,...: Feature locations on the images
%       X_1,X_2,X_3,...: Corresponding grid coordinates
%
%OUTPUT: fc: Camera focal length
%        cc: Principal point coordinates
%	     kc: Fisheye distortion coefficients
%        alpha_c: skew coefficient
%        KK: The camera matrix (containing fc, cc and alpha_c)
%
%Method: Computes the planar homographies H_1, H_2, H_3, ... and computes
%        the focal length fc from orthogonal vanishing points constraint.
%        The principal point cc is assumed at the center of the image.
%        Assumes no image distortion (kc = [0;0;0;0])
%
%Note: The row vector active_images consists of zeros and ones. To deactivate an image, set the
%      corresponding entry in the active_images vector to zero.
%
%
%Important function called within that program:
%
%compute_homography.m: Computes the planar homography between points on the grid in 3D, and the image plane.
%
%
%VERY IMPORTANT: This function works only with 2D rigs.
%In the future, a more general function will be there (working with 3D rigs as well).


if ~exist('two_focals_init'),
    two_focals_init = 0;
end;

if ~exist('est_aspect_ratio'),
    est_aspect_ratio = 1;
end;

check_active_images;

if ~exist(['x_' num2str(ind_active(1)) ]),
    click_calib;
end;


fprintf(1,'\nInitialization of the intrinsic parameters - Number of images: %d\n',length(ind_active));

check_active_images;

% initial guess for principal point and distortion:

if ~exist('nx'), [ny,nx] = size(I); end;

f_init = (max(nx,ny) / pi) * ones(2,1);
c_init = [nx;ny]/2 - 0.5; % initialize at the center of the image
k_init = [0;0;0;0]; % initialize to zero (no distortion)  

if ~est_aspect_ratio,
    f_init(1) = (f_init(1)+f_init(2))/2;
    f_init(2) = f_init(1);
end;

alpha_init = 0;

% Global calibration matrix (initial guess):

KK = [f_init(1) alpha_init*f_init(1) c_init(1);0 f_init(2) c_init(2); 0 0 1];
inv_KK = inv(KK);

cc = c_init;
fc = f_init;
kc = k_init;
alpha_c = alpha_init;


fprintf(1,'\n\nCalibration parameters after initialization:\n\n');
fprintf(1,'Focal Length:          fc = [ %3.5f   %3.5f ]\n',fc);
fprintf(1,'Principal point:       cc = [ %3.5f   %3.5f ]\n',cc);
fprintf(1,'Skew:             alpha_c = [ %3.5f ]   => angle of pixel = %3.5f degrees\n',alpha_c,90 - atan(alpha_c)*180/pi);
fprintf(1,'Fisheye Distortion:    kc = [ %3.5f   %3.5f   %3.5f   %3.5f ]\n',kc);   
