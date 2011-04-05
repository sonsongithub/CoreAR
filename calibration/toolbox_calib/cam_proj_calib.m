%%% This code is an additional code that helps doing projector calibration in 3D scanning setup.
%%% This is not a useful code for anyone else but me.
%%% I included it in the toolbox for illustration only.


fprintf(1,'3D scanner calibration code\n');
fprintf(1,'(c) Jean-Yves Bouguet - August 2000\n');
fprintf(1,'Intel Corporation\n');


if ~exist('camera_results.mat'),
   if exist('Calib_Results.mat'),
      copyfile('Calib_Results.mat','camera_results.mat');
      delete('Calib_Results.mat');
   else
      disp('ERROR: Need to calibrate the camera first, save results, and run cam_proj_calib');
      break;
   end;
end;



if 0, % If I want to run camera calibration again
   load camera_results;
   % Do estimate distortion:
   est_dist = [1 0 0 0 0]; %ones(5,1);
   est_alpha = 0;
   center_optim = 1;
   % Run the main calibration routine:
   go_calib_optim;
   saving_calib;
   copyfile('Calib_Results.mat','camera_results.mat');
   delete('Calib_Results.mat');
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% START THE MAIN PROCEDURE %%%%%%%%%%%%%%%%%%%%%%%%%%%

load camera_results;
param = solution;

% Save camera parameters:
fc_save  = fc;
cc_save = cc;
kc_save = kc;
alpha_c_save = alpha_c;

omc_1_save = omc_1;
Rc_1_save = Rc_1;
Tc_1_save = Tc_1;

clear fc cc kc alpha_c


param_cam = param([1:10 16:end]);


% Extract projector data?
if ~exist('projector_data.mat'),
	projector_calib; % extract the projector corners (all the data)
else
   load projector_data; % load the projector corners (previously saved)
end;



% Start projector calibration:

X_proj = [];
x_proj = [];
n_ima_proj = [];

for kk = ind_active,
   eval(['xproj = xproj_' num2str(kk) ';']);
   xprojn = normalize_pixel(xproj,fc_save,cc_save,kc_save,alpha_c_save);
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

% Image size: (may or may not be available)
nx = 1024;
ny = 768;

% No calibration image is available (only the corner coordinates)
no_image = 1;

n_ima_save = n_ima;
X_1_save = X_1;
x_1_save = x_1;
dX_save = dX;
dY_save = dY;

n_ima = 1;
X_1 = X_proj;
x_1 = x_proj;

% Set the toolbox not to prompt the user (choose default values)
dont_ask = 1;

% Do estimate distortion:
est_dist = [1 0 0 0 0]'; %ones(5,1);
est_alpha = 0;
center_optim = 1;


% Run the main calibration routine:
clear fc kc cc alpha_c KK
go_calib_optim;

param = solution;

param_proj = param([1:10 16:end]);

% Shows the extrinsic parameters:
dX = 30;
dY = 30;
ext_calib;

% Reprojection on the original images:
reproject_calib;
%saving_calib;
%copyfile([save_name '.mat'],'projector_results.mat');


saving_calib;

copyfile('Calib_Results.mat','projector_results.mat');
delete('Calib_Results.mat');


n_ima = n_ima_save;
X_1 = X_1_save;
x_1  = x_1_save;
no_image = 0;
dX = dX_save;
dY = dY_save;

%----------------------- Retrieve results:

% Intrinsic:

% Projector:
fp = fc;
cp = cc;
kp = kc;
alpha_p = alpha_c;

% Camera:
fc = fc_save;
cc = cc_save;
kc = kc_save;
alpha_c = alpha_c_save;


% Extrinsic:

% Relative position of projector and camera:
T = Tc_1;
om = omc_1;
R = rodrigues(om);

% Relative prosition of camera wrt world:
omc = omc_1_save;
Rc = Rc_1_save;
Tc = Tc_1_save;

% relative position of projector wrt world:
Rp = R*Rc;
omp = rodrigues(Rp);
Tp = T + R*Tc;

eval(['save calib_cam_proj  R om T fc fp cc cp alpha_c alpha_p kc kp Rc Rp Tc Tp omc omp']);



% Final refinement:

%----------------- global optimization: ---------------------

cam_proj_calib_optim;

