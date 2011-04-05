% Intrinsic and Extrinsic Camera Parameters
%
% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.
% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.
%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.
% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/


%-- Focal length:
fc = [ 2472.595487333656820 ; 2469.385796015188589 ];

%-- Principal point:
cc = [ 1286.720996289611776 ; 967.735553501556524 ];

%-- Skew coefficient:
alpha_c = 0.000000000000000;

%-- Distortion coefficients:
kc = [ 0.221684936392671 ; -0.916602264332220 ; 0.000092381428580 ; 0.002521025394037 ; 0.000000000000000 ];

%-- Focal length uncertainty:
fc_error = [ 14.909656562544333 ; 15.441107505068601 ];

%-- Principal point uncertainty:
cc_error = [ 16.615801350516499 ; 15.019544418166424 ];

%-- Skew coefficient uncertainty:
alpha_c_error = 0.000000000000000;

%-- Distortion coefficients uncertainty:
kc_error = [ 0.031239221901345 ; 0.165212639655517 ; 0.002677469961137 ; 0.002781409765276 ; 0.000000000000000 ];

%-- Image size:
nx = 2592;
ny = 1936;


%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):
%-- Those variables are used to control which intrinsic parameters should be optimized

n_ima = 13;						% Number of calibration images
est_fc = [ 1 ; 1 ];					% Estimation indicator of the two focal variables
est_aspect_ratio = 1;				% Estimation indicator of the aspect ratio fc(2)/fc(1)
center_optim = 1;					% Estimation indicator of the principal point
est_alpha = 0;						% Estimation indicator of the skew coefficient
est_dist = [ 1 ; 1 ; 1 ; 1 ; 0 ];	% Estimation indicator of the distortion coefficients


%-- Extrinsic parameters:
%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties

%-- Image #1:
omc_1 = [ 1.833612e+00 ; 1.724730e+00 ; -3.399583e-01 ];
Tc_1  = [ -1.227084e+02 ; -9.246067e+01 ; 5.171063e+02 ];
omc_error_1 = [ 5.232975e-03 ; 6.259266e-03 ; 9.184955e-03 ];
Tc_error_1  = [ 3.473996e+00 ; 3.149278e+00 ; 2.985659e+00 ];

%-- Image #2:
omc_2 = [ 1.997409e+00 ; 1.828772e+00 ; -1.726871e-01 ];
Tc_2  = [ -1.142031e+02 ; -8.641820e+01 ; 4.622546e+02 ];
omc_error_2 = [ 5.680531e-03 ; 5.904780e-03 ; 1.055260e-02 ];
Tc_error_2  = [ 3.114483e+00 ; 2.806414e+00 ; 2.806151e+00 ];

%-- Image #3:
omc_3 = [ 2.032109e+00 ; 2.064615e+00 ; 7.722599e-02 ];
Tc_3  = [ -1.059733e+02 ; -1.075848e+02 ; 4.719122e+02 ];
omc_error_3 = [ 6.477171e-03 ; 6.718413e-03 ; 1.297139e-02 ];
Tc_error_3  = [ 3.215211e+00 ; 2.876864e+00 ; 3.181279e+00 ];

%-- Image #4:
omc_4 = [ 1.978265e+00 ; 2.337113e+00 ; 3.002053e-01 ];
Tc_4  = [ -8.496528e+01 ; -1.023292e+02 ; 4.262229e+02 ];
omc_error_4 = [ 6.643240e-03 ; 6.641028e-03 ; 1.348442e-02 ];
Tc_error_4  = [ 2.902857e+00 ; 2.629823e+00 ; 2.917893e+00 ];

%-- Image #5:
omc_5 = [ -1.930829e+00 ; -2.345650e+00 ; -4.327979e-01 ];
Tc_5  = [ -9.927068e+01 ; -7.479543e+01 ; 4.345458e+02 ];
omc_error_5 = [ 5.142860e-03 ; 7.577308e-03 ; 1.310507e-02 ];
Tc_error_5  = [ 2.933353e+00 ; 2.692546e+00 ; 2.970711e+00 ];

