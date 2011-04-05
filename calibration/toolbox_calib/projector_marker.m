   if active_images(i),
   
   	%fprintf(1,'Loading image %d...\n',i);
   
   	if ~type_numbering,   
      	number_ext =  num2str(image_numbers(i));
   	else
      	number_ext = sprintf(['%.' num2str(N_slots) 'd'],image_numbers(i));
   	end;
   	
      ima_namep = [proj_name  number_ext 'p.' format_image];
      ima_namen = [proj_name  number_ext 'n.' format_image];
      ima_namer = [proj_name  number_ext 'r.' format_image];
      ima_nameb = [camera_name  number_ext '.' format_image];
      
      if i == ind_active(1),
         fprintf(1,'Loading image ');
      end;
         
         fprintf(1,'%d...',i);
         
         if format_image(1) == 'p',
            if format_image(2) == 'p',
               Ip = double(loadppm(ima_namep));
               In = double(loadppm(ima_namen));
               Ir = double(loadppm(ima_namer));
               Ib = double(loadppm(ima_nameb));
            else
               Ip = double(loadpgm(ima_namep));
               In = double(loadpgm(ima_namen));
               Ir = double(loadpgm(ima_namer));
               Ib = double(loadpgm(ima_nameb));
            end;
         else
            if format_image(1) == 'r',
               Ip = readras(ima_namep);
               In = readras(ima_namen);
               Ir = readras(ima_namer);
               Ib = readras(ima_nameb);
            else
               Ip = double(imread(ima_namep));
               In = double(imread(ima_namen));
               Ir = double(imread(ima_namer));
               Ib = double(imread(ima_nameb));
            end;
         end;

      	
			if size(Ip,3)>1,
            Ip = 0.299 * Ip(:,:,1) + 0.5870 * Ip(:,:,2) + 0.114 * Ip(:,:,3);
            In = 0.299 * In(:,:,1) + 0.5870 * In(:,:,2) + 0.114 * In(:,:,3);
            Ir = 0.299 * Ir(:,:,1) + 0.5870 * Ir(:,:,2) + 0.114 * Ir(:,:,3);
            Ib = 0.299 * Ib(:,:,1) + 0.5870 * Ib(:,:,2) + 0.114 * Ib(:,:,3);
   		end;
         
         %IIp = Ip - In;
         
         %Ip2 = Ip - Ib;
         %In2 = In - Ib;
         
         %imax = max(IIp(:));
         %imin = min(IIp(:));
         
         %IIp = 255*(IIp - imin)/(imax - imin);
         
         %indplus = find(IIp >= 255/2);
         %indminus = find(IIp < 255/2);
         
         %IIp(indplus) = 255*ones(length(indplus),1);
         %IIp(indminus) = zeros(length(indminus),1);
         
         delta_I = Ip - In;
         
         %IIp = 255*(1 + exp(-delta_I/2)).^(-1);
         
         
         IIp = (Ip >= In)*255;
         
         IIp = conv2(conv2(IIp,[1/4 1/2 1/4],'same'),[1/4 1/2 1/4]','same');
         
         if 0,
         figure(4);
         image(IIp);
         colormap(gray(256));
         axis off;
         end;
     
         
   		eval(['Ip_' num2str(i) ' = IIp;']);
   		eval(['In_' num2str(i) ' = 255 - IIp;']);
         
        
        
        
         I_marker2 = Ib-Ir;
         
         
         if DEBUG,
            
            Imax = max(I_marker2(:));
            Imin = min(I_marker2(:));
            
            I_marker_out = 255*(I_marker2 - Imin)/(Imax - Imin);
            
            figure(3);
            image(I_marker_out);
            colormap(gray(256));
            
            [xr,yr] = ginput(1);
            
            xr_list(i) = xr;
            yr_list(i) = yr;
            
         else
            
            I_marker = I_marker2 >50;
            I_marker = eliminate_boundary(I_marker);
            I_marker = eliminate_boundary(I_marker);
            [ymm,xmm] = find(I_marker);
            
            if length(xmm)<10,
               fprintf(1,'WARNING!! No marker in image %d!!!!\n',i);
            else
               xr = mean(xmm);
               yr = mean(ymm);
               xr_list(i) = xr;
               yr_list(i) = yr;
            end; 
         end;
         
         figure(2);
         image(IIp);
         colormap(gray(256));
         hold on;
         plot(xr,yr,'go');
         hold off;
         title(['Image ' num2str(i)]);
         drawnow;
         
         if ~DEBUG
            waitforbuttonpress;
         end;
         
         
         
   end;
