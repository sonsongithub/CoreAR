%%% INPUT THE IMAGE FILE NAME:

if ~exist('fc')|~exist('cc')|~exist('kc')|~exist('alpha_c')
    fprintf(1,'No intrinsic camera parameters available.\n');
    return
end

KK = [fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2) ; 0 0 1];

disp('Program that corrects distorted images');
disp('The intrinsic camera parameters are assumed to be known (previously computed)');

fprintf(1,'\n')

quest = input('Do you want to undistort all the calibration images ([],0) or a new image (1)? ');

if isempty(quest)
    quest = 0;
end

if ~quest
    if ~exist(['I_' num2str(ind_active(1))])
        ima_read_calib;
    end
    
    check_active_images;   
    
    format_image2 = format_image;
    if format_image2(1) == 'j'
        format_image2 = 'bmp';
    end
    
    for kk = 1:n_ima
        if exist(['I_' num2str(kk)])
            eval(['I = I_' num2str(kk) ';']);
            [I2] = rect(I,eye(3),fc,cc,kc,KK);
            
            if ~type_numbering 
                number_ext =  num2str(image_numbers(kk));
            else
                number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(kk));
            end
            
            ima_name2 = [calib_name '_rect' number_ext '.' format_image2];
            fprintf(1,['Saving undistorted image under ' ima_name2 '...\n'])
            
            if format_image2(1) == 'p'
                if format_image2(2) == 'p'
                    saveppm(ima_name2,uint8(round(I2)));
                else
                    savepgm(ima_name2,uint8(round(I2)));
                end
            else
                if format_image2(1) == 'r'
                    writeras(ima_name2,round(I2),gray(256));
                else
                    imwrite(uint8(round(I2)),gray(256),ima_name2,format_image2);                       
                end
            end
        end
    end
    
    fprintf(1,'done\n')
else
    dir
    fprintf(1,'\n')
    
    image_name = input('Image name (full name without extension): ','s');
    
    format_image2 = '0';
    
    while format_image2 == '0'
        format_image2 =  input('Image format ([]=''r''=''ras'', ''b''=''bmp'', ''t''=''tif'', ''p''=''pgm'', ''j''=''jpg'', ''m''=''ppm''): ','s');
        
        if isempty(format_image2)
            format_image2 = 'ras';
        end
        
        if lower(format_image2(1)) == 'm'
            format_image2 = 'ppm';
        else
            if lower(format_image2(1)) == 'b'
                format_image2 = 'bmp';
            else
                if lower(format_image2(1)) == 't'
                    format_image2 = 'tif';
                else
                    if lower(format_image2(1)) == 'p'
                        format_image2 = 'pgm';
                    else
                        if lower(format_image2(1)) == 'j'
                            format_image2 = 'jpg';
                        else
                            if lower(format_image2(1)) == 'r'
                                format_image2 = 'ras';
                            else  
                                disp('Invalid image format');
                                format_image2 = '0'; % Ask for format once again
                            end
                        end
                    end
                end
            end
        end
    end
    
    ima_name = [image_name '.' format_image2];
    
    
    %%% READ IN IMAGE:
    if format_image2(1) == 'p'
        if format_image2(2) == 'p'
            I = double(loadppm(ima_name));
        else
            I = double(loadpgm(ima_name));
        end
    else
        if format_image2(1) == 'r'
            I = readras(ima_name);
        else
            I = double(imread(ima_name));
        end
    end
    
    if (size(I,1)>ny)|(size(I,2)>nx)
        I = I(1:ny,1:nx);
    end
    
    %% SHOW THE ORIGINAL IMAGE:
    figure(2);
    image(uint8(I));
    title('Original image (with distortion) - Stored in array I')
    drawnow;
    
    %% UNDISTORT THE IMAGE:
    fprintf(1,'Computing the undistorted image...')
    
    [Ipart_1] = rect(I(:,:,1),eye(3),fc,cc,kc,alpha_c,KK);
    [Ipart_2] = rect(I(:,:,2),eye(3),fc,cc,kc,alpha_c,KK);
    [Ipart_3] = rect(I(:,:,3),eye(3),fc,cc,kc,alpha_c,KK);
    
    I2 = ones(ny, nx,3);
    I2(:,:,1) = Ipart_1;
    I2(:,:,2) = Ipart_2;
    I2(:,:,3) = Ipart_3;
    
    fprintf(1,'done\n')
    
    figure(3);
    image(uint8(I2));
    title('Undistorted image - Stored in array I2')
    drawnow;
    
    %% SAVE THE IMAGE IN FILE:
    ima_name2 = [image_name '_rect_color.' format_image2];
    
    fprintf(1,['Saving undistorted image under ' ima_name2 '...'])
    
    if format_image2(1) == 'p'
        if format_image2(2) == 'p'
            saveppm(ima_name2,uint8(round(I2)));
        else
            savepgm(ima_name2,uint8(round(I2)));
        end
    else
        if format_image2(1) == 'r'
            writeras(ima_name2,round(I2),gray(256));
        else
            imwrite(uint8(round(I2)),ima_name2,format_image2);
        end
    end
    
    fprintf(1,'done\n')
end