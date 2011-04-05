%%% INPUT THE IMAGE FILE NAME:

graphout = 0;

if ~exist('fc')|~exist('cc')|~exist('kc')|~exist('alpha_c'),
   fprintf(1,'No intrinsic camera parameters available. Maybe, need to load Calib_Results.mat\n');
   return;
end;

KK = [fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2) ; 0 0 1];

disp('Program that undistorts a whole sequence of images (works with bmp only so far... needs some debugging)');
disp('The intrinsic camera parameters are assumed to be known (previously computed)');
disp('After undistortion, the intrinsic parameters fc, cc, alpha_c remain unchanged. The distortion coefficient vector kc is zero');

dir;

fprintf(1,'\n');

seq_name = input('Basename of sequence images (without number nor suffix): ','s');

format_image_seq = '0';

while format_image_seq == '0',    
    format_image_seq =  input('Image format: ([]=''r''=''ras'', ''b''=''bmp'', ''t''=''tif'', ''p''=''pgm'', ''j''=''jpg'', ''m''=''ppm'') ','s');
    if isempty(format_image_seq),
        format_image_seq = 'ras';
    else
        if lower(format_image_seq(1)) == 'm',
            format_image_seq = 'ppm';
        else
            if lower(format_image_seq(1)) == 'b',
                format_image_seq = 'bmp';
            else
                if lower(format_image_seq(1)) == 't',
                    format_image_seq = 'tif';
                else
                    if lower(format_image_seq(1)) == 'p',
                        format_image_seq = 'pgm';
                    else
                        if lower(format_image_seq(1)) == 'j',
                            format_image_seq = 'jpg';
                        else
                            if lower(format_image_seq(1)) == 'r',
                                format_image_seq = 'ras';
                            else  
                                disp('Invalid image format');
                                format_image_seq = '0'; % Ask for format once again
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

    
ima_sequence = dir( [ seq_name '*.' format_image_seq]);
    
if isempty(ima_sequence),
    fprintf(1,'No image found\n');
    return;
end;

ima_name = ima_sequence(1).name;
if format_image_seq(1) == 'p',
    if format_image_seq(2) == 'p',
        I = double(loadppm(ima_name));
    else
        I = double(loadpgm(ima_name));
    end;
else
    if format_image_seq(1) == 'r',
        I = readras(ima_name);
    else
        I = double(imread(ima_name));
    end;
end;

[ny,nx,nc] = size(I);


% Pre-compute the necessary indices and blending coefficients to enable quick rectification: 
[Irec_junk,ind_new,ind_1,ind_2,ind_3,ind_4,a1,a2,a3,a4] = rect_index(zeros(ny,nx),eye(3),fc,cc,kc,alpha_c,KK);


n_seq = length(ima_sequence);


for kk = 1:n_seq,
    
    ima_name = ima_sequence(kk).name;
    
            fprintf(1,'Loading original image %s...',ima_name);

    %%% READ IN IMAGE:
    
    if format_image_seq(1) == 'p',
        if format_image_seq(2) == 'p',
            I = double(loadppm(ima_name));
        else
            I = double(loadpgm(ima_name));
        end;
    else
        if format_image_seq(1) == 'r',
            I = readras(ima_name);
        else
            I = double(imread(ima_name));
        end;
    end;
    
    [ny,nx,nc] = size(I);

    if graphout,
        figure(2);
        image(uint8(I));
        drawnow;
    end;
    
    I2 = zeros(ny,nx,nc);
    
    for ii = 1:nc,
        
        Iii = I(:,:,ii);
        I2ii = zeros(ny,nx);

        I2ii(ind_new) = uint8(a1 .* Iii(ind_1) + a2 .* Iii(ind_2) + a3 .* Iii(ind_3) + a4 .* Iii(ind_4));
        
        I2(:,:,ii) = I2ii;
        
    end;
    
    I2 = uint8(I2);
    
    if graphout,
        figure(3);
        image(I2);
        drawnow;
    end;
    
    ima_name2 = ['undist_' ima_name];
    
    fprintf(1,'Saving undistorted image under %s...\n',ima_name2);
    
    if format_image_seq(1) == 'p',
        if format_image_seq(2) == 'p',
            saveppm(ima_name2,I2);
        else
            savepgm(ima_name2,I2);
        end;
    else
        if format_image_seq(1) == 'r',
            writeras(ima_name2,I2,gray(256));
        else
            imwrite(I2,ima_name2,format_image_seq);
        end;
    end;
    
    
end;
