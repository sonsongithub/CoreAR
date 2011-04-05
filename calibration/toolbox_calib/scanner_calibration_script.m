%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main 3D Scanner Calibration Script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;

%--------------------------------------------------------------------------
%-- STEP 1: Calibration of the camera independently of the projector:
%--------------------------------------------------------------------------

fprintf(1,'STEP 1: Calibration of the camera \n');

%% Load the corner coordinates in all the 30 images
load camera_data;

%% Show one example image:
I_cam1 = imread('cam01.bmp');

figure(10);
image(I_cam1);
hold on;
plot(x_1(1,:)+1,x_1(2,:)+1,'r+');
title('Example camera calibration image: cam01.bmp')
hold off;
drawnow;

figure(11);
plot3(X_1(1,:),X_1(2,:),X_1(3,:),'r+');
xlabel('X');
ylabel('Y');
zlabel('Z');
title('3D coordinates of the corresponding points (camera calibration)...')
drawnow;

% Setup the camera model before calibration:
est_dist = [1;0;0;0;0]; %- A first order distortion model is enough
est_alpha = 0; % No Skew needed
center_optim = 1; % Estimate the principal point

% Run the main calibration routine:
go_calib_optim;

% Show the camera location with respect to the patterns:
ext_calib;

% Saving the camera calibration results under camera_results.mat:
saving_calib;
copyfile('Calib_Results.mat','camera_results.mat');
delete('Calib_Results.mat');
delete('Calib_Results.m');


%-- Save the camera calibration results in side variables:
n_ima_cam = n_ima;

fc_cam  = fc;
cc_cam = cc;
kc_cam = kc;
alpha_c_cam = alpha_c;
fc_error_cam  = fc_error;
cc_error_cam = cc_error;
kc_error_cam = kc_error;
alpha_c_error_cam = alpha_c_error;

est_fc_cam = est_fc;
est_dist_cam = est_dist;
est_alpha_cam = est_alpha;
center_optim_cam = center_optim;
nx_cam = nx;
ny_cam = ny;
active_images_cam = active_images;
ind_active_cam = ind_active;


X_1_cam = X_1;
x_1_cam = x_1;
omc_1_cam = omc_1;
Rc_1 = rodrigues(omc_1);
Rc_1_cam = Rc_1;
Tc_1_cam = Tc_1;
omc_error_1_cam = omc_error_1;
Tc_error_1_cam = Tc_error_1;

dX_cam = dX;
dY_cam = dY;


clear fc cc kc alpha_c


%%% Saving the calibration solution (for further refinement)
param = solution;
param_cam = param([1:10 16:end]);





%--------------------------------------------------------------------------
%-- STEP 2: Calibration of the projector having done the camera calibration:
%--------------------------------------------------------------------------

fprintf(1,'STEP 2: Calibration of the projector (having done projector calibration)...\n');

% Load the projector data:

load projector_data; % load the projector corners (previously saved)

% Show how an example of data:
I_proj1 = imread('proj01n.bmp');

figure(20);
image(I_proj1);
hold on;
plot(xproj_1(1,:)+1,xproj_1(2,:)+1,'r+');
title('Corner locations in image proj01n.bmp')
hold off;
drawnow;

figure(21);
plot(x_proj_1(1,:)+1,x_proj_1(2,:)+1,'r+');
title('Corner locations in the projector image plane');
xlabel('x (in projector image)');
ylabel('y (in projector image)');
drawnow;




% Start projector calibration making use of the information from camera
% calibration:

X_proj = []; % 3D coordinates of the points
x_proj = []; % 2D coordinates of the points in the projector image
n_ima_proj = [];

for kk = ind_active,
    eval(['xproj = xproj_' num2str(kk) ';']);
    xprojn = normalize_pixel(xproj,fc_cam,cc_cam,kc_cam,alpha_c_cam);
    eval(['Rc = Rc_' num2str(kk) ';']);
    eval(['Tc = Tc_' num2str(kk) ';']);
    
    Np_proj = size(xproj,2);
    Zc = ((Rc(:,3)'*Tc) * (1./(Rc(:,3)' * [xprojn; ones(1,Np_proj)])));
    Xcp = (ones(3,1)*Zc) .* [xprojn; ones(1,Np_proj)]; % % in the camera frame
    eval(['X_proj_' num2str(kk) ' = Xcp;']); % coordinates of the points in the 
    eval(['X_proj = [X_proj X_proj_' num2str(kk) '];']);
    eval(['x_proj = [x_proj x_proj_' num2str(kk) '];']);
    n_ima_proj = [n_ima_proj kk*ones(1,Np_proj)];
end;


figure(22);
plot(x_proj(1,:)+1,x_proj(2,:)+1,'r+');
title('Complete set of points in the projector image')
xlabel('x (in projector image)');
ylabel('y (in projector image)');
drawnow;

