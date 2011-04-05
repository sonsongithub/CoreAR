
if ~exist('n_ima'),
   fprintf(1,'No calibration data available.\n');
   return;
end;

check_active_images;

for kk = 1:n_ima,
   if ~exist(['dX_' num2str(kk)]), eval(['dX_' num2str(kk) '= dX;']); end;
   if ~exist(['dY_' num2str(kk)]), eval(['dY_' num2str(kk) '= dY;']); end;
end;

if ~exist('wintx'),
   wintx = [];
   winty = [];
end;

if ~exist('dX_default'),
   dX_default = [];
   dY_default = [];
end;

if ~exist('dX'),
    dX = [];
end;
if ~exist('dY'),
    dY = dX;
end;


if ~exist('wintx_default')|~exist('winty_default'),
    wintx_default = max(round(nx/128),round(ny/96));
    winty_default = wintx_default;
end;

if ~exist('alpha_c'),
   alpha_c = 0;
end;

if ~exist('err_std'),
    err_std = [NaN;NaN];
end;

for kk = 1:n_ima,

   if ~exist(['n_sq_x_' num2str(kk)]),
   	eval(['n_sq_x_' num2str(kk) ' = NaN;']);
   	eval(['n_sq_y_' num2str(kk) ' = NaN;']);
   end; 
   if ~exist(['wintx_' num2str(kk)]),
   	eval(['wintx_' num2str(kk) ' = NaN;']);
   	eval(['winty_' num2str(kk) ' = NaN;']);
   end;
end;

save_name = 'camera_data';

if exist([ save_name '.mat'])==2,
    disp('WARNING: File Calib_Results.mat already exists');
    if exist('copyfile')==2,
        pfn = -1;
        cont = 1;
        while cont,
            pfn = pfn + 1;
            postfix = ['_old' num2str(pfn)];
            save_name = [ 'camera_data' postfix];
            cont = (exist([ save_name '.mat'])==2);
        end;
        copyfile('camera_data.mat',[save_name '.mat']);
        disp(['Copying the current camera_calib_data.mat file to ' save_name '.mat']);
        cont_save = 1;
    else
        disp('The file camera_data.mat is about to be changed.');
        cont_save = input(1,'Do you want to continue? ([]=no,other=yes) ','s');
        cont_save = ~isempty(cont_save);
    end;
else
    cont_save = 1;
end;


if cont_save,
    
    save_name = 'camera_data';
    
    if exist('calib_name'),
        
        fprintf(1,['\nSaving calibration data under ' save_name '.mat\n']);
        
        string_save = ['save ' save_name ' active_images ind_active wintx winty n_ima type_numbering N_slots first_num image_numbers format_image calib_name nx ny dX_default dY_default dX dY wintx_default winty_default'];
        
        for kk = 1:n_ima,
            string_save = [string_save ' X_' num2str(kk) ' x_' num2str(kk) ' n_sq_x_' num2str(kk) ' n_sq_y_' num2str(kk) ' wintx_' num2str(kk) ' winty_' num2str(kk) ' dX_' num2str(kk) ' dY_' num2str(kk)];
        end;
        
    else
        
        fprintf(1,['\nSaving calibration data under ' save_name '.mat (no image version)\n']);
        
        string_save = ['save ' save_name ' active_images ind_active wintx winty n_ima nx ny dX_default dY_default dX dY wintx_default winty_default '];
        
        for kk = 1:n_ima,
            string_save = [string_save ' X_' num2str(kk) ' x_' num2str(kk)  ' n_sq_x_' num2str(kk) ' n_sq_y_' num2str(kk) ' wintx_' num2str(kk) ' winty_' num2str(kk) ' dX_' num2str(kk) ' dY_' num2str(kk)];
        end;
        
    end;
    
    
    
    %fprintf(1,'To load later click on Load\n');
    
    eval(string_save);
    
    fprintf(1,'done\n');
    
end;
