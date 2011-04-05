fprintf(1,'Recomputation of the image corners using Lucchese''s saddle point detector\n');

q = input('This detector only works for X junctions (checker board corners). Is this the case here? ([]=yes, other=no)','s');


if isempty(q),
    
    ima_proc = 1:n_ima;
    
    fprintf(1,'Processing image ');
    
    for kk = ima_proc;
        
        if active_images(kk),
            
            fprintf(1,'%d...',kk);
            
                
                eval(['I = I_' num2str(kk) ';']);
                
                eval(['y = x_' num2str(kk) ';']);
                eval(['wintx = wintx_' num2str(kk) ';']);
                eval(['winty = winty_' num2str(kk) ';']);               
                
                xc = cornerfinder_saddle_point(y+1,I,winty,wintx); % the four corners
                
                eval(['x_' num2str(kk) '= xc - 1;']);
                
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
    
else
    
    fprintf(1,'No recomputation done (The points are not locally saddle points)\n');
    
end;
