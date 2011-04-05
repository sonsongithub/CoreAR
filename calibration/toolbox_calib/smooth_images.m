% Anisotropically diffuse the calibration image
% to enhance the corner detection


fprintf(1,'Anisotropic diffusion of the images for corner enhancement (the images have to be loaded in memory)\n');


ker = [1/4 1/2 1/4];
ker2 = conv2(ker,ker);
ker2 = conv2(ker2,ker);
ker2 = conv2(ker2,ker);



if ~exist(['I_' num2str(ind_active(1))]),
   ima_read_calib;
end;

check_active_images;   

format_image2 = format_image;
if format_image2(1) == 'j',
   format_image2 = 'bmp';
end;

for kk = 1:n_ima,
   
   if exist(['I_' num2str(kk)]),
      
      %fprintf(1,'%d...',kk);
      
      eval(['I = I_' num2str(kk) ';']);
      
      
      % Compute the sigI automatically:
      [nn,xx] = hist(I(:),50);
      nn = conv2(nn,ker2,'same');
      
      max_nn = max(nn);
      
      
      localmax = [0 (nn(2:end-1)>=nn(3:end)) & (nn(2:end-1) > nn(1:end-2)) 0] .* (nn >= max_nn/5);
      
      %plot(xx,nn);
      %hold on;
      %plot(xx,nn .* localmax,'r' );
      %hold off;
     
      localmax_ind = find(localmax);
      nn_local_max = nn(localmax_ind);
      
      % order the picks:
      [a,b] = sort(-nn_local_max);
      
      localmax_ind = localmax_ind(b);
      nn_local_max = nn_local_max(b);
      
      sig_I = abs(xx(localmax_ind(1)) - xx(localmax_ind(2)))/4.25;
      
      
      
      
      I2 = anisdiff(I,sig_I,30);
      
      
   	if ~type_numbering,   
      	number_ext =  num2str(image_numbers(kk));
   	else
      	number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(kk));
   	end;
   	
      ima_name2 = [calib_name '_smth' number_ext '.' format_image2];
      
      fprintf(1,['Saving smoothed image under ' ima_name2 '...\n']);

      if format_image2(1) == 'p',
         if format_images2(2) == 'p',
            saveppm(ima_name2,uint8(round(I2)));
         else
            savepgm(ima_name2,uint8(round(I2)));
         end;
      else
         if format_image2(1) == 'r',
            writeras(ima_name2,round(I2),gray(256));
         else
            imwrite(uint8(round(I2)),gray(256),ima_name2,format_image2);
         end;
      end;
      
   end;
   
end;

fprintf(1,'\ndone\n');