
fprintf(1,'\nStereo calibration parameters:\n');


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
if ~exist('om_error')|~exist('T_error'),
    fprintf(1,'Rotation vector:             om = [ %3.5f   %3.5f  %3.5f ]\n',[om]);
    fprintf(1,'Translation vector:           T = [ %3.5f   %3.5f  %3.5f ]\n',[T]);
else
    fprintf(1,'Rotation vector:             om = [ %3.5f   %3.5f  %3.5f ] ± [ %3.5f   %3.5f  %3.5f ]\n',[om;om_error]);
    fprintf(1,'Translation vector:           T = [ %3.5f   %3.5f  %3.5f ] ± [ %3.5f   %3.5f  %3.5f ]\n',[T;T_error]);
end;

fprintf(1,'\n\nNote: The numerical errors are approximately three times the standard deviations (for reference).\n\n')
