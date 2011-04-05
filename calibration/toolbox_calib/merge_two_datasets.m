fprintf(1,'Script that merges two "Cabib_Results.mat" data sets of the same camera into a single dataset\n')

dir;


cont = 1;
while cont
    data_set1 = input('Filename of the first dataset (with complete path if necessary): ','s');    
    cont = ((exist(data_set1)~=2));
    if cont,
        fprintf(1,'File not found. Try again.\n');
    end;
end;
cont = 1;
while cont
    data_set2 = input('Filename of the second dataset (with complete path if necessary): ','s');    
    cont = ((exist(data_set2)~=2));
    if cont,
        fprintf(1,'File not found. Try again.\n');
    end;
end;


load(data_set1); % part1\Calib_Results;

shift = n_ima;

load(data_set2); % part2\Calib_Results;

active_images2 = active_images;
n_ima2 = n_ima;


for kk = 1:n_ima

eval(['X_' num2str(kk+shift) ' = X_' num2str(kk) ';']);

    
eval(['dX_' num2str(kk+shift) ' = dX_' num2str(kk) ';']);
eval(['dY_' num2str(kk+shift) ' = dY_' num2str(kk) ';']);

eval(['wintx_' num2str(kk+shift) ' = wintx_' num2str(kk) ';']);
eval(['winty_' num2str(kk+shift) ' = winty_' num2str(kk) ';']);

eval(['x_' num2str(kk+shift) ' = x_' num2str(kk) ';']);
eval(['y_' num2str(kk+shift) ' = y_' num2str(kk) ';']);

eval(['n_sq_x_' num2str(kk+shift) ' = n_sq_x_' num2str(kk) ';']);
eval(['n_sq_y_' num2str(kk+shift) ' = n_sq_y_' num2str(kk) ';']);


eval(['omc_' num2str(kk+shift) ' = omc_' num2str(kk) ';']);
eval(['Tc_' num2str(kk+shift) ' = Tc_' num2str(kk) ';']);

end;

load(data_set1); % part1\Calib_Results;

n_ima = n_ima + n_ima2;
active_images = [active_images active_images2];

no_image = 1;

% Recompute the error (in the vector ex):
comp_error_calib;

fprintf('The two calibration datasets are now merged. You are now ready to run calibration. \n');

