%%% Computes the extrinsic parameters for all the active calibration images 

check_active_images;

N_points_views = zeros(1,n_ima);

for kk = 1:n_ima,
    
    if exist(['x_' num2str(kk)]),
        
        eval(['x_kk = x_' num2str(kk) ';']);
        eval(['X_kk = X_' num2str(kk) ';']);
        
        if (isnan(x_kk(1,1))),
            if active_images(kk),
                fprintf(1,'Warning: Cannot calibrate with image %d. Need to extract grid corners first.\n',kk)
                fprintf(1,'         Set active_images(%d)=1; and run Extract grid corners.\n',kk)
            end;
        end;
        if active_images(kk),
            N_points_views(kk) = size(x_kk,2);
            [omckk,Tckk] = compute_extrinsic_init(x_kk,X_kk,fc,cc,kc,alpha_c);
            [omckk,Tckk,Rckk,JJ_kk] = compute_extrinsic_refine(omckk,Tckk,x_kk,X_kk,fc,cc,kc,alpha_c,20,thresh_cond);
            if check_cond,
                if (cond(JJ_kk)> thresh_cond),
                    active_images(kk) = 0;
                    omckk = NaN*ones(3,1);
                    Tckk = NaN*ones(3,1);
                    fprintf(1,'\nWarning: View #%d ill-conditioned. This image is now set inactive.\n',kk)
                    desactivated_images = [desactivated_images kk];
                end;
            end;
            if isnan(omckk(1,1)),
                %fprintf(1,'\nWarning: Desactivating image %d. Re-activate it later by typing:\nactive_images(%d)=1;\nand re-run optimization\n',[kk kk])
                active_images(kk) = 0;
            end;
        else
            omckk = NaN*ones(3,1);
            Tckk = NaN*ones(3,1);
        end;
        
    else
        
        omckk = NaN*ones(3,1);
        Tckk = NaN*ones(3,1);
        
        if active_images(kk),
            fprintf(1,'Warning: Cannot calibrate with image %d. Need to extract grid corners first.\n',kk)
            fprintf(1,'         Set active_images(%d)=1; and run Extract grid corners.\n',kk)
        end;
        
        active_images(kk) = 0;
        
    end;
    
    eval(['omc_' num2str(kk) ' = omckk;']);
    eval(['Tc_' num2str(kk) ' = Tckk;']);
    
end;


check_active_images;
