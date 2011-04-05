%% This code allows complete manual reselection of every corner in the
%% images.
%% This tool is specifically useful in the case of highly distorted images.
%%
%% Use it when in memory efficient mode.
%% In standard mode, use manual_corner_extraction.m


if ~exist('n_ima'),
   fprintf(1,'No image data available\n');
   return;
end;

check_active_images;

if n_ima == 0,
    
    fprintf(1,'No image data available\n');
    
else

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

fprintf(1,'\nManual re-extraction of the grid corners on the images\n');

q_converge = input('Do you want to try to automatically find the closest corner? - only works with ckecker board corners  ([]=yes, other = no)','s');

if isempty(q_converge),
    q_converge = 1;
    fprintf(1,'Automatic refinement of the corner location after manual mouse click\n');
    disp('Window size for corner finder (wintx and winty):');
    wintx = input('wintx ([] = 5) = ');
    if isempty(wintx), wintx = 5; end;
    wintx = round(wintx);
    winty = input('winty ([] = 5) = ');
    if isempty(winty), winty = 5; end;
    winty = round(winty);
    
    fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);
else
    q_converge = 0;
    fprintf(1,'No attempt to refine the corner location after manual mouse click\n');
end;


ima_numbers = input('Number(s) of image(s) to process ([] = all images) = ');

if isempty(ima_numbers),
   ima_proc = 1:n_ima;
else
   ima_proc = ima_numbers;
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
            
            
            if format_image(1) == 'p',
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
            
            eval(['x = x_' num2str(kk) ';']);
            
            Np = size(x,2);
            
            
            figure(2); 
            image(I);
            colormap(map);
            hold on;
            hx = plot(x(1,:)+1,x(2,:)+1,'r+');
            hcp = plot(x(1,1)+1,x(2,1)+1,'co');
            hold off;
            
            for np = 1:Np,
                
                set(hcp,'Xdata',x(1,np)+1,'Ydata',x(2,np)+1);
                
                
                title(['Click on corner #' num2str(np) ' out of ' num2str(Np) ' (right button: keep point unchanged)']);
                
                [xi,yi,b] = ginput4(1);
                
                if b==1,
                    xxi = [xi;yi];
                    if q_converge,
                        [xxi] = cornerfinder(xxi,I,winty,wintx);
                    end;
                    x(1,np) = xxi(1) - 1;
                    x(2,np) = xxi(2) - 1;
                    set(hx,'Xdata',x(1,:)+1,'Ydata',x(2,:)+1);
                end;
                
            end;
            
            eval(['wintx_' num2str(kk) ' = wintx;']);
            eval(['winty_' num2str(kk) ' = winty;']);
            
            eval(['x_' num2str(kk) '= x;']);
            
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

fprintf(1,'\ndone\n');

end;
