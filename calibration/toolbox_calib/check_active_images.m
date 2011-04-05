if n_ima ~= 0,
    
    if ~exist('active_images'),
        active_images = ones(1,n_ima);
    end;
    n_act = length(active_images);
    if n_act < n_ima,
        active_images = [active_images ones(1,n_ima-n_act)];
    else
        if n_act > n_ima,
            active_images = active_images(1:n_ima);
        end;
    end;
    
    ind_active = find(active_images);
    
    if prod(double(active_images == 0)),
        disp('Error: There is no active image. Run Add/Suppress images to add images');
        break
    end;
    
    if exist('center_optim'),
        center_optim = double(center_optim);
    end;
    if exist('est_alpha'),
        est_alpha = double(est_alpha);
    end;
    if exist('est_dist'),
        est_dist = double(est_dist);
    end;
    if exist('est_fc'),
        est_fc = double(est_fc);
    end;
    if exist('est_aspect_ratio'),
        est_aspect_ratio = double(est_aspect_ratio);
    end;
    
end;
