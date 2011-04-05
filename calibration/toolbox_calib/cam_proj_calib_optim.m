load camera_results;

string_global = 'global n_ima';
for kk = 1:n_ima,
   string_global = [string_global ' x_' num2str(kk) ' X_' num2str(kk) ' xproj_' num2str(kk) ' x_proj_' num2str(kk)];
end;
eval(string_global);   


%----------------- global optimization: ---------------------

load projector_data; % load the projector corners (previously saved)
load projector_results;

solution_projector = solution;


load camera_results;

solution_camera = solution;

param_cam = solution_camera([1:10 16:end]);
param_proj = solution_projector([1:10 16:end]);

param = [param_cam;param_proj];


% Restart the minimization from here (if need be):
load camera_results;
load calib_cam_proj_optim2;


options = [1 1e-4 1e-4 1e-6  0 0 0 0 0 0 0 0 0 12000 0 1e-8 0.1 0];

%if 0, % use the full distortion model:
   
%   fprintf(1,'Take the complete distortion model\n');

   % test the global error function:
%   e_global = error_cam_proj(param);
   
%   param_init = param;
   
%   param = leastsq('error_cam_proj',param,options);
   
   
%else
   
   % Use a limitd distortion model (no 6th order)
   fprintf(1,'Take the 6th order distortion coefficient out\n');
   
   param = param([1:9 11:11+6*n_ima-1  11+6*n_ima:11+6*n_ima+9-1  11+6*n_ima+9+1:end]);
   
   % test the global error function:
   e_global2 = error_cam_proj2(param);
   
   param_init = param;
   
   param = leastsq('error_cam_proj2',param,options);
   
   param = [param(1:9);0;param(10:10+6*n_ima-1);param(10+6*n_ima:10+6*n_ima+9-1);0;param(10+6*n_ima+9:end)];
  
%end;




% Extract the parameters:

cam_proj_extract_param;

   
% Relative prosition of camera wrt world:
omc = omc_1;
Rc = Rc_1;
Tc = Tc_1;

% relative position of projector wrt world:
Rp = R*Rc;
omp = rodrigues(Rp);
Tp = T + R*Tc;

eval(['save calib_cam_proj_optim3  R om T fc fp cc cp alpha_c alpha_p kc kp Rc Rp Tc Tp omc omp param param_init']);

no_image = 0;
% Image size: (may or may not be available)
nx = 640;
ny = 480;

comp_error_calib;

% Save the optimal camera parameters:
saving_calib;
copyfile('Calib_Results.mat','camera_results_optim3.mat');
delete('Calib_Results.mat');

% Save the optimal camera parameters:
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
nx = 1024;
ny = 768;

% No calibration image is available (only the corner coordinates)
no_image = 1;

comp_error_calib;

saving_calib;
copyfile('Calib_Results.mat','projector_results_optim3.mat');
delete('Calib_Results.mat');

