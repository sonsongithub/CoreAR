%%% Script that combines two calibration sets together.


dir;

name1 = input('Calibration file name #1: ','s');
name2 = input('Calibration file name #2: ','s');


load(name1);

n_ima_1 = n_ima;


load(name2);

n_ima_2= n_ima;
active_images_2 = active_images;

for kk=n_ima:-1:1,
    
    eval(['X_' num2str(kk+n_ima_1) '=X_' num2str(kk) ';' ]);
    eval(['x_' num2str(kk+n_ima_1) '=x_' num2str(kk) ';' ]);
    eval(['dX_' num2str(kk+n_ima_1) '=dX_' num2str(kk) ';' ]);
    eval(['dY_' num2str(kk+n_ima_1) '=dY_' num2str(kk) ';' ]);
    eval(['n_sq_x_' num2str(kk+n_ima_1) '=n_sq_x_' num2str(kk) ';' ]);
    eval(['n_sq_y_' num2str(kk+n_ima_1) '=n_sq_y_' num2str(kk) ';' ]);
    eval(['wintx_' num2str(kk+n_ima_1) '=wintx_' num2str(kk) ';' ]);
    eval(['winty_' num2str(kk+n_ima_1) '=winty_' num2str(kk) ';' ]);

end;

load(name1);

n_ima = n_ima + n_ima_2;
active_images = [ active_images active_images_2];

%no_image = 1;

clear calib_name  format_image type_numbering image_numbers N_slots