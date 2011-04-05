% Color code for each image:

if ~exist('n_ima')|~exist('fc'),
    fprintf(1,'No calibration data available.\n');
    return;
end;

check_active_images;

if ~exist('alpha_c'),
    alpha_c = 0;
    est_alpha = 0;
end;

%if length(kc) == 4;
%    kc = [kc;0];
%end;

%if ~exist('est_dist'),
%    est_dist = (kc~=0);
%else
%    if length(est_dist) == 4;
%        est_dist = [est_dist;0];
%    end;
%end;

if ~exist('err_std'),
    comp_error_calib_fisheye;
end;


if ~exist('fc_error'),
    
    fprintf(1,'\n\nCalibration results:\n\n');
    fprintf(1,'Focal Length:          fc = [ %3.5f   %3.5f ]\n',[fc]);
    fprintf(1,'Principal point:       cc = [ %3.5f   %3.5f ]\n',[cc]);
    fprintf(1,'Skew:             alpha_c = [ %3.5f ]  => angle of pixel axes = %3.5f degrees\n',[alpha_c],90 - atan(alpha_c)*180/pi);
    fprintf(1,'Fisheye Distortion:    kc = [ %3.5f   %3.5f   %3.5f   %3.5f ]\n',[kc]);   
    if n_ima ~= 0,
        fprintf(1,'Pixel error:          err = [ %3.5f   %3.5f ]\n',err_std);
    end;
    fprintf(1,'\n\n\n');     

else
    
    fprintf(1,'\n\nCalibration results (with uncertainties):\n\n');
    fprintf(1,'Focal Length:          fc = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[fc;fc_error]);
    fprintf(1,'Principal point:       cc = [ %3.5f   %3.5f ] ± [ %3.5f   %3.5f ]\n',[cc;cc_error]);
    fprintf(1,'Skew:             alpha_c = [ %3.5f ] ± [ %3.5f  ]   => angle of pixel axes = %3.5f ± %3.5f degrees\n',[alpha_c;alpha_c_error],90 - atan(alpha_c)*180/pi,atan(alpha_c_error)*180/pi);
    fprintf(1,'Fisheye Distortion:    kc = [ %3.5f   %3.5f   %3.5f   %3.5f ] ± [ %3.5f   %3.5f   %3.5f   %3.5f ]\n',[kc;kc_error]);
    if n_ima ~= 0,
        fprintf(1,'Pixel error:          err = [ %3.5f   %3.5f ]\n',err_std);
    end;
    fprintf(1,'\n',err_std); 
    fprintf(1,'Note: The numerical errors are approximately three times the standard deviations (for reference).\n\n\n')
    
end;
