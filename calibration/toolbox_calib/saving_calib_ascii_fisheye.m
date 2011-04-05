if ~exist('save_name'),
    save_name = 'Calib_Results';
end;

fprintf(1,'Generating the matlab script file %s.m containing the intrinsic and extrinsic parameters...\n',save_name)


fid = fopen([ save_name '.m'],'wt');

fprintf(fid,'%% Intrinsic and Extrinsic Camera Parameters\n');
fprintf(fid,'%%\n');
fprintf(fid,'%% This script file can be directly excecuted under Matlab to recover the camera intrinsic and extrinsic parameters.\n');
fprintf(fid,'%% IMPORTANT: This file contains neither the structure of the calibration objects nor the image coordinates of the calibration points.\n');
fprintf(fid,'%%            All those complementary variables are saved in the complete matlab data file Calib_Results.mat.\n');
fprintf(fid,'%% For more information regarding the calibration model visit http://www.vision.caltech.edu/bouguetj/calib_doc/\n');
fprintf(fid,'\n\n');
fprintf(fid,'%%-- Focal length:\n');
fprintf(fid,'fc = [ %5.15f ; %5.15f ];\n',fc);
fprintf(fid,'\n');
fprintf(fid,'%%-- Principal point:\n');
fprintf(fid,'cc = [ %5.15f ; %5.15f ];\n',cc);
fprintf(fid,'\n');
fprintf(fid,'%%-- Skew coefficient:\n');
fprintf(fid,'alpha_c = %5.15f;\n',alpha_c);
fprintf(fid,'\n');
fprintf(fid,'%%-- Distortion coefficients:\n');
fprintf(fid,'kc = [ %5.15f ; %5.15f ; %5.15f ; %5.15f ];\n',kc);
fprintf(fid,'\n');
fprintf(fid,'%%-- Focal length uncertainty:\n');
fprintf(fid,'fc_error = [ %5.15f ; %5.15f ];\n',fc_error);
fprintf(fid,'\n');
fprintf(fid,'%%-- Principal point uncertainty:\n');
fprintf(fid,'cc_error = [ %5.15f ; %5.15f ];\n',cc_error);
fprintf(fid,'\n');
fprintf(fid,'%%-- Skew coefficient uncertainty:\n');
fprintf(fid,'alpha_c_error = %5.15f;\n',alpha_c_error);
fprintf(fid,'\n');
fprintf(fid,'%%-- Distortion coefficients uncertainty:\n');
fprintf(fid,'kc_error = [ %5.15f ; %5.15f ; %5.15f ; %5.15f ];\n',kc_error);
fprintf(fid,'\n');
fprintf(fid,'%%-- Image size:\n');
fprintf(fid,'nx = %d;\n',nx);
fprintf(fid,'ny = %d;\n',ny);
fprintf(fid,'\n');
fprintf(fid,'\n');
fprintf(fid,'%%-- Various other variables (may be ignored if you do not use the Matlab Calibration Toolbox):\n');
fprintf(fid,'%%-- Those variables are used to control which intrinsic parameters should be optimized\n');
fprintf(fid,'\n');
fprintf(fid,'n_ima = %d;\t\t\t\t\t\t%% Number of calibration images\n',n_ima);
fprintf(fid,'est_fc = [ %d ; %d ];\t\t\t\t\t%% Estimation indicator of the two focal variables\n',est_fc);
fprintf(fid,'est_aspect_ratio = %d;\t\t\t\t%% Estimation indicator of the aspect ratio fc(2)/fc(1)\n',est_aspect_ratio);
fprintf(fid,'center_optim = %d;\t\t\t\t\t%% Estimation indicator of the principal point\n',center_optim);
fprintf(fid,'est_alpha = %d;\t\t\t\t\t\t%% Estimation indicator of the skew coefficient\n',est_alpha);
fprintf(fid,'est_dist = [ %d ; %d ; %d ; %d ; %d ];\t%% Estimation indicator of the distortion coefficients\n',est_dist);
fprintf(fid,'\n\n');
fprintf(fid,'%%-- Extrinsic parameters:\n');
fprintf(fid,'%%-- The rotation (omc_kk) and the translation (Tc_kk) vectors for every calibration image and their uncertainties\n');
fprintf(fid,'\n');
for kk = 1:n_ima,
    fprintf(fid,'%%-- Image #%d:\n',kk);
    eval(['omckk = omc_' num2str(kk) ';']);
    eval(['Tckk = Tc_' num2str(kk) ';']);
    fprintf(fid,'omc_%d = [ %d ; %d ; %d ];\n',kk,omckk);
    fprintf(fid,'Tc_%d  = [ %d ; %d ; %d ];\n',kk,Tckk);
    if (exist(['Tc_error_' num2str(kk)])==1) & (exist(['omc_error_' num2str(kk)])==1),
        eval(['omckk_error = omc_error_' num2str(kk) ';']);
        eval(['Tckk_error = Tc_error_' num2str(kk) ';']);
        fprintf(fid,'omc_error_%d = [ %d ; %d ; %d ];\n',kk,omckk_error);
        fprintf(fid,'Tc_error_%d  = [ %d ; %d ; %d ];\n',kk,Tckk_error);
    end;
    fprintf(fid,'\n');
end;

fclose(fid);