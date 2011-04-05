

if ~exist('n_ima'),
    data_calib_no_read;
end;


check_active_images;

n_col = floor(sqrt(n_ima*nx/ny));

n_row = ceil(n_ima / n_col);


ker2 = 1;
for ii  = 1:n_col,
   ker2 = conv(ker2,[1/4 1/2 1/4]);
end;

ny2 = length(1:n_col:ny);
nx2 = length(1:n_col:nx);

%II = I_1(1:n_col:end,1:n_col:end);
%[ny2,nx2] = size(II);



kk_c = 1;

II_mosaic = [];

for jj = 1:n_row,
    
    
    II_row = [];
    
    for ii = 1:n_col,
        
        
        if (kk_c <= n_ima),
            
            if ~type_numbering,   
                number_ext =  num2str(image_numbers(kk_c));
            else
                number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(kk_c));
            end;
            
            ima_name = [calib_name  number_ext '.' format_image]; 
            
            
            
            if (exist(ima_name)) & (kk_c <= n_ima),
                
                if active_images(kk_c),
                    
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
                    
                    %I = conv2(conv2(I,ker2,'same'),ker2','same'); % anti-aliasing
                    I = I(1:n_col:end,1:n_col:end);
                else
                    I = zeros(ny2,nx2);
                end;
                
            else
                
                I = zeros(ny2,nx2);
                
            end;
            
        else 
            
            I = zeros(ny2,nx2);
            
        end;
        
        II_row = [II_row I];
        
        if ii ~= n_col,
            
            II_row = [II_row zeros(ny2,3)];
            
        end;
        
        
        kk_c = kk_c + 1;
        
    end;
    
    nn2 = size(II_row,2);
    
    if jj ~= n_row,
        II_row = [II_row; zeros(3,nn2)];
    end;
    
    II_mosaic = [II_mosaic ; II_row];
    
end;

figure(2);
image(II_mosaic);
colormap(gray(256));
title('Calibration images');
set(gca,'Xtick',[])
set(gca,'Ytick',[])
axis('image');

