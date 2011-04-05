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
    return;
end

%if ~exist(['I_' num2str(ind_active(1))]),
%   n_ima_save = n_ima;
%   active_images_save = active_images;
%   ima_read_calib;
%   n_ima = n_ima_save;
%   active_images = active_images_save;
%   check_active_images;
%   if no_image_file,
%      disp('Cannot extract corners without images');
%      return;
%   end;
%end;

fprintf(1,'\nRe-extraction of the grid corners on the images (after first calibration)\n');

if ~dont_ask,
    disp('Window size for corner finder (wintx and winty):');
    wintx = input('wintx ([] = 20) = ');
    if isempty(wintx), wintx = 20; end;
    wintx = round(wintx);
    winty = input('winty ([] = 20) = ');
    if isempty(winty), winty = 20; end;
    winty = round(winty);
else
    wintx = 20;
    winty = 20;
end;

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);

if ~dont_ask,
    ima_numbers = input('Number(s) of image(s) to process ([] = all images) = ');
else
    ima_numbers = [];
end;

if isempty(ima_numbers),
   ima_proc = 1:n_ima;
else
   ima_proc = ima_numbers;
end;

if ~dont_ask,
    q_auto = input('Use the projection of 3D grid or manual click ([]=auto, other=manual): ','s');
else
    q_auto = [];
end;

fprintf(1,'Processing image ');

for kk = ima_proc;
    if active_images(kk),
        fprintf(1,'%d...',kk);
        
        if ~type_numbering,   
            number_ext =  num2str(image_numbers(kk));
        else
            number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(kk));
        end;
        ima_name = [calib_name  number_ext '.' format_image];
        
        if exist(ima_name),
            if format_image(1) == 'p';
                if format_image(2) == 'p',
                    I = double(loadppm(ima_name));
                else
                    I = double(loadpgm(ima_name));
                end;
            else
                if format_image(1) == 'r',
                    I = readras(ima_name);
                else
                    I = double(imread(ima_name));
                end;
            end;
            if size(I,3)>1,
                I = 0.299 * I(:,:,1) + 0.5870 * I(:,:,2) + 0.114 * I(:,:,3);
            end;
            [ny,nx,junk] = size(I);
            if isempty(q_auto),
                eval(['y = y_' num2str(kk) ';']);
                xc = cornerfinder(y+1,I,winty,wintx); % the four corners
                eval(['wintx_' num2str(kk) ' = wintx;']);
                eval(['winty_' num2str(kk) ' = winty;']);
                eval(['x_' num2str(kk) '= xc - 1;']);
            else
                fprintf(1,'\n');
                fprintf(1,'\nProcessing image %d...\n',kk);
                click_calib_fisheye_no_read;
            end;
        else
            fprintf(1,'Image %s not found!!!...',ima_name);
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
comp_error_calib_fisheye;
fprintf(1,'\ndone\n');
