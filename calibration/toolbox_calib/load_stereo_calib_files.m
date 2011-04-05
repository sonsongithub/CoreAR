
dir('*mat');

fprintf(1,'Loading of the individual left and right camera calibration files\n');

calib_file_name_left = input('Name of the left camera calibration file ([]=Calib_Results_left.mat): ','s');

if isempty(calib_file_name_left),
    calib_file_name_left = 'Calib_Results_left.mat';
end;


calib_file_name_right = input('Name of the right camera calibration file ([]=Calib_Results_right.mat): ','s');

if isempty(calib_file_name_right),
    calib_file_name_right = 'Calib_Results_right.mat';
end;


if (exist(calib_file_name_left)~=2)|(exist(calib_file_name_right)~=2),
    fprintf(1,'Error: left and right calibration files do not exist.\n');
    return;
end;


fprintf(1,'Loading the left camera calibration result file %s...\n',calib_file_name_left);

clear calib_name

load(calib_file_name_left);

fc_left = fc;
cc_left = cc;
kc_left = kc;
alpha_c_left = alpha_c;
fc_left_error = fc_error;
cc_left_error = cc_error;
kc_left_error = kc_error;
alpha_c_left_error = alpha_c_error;
KK_left = KK;

if exist('calib_name'),
    calib_name_left = calib_name;
    format_image_left = format_image;
    type_numbering_left = type_numbering;
    image_numbers_left = image_numbers;
    N_slots_left = N_slots;
else
    calib_name_left = '';
    format_image_left = '';
    type_numbering_left = '';
    image_numbers_left = '';
    N_slots_left = '';
end;

    
X_left = [];


om_left_list = [];
T_left_list = [];

for kk = 1:n_ima,
   
   if active_images(kk),
      
      eval(['Xkk = X_' num2str(kk) ';']);
      eval(['omckk = omc_' num2str(kk) ';']);
      eval(['Rckk = Rc_' num2str(kk) ';']);
      eval(['Tckk = Tc_' num2str(kk) ';']);
      
      N = size(Xkk,2);
      
      Xckk = Rckk * Xkk  + Tckk*ones(1,N);
      
      X_left = [X_left Xckk];

      om_left_list = [om_left_list omckk];
      
      T_left_list = [T_left_list Tckk];
      
  end;
end;



fprintf(1,'Loading the right camera calibration result file %s...\n',calib_file_name_right);

clear calib_name

load(calib_file_name_right);

fc_right = fc;
cc_right = cc;
kc_right = kc;
alpha_c_right = alpha_c;
KK_right = KK;
fc_right_error = fc_error;
cc_right_error = cc_error;
kc_right_error = kc_error;
alpha_c_right_error = alpha_c_error;

if exist('calib_name'),
    calib_name_right = calib_name;
    format_image_right = format_image;
    type_numbering_right = type_numbering;
    image_numbers_right = image_numbers;
    N_slots_right = N_slots;
else
    calib_name_right = '';
    format_image_right = '';
    type_numbering_right = '';
    image_numbers_right = '';
    N_slots_right = '';
end;

X_right = [];

om_right_list = [];
T_right_list = [];


for kk = 1:n_ima,
   
   if active_images(kk),
      
      eval(['Xkk = X_' num2str(kk) ';']);
      eval(['omckk = omc_' num2str(kk) ';']);
      eval(['Rckk = Rc_' num2str(kk) ';']);
      eval(['Tckk = Tc_' num2str(kk) ';']);
      
      N = size(Xkk,2);
      
      Xckk = Rckk * Xkk  + Tckk*ones(1,N);
      
      X_right = [X_right Xckk];
      
      om_right_list = [om_right_list omckk];
      T_right_list = [T_right_list Tckk];
      
   end;
end;




om_ref_list = [];
T_ref_list = [];
for ii = 1:size(om_left_list,2),
    % Align the structure from the first view:
    R_ref = rodrigues(om_right_list(:,ii)) * rodrigues(om_left_list(:,ii))';
    T_ref = T_right_list(:,ii) - R_ref * T_left_list(:,ii);
    om_ref = rodrigues(R_ref);
    om_ref_list = [om_ref_list om_ref];
    T_ref_list = [T_ref_list T_ref];