figure(23);
plot3(X_proj(1,:),X_proj(2,:),X_proj(3,:),'r+');
axis equal
title('3D coordinates of the projector points (computed using the camera calibration results)')
xlabel('Xc (camera reference frame)');
ylabel('Yc (camera reference frame)');
zlabel('Zc (camera reference frame)');
drawnow;


% Projector image size: (may or may not be available)
nx = 1024;
ny = 768;

% No calibration image is available (only the corner coordinates)
no_image = 1;

n_ima = 1;
X_1 = X_proj;
x_1 = x_proj;

% Do estimate distortion:
est_dist = [1 0 0 0 0]'; %ones(5,1);
est_alpha = 0;
center_optim = 1;


% Run the main projector calibration routine:
go_calib_optim;



%%% Saving the calibration solution (for further refinement)
param = solution;
param_proj = param([1:10 16:end]);



% Shows the extrinsic parameters:
dX = 30;
dY = 30;
ext_calib;

% Reprojection on the original images:
dont_ask = 1;
reproject_calib;
dont_ask = 0;

saving_calib;
copyfile('Calib_Results.mat','projector_results.mat');
delete('Calib_Results.mat');
delete('Calib_Results.m');


%-- Projector parameters:

fc_proj  = fc;
cc_proj = cc;
kc_proj = kc;
alpha_c_proj = alpha_c;
fc_error_proj  = fc_error;
cc_error_proj = cc_error;
kc_error_proj = kc_error;
alpha_c_error_proj = alpha_c_error;

est_fc_proj = est_fc;
est_dist_proj = est_dist;
est_alpha_proj = est_alpha;
center_optim_proj = center_optim;
nx_proj = nx;
ny_proj = ny;
active_images_proj = active_images;
ind_active_proj = ind_active;

% Position of the global structure wrt the projector:
T_proj = Tc_1;
om_proj = omc_1;
R_proj = rodrigues(om_proj);
T_error_proj = Tc_error_1;
om_error_proj = omc_error_1;


%-- Restore the camera calibration information (previously saved in local variables)
n_ima = n_ima_cam;
X_1 = X_1_cam;
x_1  = x_1_cam;
no_image = 0;
dX = dX_cam;
dY = dY_cam;

omc_1 = omc_1_cam;
Rc_1 = Rc_1_cam;
Tc_1 = Tc_1_cam;
omc_error_1 = omc_error_1_cam;
Tc_error_1 = Tc_error_1_cam;


%----------------------- Retrieve calibration results:

% Intrinsic parameters:

% Projector:
fp = fc_proj;
cp = cc_proj;
kp = kc_proj;
alpha_p = alpha_c_proj;
fp_error = fc_error_proj;
cp_error = cc_error_proj;
kp_error = kc_error_proj;
alpha_p_error = alpha_c_error_proj;

% Camera:
fc = fc_cam;
cc = cc_cam;
kc = kc_cam;
alpha_c = alpha_c_cam;
fc_error = fc_error_cam;
cc_error = cc_error_cam;
kc_error = kc_error_cam;
alpha_c_error = alpha_c_error_cam;

% Extrinsic parameters:

% Relative position of projector and camera:
T = T_proj;
om = om_proj;
R = R_proj;
T_error = T_error_proj;
om_error = om_error_proj;


% Relative prosition of camera wrt world (assuming first pattern as reference -- arbitrary):
omc = omc_1_cam;
Rc = Rc_1_cam;
Tc = Tc_1_cam;

% Relative position of projector wrt world (assuming first pattern as reference -- arbitrary):
Rp = R*Rc;
omp = rodrigues(Rp);
Tp = T + R*Tc;


fprintf(1,'Saving the scanner calibration results in calib_cam_proj.mat...\n');

saving_string = 'save calib_cam_proj  R om T fc fp cc cp alpha_c alpha_p kc kp Rc Rp Tc Tp omc omp n_ima active_images_cam active_images_proj ind_active_cam ind_active_proj T_error om_error fc_error cc_error kc_error alpha_c_error fp_error cp_error kp_error alpha_p_error est_fc_cam est_dist_cam est_alpha_cam center_optim_cam est_fc_proj est_dist_proj est_alpha_proj center_optim_proj param_cam param_proj nx_cam ny_cam nx_proj ny_proj';

for kk = 1:n_ima,
    saving_string = [saving_string ' X_' num2str(kk) ' x_' num2str(kk) ' xproj_' num2str(kk) ' x_proj_' num2str(kk) ' omc_' num2str(kk) ' Rc_' num2str(kk) ' Tc_' num2str(kk) ' omc_error_' num2str(kk)  ' Tc_error_' num2str(kk) ];
end;

eval(saving_string);



%--------------------------------------------------------------------------
%-- STEP 3: Global optimization (optimize over all parameters, camera and projector):
%--------------------------------------------------------------------------

fprintf(1,'STEP 3: Global optimization...This step may take a while...\n');

string_global = 'global n_ima';
for kk = 1:n_ima,
   string_global = [string_global ' x_' num2str(kk) ' X_' num2str(kk) ' xproj_' num2str(kk) ' x_proj_' num2str(kk)];
