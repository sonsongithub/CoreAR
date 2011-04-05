% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 351.794800281790003 ; 351.206295769769781 ];

%-- Principal point:
cc = [ 172.039363935631400 ; 128.255976596605251 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.131515714081418 ; -0.613000869587288 ; -0.001822395813943 ; 0.004855170213131 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 1.681298084398018 ; 1.658677242121716 ];

%-- Principal point uncertainty:
cc_error = [ 2.961513314049633 ; 2.545682059833849 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.041630953197575 ; 0.352537992834516 ; 0.003047535447403 ; 0.003668773213620 ; 0.000000000000000 ];

%-- Image size:
nx = 320;
ny = 240;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 11;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ -2.187492e+00 ; -2.173829e+00 ; -5.719594e-02 ];
Tc_1  = [ -1.491244e+02 ; -1.050601e+02 ; 5.276773e+02 ];
omc_error_1 = [ 6.961751e-03 ; 6.791677e-03 ; 1.489710e-02 ];
Tc_error_1  = [ 4.481935e+00 ; 3.888881e+00 ; 3.166280e+00 ];

%-- Image #2:
omc_2 = [ 1.756504e+00 ; 1.842192e+00 ; 5.531726e-01 ];
Tc_2  = [ -1.191262e+02 ; -9.084211e+01 ; 5.295983e+02 ];
omc_error_2 = [ 6.915179e-03 ; 5.970707e-03 ; 1.036572e-02 ];
Tc_error_2  = [ 4.483345e+00 ; 3.887838e+00 ; 3.146905e+00 ];

%-- Image #3:
omc_3 = [ -2.011694e+00 ; -1.890808e+00 ; 7.531841e-01 ];
Tc_3  = [ -1.303651e+02 ; -7.645801e+01 ; 6.182195e+02 ];
omc_error_3 = [ 7.713498e-03 ; 5.011400e-03 ; 1.131624e-02 ];
Tc_error_3  = [ 5.189699e+00 ; 4.511118e+00 ; 2.882958e+00 ];

%-- Image #4:
omc_4 = [ -2.034078e+00 ; -2.006325e+00 ; -3.776634e-01 ];
Tc_4  = [ -1.365251e+02 ; -2.509965e+01 ; 5.360089e+02 ];
omc_error_4 = [ 5.566751e-03 ; 7.728550e-03 ; 1.289167e-02 ];
Tc_error_4  = [ 4.496012e+00 ; 3.931207e+00 ; 3.125679e+00 ];

%-- Image #5:
omc_5 = [ 1.880173e+00 ; 1.854309e+00 ; -5.642208e-01 ];
Tc_5  = [ -1.504197e+02 ; -5.144816e+01 ; 6.640009e+02 ];
omc_error_5 = [ 4.939277e-03 ; 7.066376e-03 ; 1.137172e-02 ];
Tc_error_5  = [ 5.576013e+00 ; 4.858550e+00 ; 3.297937e+00 ];

%-- Image #6:
omc_6 = [ 1.449973e+00 ; 2.678005e+00 ; 4.715153e-02 ];
Tc_6  = [ -8.834888e+01 ; -1.481389e+02 ; 5.480256e+02 ];
omc_error_6 = [ 4.861730e-03 ; 9.106757e-03 ; 1.458709e-02 ];
Tc_error_6  = [ 4.651407e+00 ; 4.023010e+00 ; 3.202109e+00 ];

%-- Image #7:
omc_7 = [ 2.614323e+00 ; 1.533677e+00 ; -1.021885e-01 ];
Tc_7  = [ -1.659884e+02 ; -2.565529e+01 ; 6.320764e+02 ];
omc_error_7 = [ 8.592142e-03 ; 5.727126e-03 ; 1.665386e-02 ];
Tc_error_7  = [ 5.344654e+00 ; 4.610725e+00 ; 3.547413e+00 ];

%-- Image #8:
omc_8 = [ 1.372485e+00 ; 2.226183e+00 ; 9.579035e-01 ];
Tc_8  = [ -4.360067e+01 ; -1.129637e+02 ; 4.420890e+02 ];
omc_error_8 = [ 7.366143e-03 ; 6.542271e-03 ; 9.961271e-03 ];
Tc_error_8  = [ 3.742898e+00 ; 3.243538e+00 ; 2.664586e+00 ];

%-- Image #9:
omc_9 = [ -2.372905e+00 ; -8.532431e-01 ; 7.471598e-01 ];
Tc_9  = [ -1.401396e+02 ; 2.633431e+01 ; 6.292107e+02 ];
omc_error_9 = [ 8.198265e-03 ; 3.975884e-03 ; 1.071964e-02 ];
Tc_error_9  = [ 5.312376e+00 ; 4.582438e+00 ; 2.773172e+00 ];

%-- Image #10:
omc_10 = [ 4.543395e-01 ; 2.320245e+00 ; -1.401970e+00 ];
Tc_10  = [ -2.764004e+01 ; -3.070509e+01 ; 7.034281e+02 ];
omc_error_10 = [ 5.230414e-03 ; 8.842267e-03 ; 9.474703e-03 ];
Tc_error_10  = [ 5.904933e+00 ; 5.107768e+00 ; 2.695347e+00 ];

%-- Image #11:
omc_11 = [ 1.714915e-02 ; -2.609924e+00 ; 1.109814e+00 ];
Tc_11  = [ 1.499884e+02 ; -4.154651e+01 ; 7.913049e+02 ];
omc_error_11 = [ 4.778010e-03 ; 8.847687e-03 ; 1.028626e-02 ];
Tc_error_11  = [ 6.657101e+00 ; 5.762624e+00 ; 3.819397e+00 ];

