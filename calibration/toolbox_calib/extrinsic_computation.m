%%% INPUT THE IMAGE FILE NAME:

if ~exist('fc')|~exist('cc')|~exist('kc')|~exist('alpha_c'),
   fprintf(1,'No intrinsic camera parameters available.\n');
   return;
end;

dir;

fprintf(1,'\n');
disp('Computation of the extrinsic parameters from an image of a pattern');
disp('The intrinsic camera parameters are assumed to be known (previously computed)');

fprintf(1,'\n');
image_name = input('Image name (full name without extension): ','s');

format_image2 = '0';

while format_image2 == '0',
   
   format_image2 =  input('Image format: ([]=''r''=''ras'', ''b''=''bmp'', ''t''=''tif'', ''p''=''pgm'', ''j''=''jpg'', ''m''=''ppm'') ','s');
	
	if isempty(format_image2),
   	format_image2 = 'ras';
	end;
   
   if lower(format_image2(1)) == 'm',
      format_image2 = 'ppm';
   else
      if lower(format_image2(1)) == 'b',
         format_image2 = 'bmp';
      else
         if lower(format_image2(1)) == 't',
            format_image2 = 'tif';
         else
            if lower(format_image2(1)) == 'p',
               format_image2 = 'pgm';
            else
               if lower(format_image2(1)) == 'j',
                  format_image2 = 'jpg';
               else
                  if lower(format_image2(1)) == 'r',
                     format_image2 = 'ras';
                  else  
                     disp('Invalid image format');
                     format_image2 = '0'; % Ask for format once again
                  end;
               end;
            end;
         end;
      end;
   end;
end;

ima_name = [image_name '.' format_image2];


%%% READ IN IMAGE:

if format_image2(1) == 'p',
   if format_image2(2) == 'p',
      I = double(loadppm(ima_name));
   else
      I = double(loadpgm(ima_name));
   end;
else
   if format_image2(1) == 'r',
      I = readras(ima_name);
   else
      I = double(imread(ima_name));
   end;
end;

if size(I,3)>1,
   I = I(:,:,2);
end;


%%% EXTRACT GRID CORNERS:

fprintf(1,'\nExtraction of the grid corners on the image\n');

disp('Window size for corner finder (wintx and winty):');
wintx = input('wintx ([] = 5) = ');
if isempty(wintx), wintx = 5; end;
wintx = round(wintx);
winty = input('winty ([] = 5) = ');
if isempty(winty), winty = 5; end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);


[x_ext,X_ext,n_sq_x,n_sq_y,ind_orig,ind_x,ind_y] = extract_grid(I,wintx,winty,fc,cc,kc);



%%% Computation of the Extrinsic Parameters attached to the grid:

[omc_ext,Tc_ext,Rc_ext,H_ext] = compute_extrinsic(x_ext,X_ext,fc,cc,kc,alpha_c);


%%% Reproject the points on the image:

[x_reproj] = project_points2(X_ext,omc_ext,Tc_ext,fc,cc,kc,alpha_c);

err_reproj = x_ext - x_reproj;

err_std2 = std(err_reproj')';


Basis = [X_ext(:,[ind_orig ind_x ind_orig ind_y ind_orig ])];

VX = Basis(:,2) - Basis(:,1);
VY = Basis(:,4) - Basis(:,1);

nX = norm(VX);
nY = norm(VY);

VZ = min(nX,nY) * cross(VX/nX,VY/nY);

Basis = [Basis VZ];

[x_basis] = project_points2(Basis,omc_ext,Tc_ext,fc,cc,kc,alpha_c);

dxpos = (x_basis(:,2) + x_basis(:,1))/2;
dypos = (x_basis(:,4) + x_basis(:,3))/2;
dzpos = (x_basis(:,6) + x_basis(:,5))/2;



figure(2);
image(I);
colormap(gray(256));
hold on;
plot(x_ext(1,:)+1,x_ext(2,:)+1,'r+');
plot(x_reproj(1,:)+1,x_reproj(2,:)+1,'yo');
h = text(x_ext(1,ind_orig)-25,x_ext(2,ind_orig)-25,'O');
set(h,'Color','g','FontSize',14);
h2 = text(dxpos(1)+1,dxpos(2)-30,'X');
set(h2,'Color','g','FontSize',14);
h3 = text(dypos(1)-30,dypos(2)+1,'Y');
set(h3,'Color','g','FontSize',14);
h4 = text(dzpos(1)-10,dzpos(2)-20,'Z');
set(h4,'Color','g','FontSize',14);
plot(x_basis(1,:)+1,x_basis(2,:)+1,'g-','linewidth',2);
title('Image points (+) and reprojected grid points (o)');
hold off;


fprintf(1,'\n\nExtrinsic parameters:\n\n');
fprintf(1,'Translation vector: Tc_ext = [ %3.6f \t %3.6f \t %3.6f ]\n',Tc_ext);
fprintf(1,'Rotation vector:   omc_ext = [ %3.6f \t %3.6f \t %3.6f ]\n',omc_ext);
fprintf(1,'Rotation matrix:    Rc_ext = [ %3.6f \t %3.6f \t %3.6f\n',Rc_ext(1,:)');
fprintf(1,'                               %3.6f \t %3.6f \t %3.6f\n',Rc_ext(2,:)');
fprintf(1,'                               %3.6f \t %3.6f \t %3.6f ]\n',Rc_ext(3,:)');
fprintf(1,'Pixel error:           err = [ %3.5f \t %3.5f ]\n\n',err_std2); 





return;


% Stores the results:

kk = 1;

% Stores location of grid wrt camera:

eval(['omc_' num2str(kk) ' = omc_ext;']);
eval(['Tc_' num2str(kk) ' = Tc_ext;']);

% Stores the projected points:
      
eval(['y_' num2str(kk) ' = x_reproj;']);
eval(['X_' num2str(kk) ' = X_ext;']);
eval(['x_' num2str(kk) ' = x_ext;']);      
      
            
% Organize the points in a grid:
      
eval(['n_sq_x_' num2str(kk) ' = n_sq_x;']);
eval(['n_sq_y_' num2str(kk) ' = n_sq_y;']);
   