end;


% Robust estimate of the initial value for rotation and translation between the two views:
om = median(om_ref_list,2);
T = median(T_ref_list,2);




if 0,
    figure(10);
    plot3(X_right(1,:),X_right(2,:),X_right(3,:),'bo');
    hold on;
    [Xr2] = rigid_motion(X_left,om,T);
    plot3(Xr2(1,:),Xr2(2,:),Xr2(3,:),'r+');
    hold off;
    drawnow;
end;


R = rodrigues(om);



% Re-optimize now over all the set of extrinsic unknows (global optimization) and intrinsic parameters:

load(calib_file_name_left); % Calib_Results_left;

for kk = 1:n_ima,
   if active_images(kk),
      eval(['X_left_'  num2str(kk) ' = X_' num2str(kk) ';']);
      eval(['x_left_'  num2str(kk) ' = x_' num2str(kk) ';']);
      eval(['omc_left_' num2str(kk) ' = omc_' num2str(kk) ';']);
      eval(['Rc_left_' num2str(kk) ' = Rc_' num2str(kk) ';']);
      eval(['Tc_left_' num2str(kk) ' = Tc_' num2str(kk) ';']);
   end;
end;

center_optim_left = center_optim;
est_alpha_left = est_alpha;
est_dist_left = est_dist;
est_fc_left = est_fc;
est_aspect_ratio_left = est_aspect_ratio;
active_images_left = active_images;


load(calib_file_name_right);

for kk = 1:n_ima,
   if active_images(kk),
      eval(['X_right_'  num2str(kk) ' = X_' num2str(kk) ';']);
      eval(['x_right_'  num2str(kk) ' = x_' num2str(kk) ';']);
   end;
end;

center_optim_right = center_optim;
est_alpha_right = est_alpha;
est_dist_right = est_dist;
est_fc_right = est_fc;
est_aspect_ratio_right = est_aspect_ratio;
active_images_right = active_images;


active_images = active_images_left & active_images_right;



fprintf(1,'\n\n\nStereo calibration parameters after loading the individual calibration files:\n');


fprintf(1,'\n\nIntrinsic parameters of left camera:\n\n');
fprintf(1,'Focal Length:          fc_left = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[fc_left;fc_left_error]);
fprintf(1,'Principal point:       cc_left = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[cc_left;cc_left_error]);
fprintf(1,'Skew:             alpha_c_left = [ %3.5f ] ± [ %3.5f  ]   => angle of pixel axes = %3.5f ± %3.5f degrees\n',[alpha_c_left;alpha_c_left_error],90 - atan(alpha_c_left)*180/pi,atan(alpha_c_left_error)*180/pi);
fprintf(1,'Distortion:            kc_left = [ %3.5f   %3.5f   %3.5f   %3.5f  %5.5f ] ± [ %3.5f   %3.5f   %3.5f   %3.5f  %5.5f ]\n',[kc_left;kc_left_error]);   


fprintf(1,'\n\nIntrinsic parameters of right camera:\n\n');
fprintf(1,'Focal Length:          fc_right = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[fc_right;fc_right_error]);
fprintf(1,'Principal point:       cc_right = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[cc_right;cc_right_error]);
fprintf(1,'Skew:             alpha_c_right = [ %3.5f ] ± [ %3.5f  ]   => angle of pixel axes = %3.5f ± %3.5f degrees\n',[alpha_c_right;alpha_c_right_error],90 - atan(alpha_c_right)*180/pi,atan(alpha_c_right_error)*180/pi);
fprintf(1,'Distortion:            kc_right = [ %3.5f   %3.5f   %3.5f   %3.5f  %5.5f ] ± [ %3.5f   %3.5f   %3.5f   %3.5f  %5.5f ]\n',[kc_right;kc_right_error]);   


fprintf(1,'\n\nExtrinsic parameters (position of right camera wrt left camera):\n\n');
fprintf(1,'Rotation vector:             om = [ %3.5f   %3.5f  %3.5f ]\n',om);
fprintf(1,'Translation vector:           T = [ %3.5f   %3.5f  %3.5f ]\n',T);