%-- Image #6:
omc_6 = [ -1.673988e+00 ; -2.177883e+00 ; -6.706115e-01 ];
Tc_6  = [ -1.071716e+02 ; -5.808384e+01 ; 4.205414e+02 ];
omc_error_6 = [ 4.364882e-03 ; 7.052836e-03 ; 1.052639e-02 ];
Tc_error_6  = [ 2.819087e+00 ; 2.616751e+00 ; 2.926472e+00 ];

%-- Image #7:
omc_7 = [ 1.936154e+00 ; 1.916251e+00 ; 4.012226e-01 ];
Tc_7  = [ -7.126628e+01 ; -9.860552e+01 ; 4.069957e+02 ];
omc_error_7 = [ 6.249711e-03 ; 5.237313e-03 ; 1.016866e-02 ];
Tc_error_7  = [ 2.772091e+00 ; 2.470553e+00 ; 2.825361e+00 ];

%-- Image #8:
omc_8 = [ 1.475878e+00 ; 2.144108e+00 ; 2.164475e-01 ];
Tc_8  = [ -1.181493e+00 ; -1.449323e+02 ; 4.740147e+02 ];
omc_error_8 = [ 5.441745e-03 ; 6.517627e-03 ; 9.576334e-03 ];
Tc_error_8  = [ 3.199440e+00 ; 2.872222e+00 ; 3.151188e+00 ];

%-- Image #9:
omc_9 = [ 2.412613e+00 ; 1.772962e+00 ; 7.016622e-01 ];
Tc_9  = [ -9.769096e+01 ; -4.715448e+01 ; 4.092608e+02 ];
omc_error_9 = [ 7.592138e-03 ; 3.989264e-03 ; 1.153337e-02 ];
Tc_error_9  = [ 2.807915e+00 ; 2.505771e+00 ; 2.942898e+00 ];

%-- Image #10:
omc_10 = [ -2.115555e+00 ; -2.106915e+00 ; 1.421795e-01 ];
Tc_10  = [ -1.348465e+02 ; -9.076652e+01 ; 4.376979e+02 ];
omc_error_10 = [ 6.408328e-03 ; 6.324750e-03 ; 1.306894e-02 ];
Tc_error_10  = [ 2.940238e+00 ; 2.685841e+00 ; 2.662014e+00 ];

%-- Image #11:
omc_11 = [ -1.686843e+00 ; -1.775360e+00 ; -3.233741e-01 ];
Tc_11  = [ -1.472210e+02 ; -7.143182e+01 ; 3.301487e+02 ];
omc_error_11 = [ 4.744198e-03 ; 5.814970e-03 ; 8.900894e-03 ];
Tc_error_11  = [ 2.230311e+00 ; 2.067851e+00 ; 2.155645e+00 ];

%-- Image #12:
omc_12 = [ 1.712145e+00 ; 1.885720e+00 ; -7.526507e-01 ];
Tc_12  = [ -1.145537e+02 ; -9.999824e+01 ; 4.977169e+02 ];
omc_error_12 = [ 4.315239e-03 ; 6.742898e-03 ; 8.817660e-03 ];
Tc_error_12  = [ 3.337502e+00 ; 3.043612e+00 ; 2.478737e+00 ];

%-- Image #13:
omc_13 = [ 1.563035e+00 ; 1.743404e+00 ; -6.648449e-01 ];
Tc_13  = [ -1.150527e+02 ; -9.376326e+01 ; 4.713876e+02 ];
omc_error_13 = [ 4.485253e-03 ; 6.489583e-03 ; 7.908034e-03 ];
Tc_error_13  = [ 3.162767e+00 ; 2.884082e+00 ; 2.344353e+00 ];

