% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 649.590771179639773 ; 653.240978126455161 ];

%-- Principal point:
cc = [ 325.424044518301571 ; 207.517575974516490 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ -0.026638341380432 ; 0.293146363735003 ; -0.024799586146210 ; -0.005724334030959 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 5.082665478399187 ; 5.833907019528290 ];

%-- Principal point uncertainty:
cc_error = [ 8.808295753917966 ; 9.239718818666507 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.052854988469379 ; 0.295040276988443 ; 0.005525342083173 ; 0.004969873641385 ; 0.000000000000000 ];

%-- Image size:
nx = 640;
ny = 480;


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
omc_1 = [ 2.196475e+00 ; 2.193985e+00 ; -5.124065e-02 ];
Tc_1  = [ -1.305046e+02 ; -5.294900e+01 ; 5.741624e+02 ];
omc_error_1 = [ 1.427803e-02 ; 1.384015e-02 ; 2.945751e-02 ];
Tc_error_1  = [ 7.864449e+00 ; 8.197555e+00 ; 5.462441e+00 ];

%-- Image #2:
omc_2 = [ -1.776732e+00 ; -1.831347e+00 ; 9.949194e-01 ];
Tc_2  = [ -4.369318e+01 ; -4.746508e+01 ; 6.794698e+02 ];
omc_error_2 = [ 1.410206e-02 ; 9.819045e-03 ; 1.649727e-02 ];
Tc_error_2  = [ 9.122663e+00 ; 9.581394e+00 ; 4.941654e+00 ];

%-- Image #3:
omc_3 = [ 1.934966e+00 ; 1.833347e+00 ; 7.971106e-01 ];
Tc_3  = [ -1.237002e+02 ; -7.598020e+01 ; 4.034730e+02 ];
omc_error_3 = [ 1.355752e-02 ; 7.806791e-03 ; 2.003804e-02 ];
Tc_error_3  = [ 5.550902e+00 ; 5.848354e+00 ; 4.799258e+00 ];

%-- Image #4:
omc_4 = [ -1.861276e+00 ; -1.782358e+00 ; -5.218664e-01 ];
Tc_4  = [ -1.352870e+02 ; -9.008804e+01 ; 5.163151e+02 ];
omc_error_4 = [ 1.014565e-02 ; 1.316815e-02 ; 1.942007e-02 ];
Tc_error_4  = [ 7.016417e+00 ; 7.458262e+00 ; 5.149303e+00 ];

%-- Image #5:
omc_5 = [ 1.806956e+00 ; 1.858638e+00 ; -7.160640e-01 ];
Tc_5  = [ -1.280935e+02 ; -3.258329e+00 ; 5.850813e+02 ];
omc_error_5 = [ 9.311146e-03 ; 1.315077e-02 ; 1.573303e-02 ];
Tc_error_5  = [ 7.928138e+00 ; 8.313580e+00 ; 4.540080e+00 ];

%-- Image #6:
omc_6 = [ -8.609281e-01 ; -2.707561e+00 ; 1.279517e+00 ];
Tc_6  = [ 2.863612e+01 ; -8.667389e+01 ; 6.891523e+02 ];
omc_error_6 = [ 1.161043e-02 ; 1.056427e-02 ; 2.151900e-02 ];
Tc_error_6  = [ 9.286797e+00 ; 9.799528e+00 ; 5.151954e+00 ];

%-- Image #7:
omc_7 = [ 3.363624e-01 ; 2.345640e+00 ; -1.050730e+00 ];
Tc_7  = [ 1.235860e+01 ; -4.976117e+01 ; 6.114043e+02 ];
omc_error_7 = [ 7.639902e-03 ; 1.465429e-02 ; 1.676229e-02 ];
Tc_error_7  = [ 8.223431e+00 ; 8.680989e+00 ; 4.301341e+00 ];

%-- Image #8:
omc_8 = [ 9.090671e-01 ; 2.421620e+00 ; 8.722936e-01 ];
Tc_8  = [ -1.752849e+01 ; -9.075496e+01 ; 4.640937e+02 ];
omc_error_8 = [ 1.161768e-02 ; 1.259053e-02 ; 1.916184e-02 ];
Tc_error_8  = [ 6.211051e+00 ; 6.635574e+00 ; 4.774661e+00 ];

%-- Image #9:
omc_9 = [ -4.989107e-01 ; 2.904485e+00 ; 9.698583e-01 ];
Tc_9  = [ 1.511434e+02 ; -3.573495e+01 ; 4.894771e+02 ];
omc_error_9 = [ 5.773099e-03 ; 1.655974e-02 ; 2.276120e-02 ];
Tc_error_9  = [ 6.616282e+00 ; 7.066716e+00 ; 5.597036e+00 ];

%-- Image #10:
omc_10 = [ 2.173444e+00 ; 1.468850e+00 ; -8.848026e-01 ];
Tc_10  = [ -1.324903e+02 ; 8.630334e+00 ; 6.235487e+02 ];
omc_error_10 = [ 1.108888e-02 ; 1.324318e-02 ; 1.594914e-02 ];
Tc_error_10  = [ 8.421320e+00 ; 8.825857e+00 ; 4.718597e+00 ];

