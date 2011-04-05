
fprintf(1,'Saving the stereo calibration results in Calib_Results_stereo.mat...\n');

string_save = 'save Calib_Results_stereo om R T recompute_intrinsic_right recompute_intrinsic_left calib_name_left format_image_left type_numbering_left image_numbers_left N_slots_left calib_name_right format_image_right type_numbering_right image_numbers_right N_slots_right fc_left cc_left kc_left alpha_c_left KK_left fc_right cc_right kc_right alpha_c_right KK_right active_images dX dY nx ny n_ima active_images_right active_images_left inconsistent_images center_optim_left est_alpha_left est_dist_left est_fc_left est_aspect_ratio_left center_optim_right est_alpha_right est_dist_right est_fc_right est_aspect_ratio_right history param param_error sigma_x om_error T_error fc_left_error cc_left_error kc_left_error alpha_c_left_error fc_right_error cc_right_error kc_right_error alpha_c_right_error';

for kk = 1:n_ima,
    if active_images(kk),
        string_save = [string_save ' X_left_' num2str(kk)  ' omc_left_' num2str(kk) ' Tc_left_' num2str(kk) ' omc_left_error_' num2str(kk) ' Tc_left_error_' num2str(kk)  ' n_sq_x_' num2str(kk) ' n_sq_y_' num2str(kk)];
    end;
end;
eval(string_save);