end;
eval(string_global);   


param = [param_cam([1:4 6 11:end]);param_proj([1:4 6 11:end])];


param_init = param;


options = [1 1e-4 1e-4 1e-6  0 0 0 0 0 0 0 0 0 12000 0 1e-8 0.1 0];
param = leastsq('error_cam_proj3',param,options);


%options = optimset('Display','iter','MaxFunEvals',100,'MaxIter',50);
%param = lsqnonlin('error_cam_proj3',param,options);



%-- Retrive the parameters:

fc = param(1:2);
cc = param(3:4);
alpha_c = 0;
kc = [param(5);zeros(4,1)];

for kk = 1:n_ima,
   omckk = param(kk*6:kk*6+2);
   Tckk = param(kk*6+3:kk*6+5);
   Rckk = rodrigues(omckk);
   eval(['omc_' num2str(kk) '= omckk;']);
   eval(['Tc_' num2str(kk) '= Tckk;']);
   eval(['Rc_' num2str(kk) '= Rckk;']);
end;

fp = param((1:2)+n_ima * 6 + 5);
cp = param((3:4)+n_ima * 6 + 5);
alpha_p = 0;
kp = [param((5)+n_ima * 6 + 5);zeros(4,1)];

om = param((6:8)+n_ima * 6 + 5);
T = param((9:11)+n_ima * 6 + 5);
R = rodrigues(om);

omc = omc_1;
Rc = Rc_1;
Tc = Tc_1;

Rp = R*Rc;
omp = rodrigues(Rp);
Tp = T + R*Tc;


%-- Re-create the parameters:

param_cam = [param(1:4);0;param(5);zeros(4,1);param(6:5+6*n_ima)];
param_proj = [param((1:4)+5+6*n_ima);0;param(5+5+6*n_ima);zeros(4,1);param((6:11)+5+6*n_ima)];


fprintf(1,'Saving the optimized scanner calibration results in calib_cam_proj_optim.mat...\n');

saving_string = 'save calib_cam_proj_optim  R om T fc fp cc cp alpha_c alpha_p kc kp Rc Rp Tc Tp omc omp n_ima active_images_cam active_images_proj ind_active_cam ind_active_proj est_fc_cam est_dist_cam est_alpha_cam center_optim_cam est_fc_proj est_dist_proj est_alpha_proj center_optim_proj param_cam param_proj param_init nx_cam ny_cam nx_proj ny_proj';

for kk = 1:n_ima,
    saving_string = [saving_string ' X_' num2str(kk) ' x_' num2str(kk) ' xproj_' num2str(kk) ' x_proj_' num2str(kk) ' omc_' num2str(kk) ' Rc_' num2str(kk) ' Tc_' num2str(kk) ];
end;

eval(saving_string);


% Save the optimal camera parameters:

no_image = 0;

nx = nx_cam;
ny = ny_cam;

comp_error_calib;

saving_calib;
copyfile('Calib_Results.mat','camera_results_optim.mat');
delete('Calib_Results.mat');
delete('Calib_Results.m');


omc_1_cam = omc_1;
Rc_1_cam = Rc_1;
Tc_1_cam = Tc_1;

% Save the optimal projector parameters:


X_proj = [];
x_proj = [];

for kk = 1:n_ima,
   eval(['xproj = xproj_' num2str(kk) ';']);
   xprojn = normalize_pixel(xproj,fc,cc,kc,alpha_c);
   eval(['Rc = Rc_' num2str(kk) ';']);
   eval(['Tc = Tc_' num2str(kk) ';']);   
   Np_proj = size(xproj,2);
	Zc = ((Rc(:,3)'*Tc) * (1./(Rc(:,3)' * [xprojn; ones(1,Np_proj)])));
	Xcp = (ones(3,1)*Zc) .* [xprojn; ones(1,Np_proj)]; % % in the camera frame
   eval(['X_proj_' num2str(kk) ' = Xcp;']); % coordinates of the points in the 
   eval(['X_proj = [X_proj X_proj_' num2str(kk) '];']);
   eval(['x_proj = [x_proj x_proj_' num2str(kk) '];']);
end;

fc = fp;
cc = cp;
alpha_c = alpha_p;
kc = kp;

n_ima = 1;
X_1 = X_proj;
x_1 = x_proj;
omc_1 = om;
Tc_1 = T;
Rc_1 = R;

% Image size: (may or may not be available)
nx = nx_proj;
ny = ny_proj;

% No calibration image is available (only the corner coordinates)
no_image = 1;

comp_error_calib;

saving_calib;
copyfile('Calib_Results.mat','projector_results_optim.mat');
delete('Calib_Results.mat');
delete('Calib_Results.m');

n_ima = n_ima_cam;
X_1 = X_1_cam;
x_1  = x_1_cam;
no_image = 0;
dX = dX_cam;
dY = dY_cam;

omc_1 = omc_1_cam;
Rc_1 = Rc_1_cam;
Tc_1 = Tc_1_cam;