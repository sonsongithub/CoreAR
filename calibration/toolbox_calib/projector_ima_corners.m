
   eval(['Ip = Ip_' num2str(kk) ';']);
   eval(['In = In_' num2str(kk) ';']);
   
   xr = xr_list(kk);
   yr = yr_list(kk);
   
   fprintf(1,'Processing image %d...',kk);
   
   if ~recompute_corner,
		[x,X,n_sq_x,n_sq_y,ind_orig,ind_x,ind_y] = extract_grid(Ip,wintx,winty,fc_save,cc_save,kc_save,dX,dY,xr,yr,1);
   	xproj = x;
   else
      eval(['xproj = xproj_' num2str(kk) ';']);
      x = cornerfinder(xproj+1,Ip,winty,wintx);
      xproj = x - 1;
   end;
   
   Np_proj = size(x,2);
   
	figure(2);
	image(Ip);
	hold on;
	plot(xproj(1,:)+1,xproj(2,:)+1,'r+');
	%title('Click on your reference point');
	xlabel('Xc (in camera frame)');
	ylabel('Yc (in camera frame)');
	hold off;
	
	%disp('Click on your reference point...');
	
   %[xr,yr] = ginput2(1);
   
   xr = xr_list(kk);
   yr = yr_list(kk);
   
	err = sqrt(sum((xproj - [xr;yr]*ones(1,Np_proj)).^2));
	ind_ref = find(err == min(err));
	
	ref_pt = xproj(:,ind_ref);
	
	figure(2);
	hold on;
   plot(ref_pt(1)+1,ref_pt(2)+1,'go'); hold off;
   title(['Image ' num2str(kk)]);
   drawnow;
   
   
   if ~recompute_corner,
      
   	off_x = mod(ind_ref-1,n_sq_x+1);
   	off_y = n_sq_y - floor((ind_ref-1)/(n_sq_x+1));
   	
   	x_proj = X(1:2,:) + ([dXoff - dX * off_x ; dYoff - dY * off_y]*ones(1,Np_proj));
   	
   	eval(['x_proj_' num2str(kk) ' = x_proj;']); % coordinates of the points in the projector image
   	
	end;

   eval(['xproj_' num2str(kk) ' = xproj;']); % coordinates of the points in the camera image

