% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 1165.214842426865516 ; 1164.426375701091047 ];

%-- Principal point:
cc = [ 366.117328812647202 ; 502.826461416662369 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.123099260911403 ; 0.799076092580660 ; 0.002951374770375 ; -0.000563029977992 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 3.115959711399751 ; 3.493847772992476 ];

%-- Principal point uncertainty:
cc_error = [ 5.785751046727245 ; 6.334391594190967 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.027776029116017 ; 0.241243710244010 ; 0.001849199009499 ; 0.001720119742825 ; 0.000000000000000 ];

%-- Image size:
nx = 720;
ny = 960;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 12;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ 2.327281e+00 ; 8.211716e-02 ; 4.394781e-03 ];
Tc_1  = [ -1.102053e+02 ; 7.580182e+01 ; 5.576308e+02 ];
omc_error_1 = [ 5.796416e-03 ; 2.653618e-03 ; 6.314721e-03 ];
Tc_error_1  = [ 2.787146e+00 ; 3.059850e+00 ; 1.844106e+00 ];

%-- Image #2:
omc_2 = [ 2.337845e+00 ; -7.023217e-02 ; -3.583788e-01 ];
Tc_2  = [ -1.206347e+02 ; 8.854053e+01 ; 5.979433e+02 ];
omc_error_2 = [ 5.841106e-03 ; 2.803620e-03 ; 6.440205e-03 ];
Tc_error_2  = [ 2.985025e+00 ; 3.276867e+00 ; 1.943219e+00 ];

%-- Image #3:
omc_3 = [ 2.414641e+00 ; -1.670836e-01 ; -8.677492e-01 ];
Tc_3  = [ -1.418204e+02 ; 1.054765e+02 ; 5.592332e+02 ];
omc_error_3 = [ 5.873541e-03 ; 3.275443e-03 ; 6.629245e-03 ];
Tc_error_3  = [ 2.806189e+00 ; 3.082864e+00 ; 1.794837e+00 ];

%-- Image #4:
omc_4 = [ 2.422811e+00 ; 6.839111e-01 ; 9.798378e-01 ];
Tc_4  = [ -6.972108e+01 ; 1.422096e+01 ; 5.059522e+02 ];
omc_error_4 = [ 6.028408e-03 ; 2.860519e-03 ; 6.998351e-03 ];
Tc_error_4  = [ 2.526633e+00 ; 2.759433e+00 ; 1.895170e+00 ];

%-- Image #5:
omc_5 = [ 2.576441e+00 ; 2.510062e-01 ; 1.036764e+00 ];
Tc_5  = [ -5.787052e+01 ; 7.523801e+01 ; 4.304442e+02 ];
omc_error_5 = [ 5.926261e-03 ; 2.983949e-03 ; 6.985092e-03 ];
Tc_error_5  = [ 2.159170e+00 ; 2.355271e+00 ; 1.615307e+00 ];

%-- Image #6:
omc_6 = [ 2.217532e+00 ; 5.151866e-02 ; -6.812245e-02 ];
Tc_6  = [ -1.025724e+02 ; 4.153583e+01 ; 4.162990e+02 ];
omc_error_6 = [ 5.696413e-03 ; 2.944651e-03 ; 5.848395e-03 ];
Tc_error_6  = [ 2.073777e+00 ; 2.282978e+00 ; 1.358391e+00 ];

%-- Image #7:
omc_7 = [ -3.125260e+00 ; -4.403435e-02 ; -7.596473e-02 ];
Tc_7  = [ -1.107696e+02 ; 1.359798e+02 ; 5.626536e+02 ];
omc_error_7 = [ 6.898196e-03 ; 9.937628e-04 ; 1.111367e-02 ];
Tc_error_7  = [ 2.840370e+00 ; 3.097905e+00 ; 1.961866e+00 ];

%-- Image #8:
omc_8 = [ -2.595812e+00 ; -6.248369e-02 ; 2.108940e-01 ];
Tc_8  = [ -1.126569e+02 ; 1.082760e+02 ; 5.738556e+02 ];
omc_error_8 = [ 5.589972e-03 ; 2.012691e-03 ; 6.852891e-03 ];
Tc_error_8  = [ 2.868770e+00 ; 3.141737e+00 ; 1.507348e+00 ];

%-- Image #9:
omc_9 = [ -2.463202e+00 ; -3.587182e-02 ; 6.734168e-01 ];
Tc_9  = [ -8.273948e+01 ; 1.013123e+02 ; 6.061627e+02 ];
omc_error_9 = [ 5.607099e-03 ; 2.784356e-03 ; 6.444955e-03 ];
Tc_error_9  = [ 3.033459e+00 ; 3.319385e+00 ; 1.445712e+00 ];

%-- Image #10:
omc_10 = [ -2.582255e+00 ; -8.044362e-02 ; -4.971847e-01 ];
Tc_10  = [ -1.115602e+02 ; 1.101177e+02 ; 4.864191e+02 ];
omc_error_10 = [ 5.493788e-03 ; 2.279401e-03 ; 6.611843e-03 ];
Tc_error_10  = [ 2.437841e+00 ; 2.658398e+00 ; 1.472164e+00 ];

%-- Image #11:
omc_11 = [ 2.158793e+00 ; -3.634842e-01 ; 3.585060e-01 ];
Tc_11  = [ -6.062400e+01 ; 8.223433e+01 ; 4.139246e+02 ];
omc_error_11 = [ 5.565550e-03 ; 3.128202e-03 ; 5.703081e-03 ];
Tc_error_11  = [ 2.076984e+00 ; 2.283987e+00 ; 1.485894e+00 ];

%-- Image #12:
omc_12 = [ 2.250934e+00 ; 5.483964e-01 ; -3.383672e-01 ];
Tc_12  = [ -1.482405e+02 ; 1.160655e+01 ; 5.327296e+02 ];
omc_error_12 = [ 5.648474e-03 ; 3.313043e-03 ; 6.194871e-03 ];
Tc_error_12  = [ 2.658072e+00 ; 2.925337e+00 ; 1.655508e+00 ];

