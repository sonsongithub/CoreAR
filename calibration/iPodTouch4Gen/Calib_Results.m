% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 1153.021908154610173 ; 1154.620738980067017 ];

%-- Principal point:
cc = [ 460.372001554790756 ; 346.806994032054604 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.213795208261261 ; -1.309985561180440 ; -0.003162118830671 ; -0.005089871607323 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 9.461187214291545 ; 9.543282077367801 ];

%-- Principal point uncertainty:
cc_error = [ 7.877571550978829 ; 7.308673344858684 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.045789499575892 ; 0.297510490165066 ; 0.002573861183044 ; 0.002476606903803 ; 0.000000000000000 ];

%-- Image size:
nx = 960;
ny = 720;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 10;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ 1.772598e+00 ; 1.694438e+00 ; -3.662898e-01 ];
Tc_1  = [ -1.320581e+02 ; -9.364041e+01 ; 4.586329e+02 ];
omc_error_1 = [ 5.067929e-03 ; 6.144488e-03 ; 8.606530e-03 ];
Tc_error_1  = [ 3.132649e+00 ; 2.923040e+00 ; 3.519594e+00 ];

%-- Image #2:
omc_2 = [ 1.936437e+00 ; 1.788444e+00 ; -2.255778e-01 ];
Tc_2  = [ -1.241542e+02 ; -8.679234e+01 ; 4.442923e+02 ];
omc_error_2 = [ 5.446684e-03 ; 5.853686e-03 ; 9.707564e-03 ];
Tc_error_2  = [ 3.038069e+00 ; 2.816832e+00 ; 3.520833e+00 ];

%-- Image #3:
omc_3 = [ 2.048640e+00 ; 1.979780e+00 ; -4.326660e-02 ];
Tc_3  = [ -1.149769e+02 ; -8.497798e+01 ; 4.248323e+02 ];
omc_error_3 = [ 6.096965e-03 ; 5.974810e-03 ; 1.203949e-02 ];
Tc_error_3  = [ 2.915482e+00 ; 2.692541e+00 ; 3.586297e+00 ];

%-- Image #4:
omc_4 = [ 2.107033e+00 ; 2.295160e+00 ; 3.284204e-01 ];
Tc_4  = [ -9.460475e+01 ; -8.682770e+01 ; 4.081097e+02 ];
omc_error_4 = [ 7.006318e-03 ; 6.072086e-03 ; 1.390638e-02 ];
Tc_error_4  = [ 2.799393e+00 ; 2.601611e+00 ; 3.637605e+00 ];

%-- Image #5:
omc_5 = [ -2.004121e+00 ; -2.260723e+00 ; -5.007548e-01 ];
Tc_5  = [ -1.002241e+02 ; -8.678532e+01 ; 4.179846e+02 ];
omc_error_5 = [ 5.048248e-03 ; 7.173770e-03 ; 1.262798e-02 ];
Tc_error_5  = [ 2.874367e+00 ; 2.684978e+00 ; 3.807798e+00 ];

%-- Image #6:
omc_6 = [ 1.967636e+00 ; 1.949592e+00 ; 2.990837e-01 ];
Tc_6  = [ -7.092045e+01 ; -9.082890e+01 ; 4.603818e+02 ];
omc_error_6 = [ 6.624663e-03 ; 5.500305e-03 ; 1.152240e-02 ];
Tc_error_6  = [ 3.154522e+00 ; 2.895595e+00 ; 4.097188e+00 ];

%-- Image #7:
omc_7 = [ 2.041866e+00 ; 1.999112e+00 ; 2.317483e-01 ];
Tc_7  = [ -9.479093e+01 ; -9.280442e+01 ; 4.689315e+02 ];
omc_error_7 = [ 6.683529e-03 ; 5.891238e-03 ; 1.254030e-02 ];
Tc_error_7  = [ 3.232396e+00 ; 2.963727e+00 ; 4.169332e+00 ];

%-- Image #8:
omc_8 = [ -2.058698e+00 ; -2.078805e+00 ; 3.788265e-01 ];
Tc_8  = [ -1.371742e+02 ; -1.131334e+02 ; 4.926709e+02 ];
omc_error_8 = [ 6.629270e-03 ; 5.494429e-03 ; 1.192665e-02 ];
Tc_error_8  = [ 3.359383e+00 ; 3.130380e+00 ; 3.803458e+00 ];

%-- Image #9:
omc_9 = [ -1.865575e+00 ; -1.904313e+00 ; -6.398790e-02 ];
Tc_9  = [ -1.453429e+02 ; -7.550962e+01 ; 4.629190e+02 ];
omc_error_9 = [ 5.228060e-03 ; 5.956250e-03 ; 1.049177e-02 ];
Tc_error_9  = [ 3.147109e+00 ; 2.952983e+00 ; 3.769592e+00 ];

%-- Image #10:
omc_10 = [ 1.569081e+00 ; 1.670861e+00 ; 1.755065e-01 ];
Tc_10  = [ -7.877312e+01 ; -1.045540e+02 ; 4.616574e+02 ];
omc_error_10 = [ 5.771107e-03 ; 5.714525e-03 ; 8.136113e-03 ];
Tc_error_10  = [ 3.162047e+00 ; 2.913814e+00 ; 3.923664e+00 ];

