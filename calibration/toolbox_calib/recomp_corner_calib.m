% Re-select te corners after calibration

if ~exist('n_ima')|~exist('fc'),
   fprintf(1,'No calibration data available.\n');
   return;
end;

check_active_images;

flag = 0;
for kk = ind_active,
   if ~exist(['y_' num2str(kk)]),
      flag = 1;
   else
      eval(['ykk = y_' num2str(kk) ';']);
      if isnan(ykk(1,1)),
	 flag = 1;
      end;
   end;
end;

if flag,
   fprintf(1,'Need to calibrate once before before recomputing image corners. Maybe need to load Calib_Results.mat file.\n');
   return;
end;


if n_ima == 0,
    
    fprintf(1,'No image data available\n');
    
else

if ~exist(['I_' num2str(ind_active(1))]),
   n_ima_save = n_ima;
   active_images_save = active_images;
   ima_read_calib;
   n_ima = n_ima_save;
   active_images = active_images_save;
   check_active_images;
   if no_image_file,
      disp('Cannot extract corners without images');
      return;
   end;
end;

fprintf(1,'\nRe-extraction of the grid corners on the images (after first calibration)\n');

disp('Window size for corner finder (wintx and winty):');
wintx = input('wintx ([] = 5) = ');
if isempty(wintx), wintx = 5; end;
wintx = round(wintx);
winty = input('winty ([] = 5) = ');
if isempty(winty), winty = 5; end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);

ima_numbers = input('Number(s) of image(s) to process ([] = all images) = ');

if isempty(ima_numbers),
   ima_proc = 1:n_ima;
else
   ima_proc = ima_numbers;
end;

q_auto = input('Use the projection of 3D grid or manual click ([]=auto, other=manual): ','s');

fprintf(1,'Processing image ');

for kk = ima_proc;
    
    if active_images(kk),
        
        fprintf(1,'%d...',kk);
        
        if isempty(q_auto),
            
            eval(['I = I_' num2str(kk) ';']);
            
            eval(['y = y_' num2str(kk) ';']);
            
            xc = cornerfinder(y+1,I,winty,wintx); % the four corners
            
            eval(['wintx_' num2str(kk) ' = wintx;']);
            eval(['winty_' num2str(kk) ' = winty;']);
            
            eval(['x_' num2str(kk) '= xc - 1;']);
            
        else
            
            fprintf(1,'\n');
            
            eval(['wintx_' num2str(kk) ' = wintx;']);
            eval(['winty_' num2str(kk) ' = winty;']);
            
            click_ima_calib;
            
        end;
        
    else
        
        if ~exist(['omc_' num2str(kk)]),
            
            eval(['dX_' num2str(kk) ' = NaN;']);
            eval(['dY_' num2str(kk) ' = NaN;']);  
            
            eval(['wintx_' num2str(kk) ' = NaN;']);
            eval(['winty_' num2str(kk) ' = NaN;']);
            
            eval(['x_' num2str(kk) ' = NaN*ones(2,1);']);
            eval(['X_' num2str(kk) ' = NaN*ones(3,1);']);
            
            eval(['n_sq_x_' num2str(kk) ' = NaN;']);
            eval(['n_sq_y_' num2str(kk) ' = NaN;']);
            
        end;
        
    end;
    
    
end;

% Recompute the error:

comp_error_calib;

fprintf(1,'\ndone\n');

end;
