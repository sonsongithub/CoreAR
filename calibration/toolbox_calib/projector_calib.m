
% load camera results (for setting active images, n_ima,...)
load camera_results;


% Projection settings:

wintx = 12; %8;
winty = 12; %8;
nx = 1024;
ny = 768;
dX = 32;
dY = 32;
dXoff=511.5;
dYoff=383.5;


proj_name = 'proj'; %input('Basename projector calibration images (without number nor suffix): ','s');
camera_name = 'cam';


xr_list = NaN*ones(1,n_ima);
yr_list = NaN*ones(1,n_ima);


ind_proc = ind_active;



DEBUG = 1;
%ind_ima_proj = [18];

for i = ind_proc,
      
   projector_marker; 
   
end;


fprintf(1,'\nExtraction of the grid corners on the image\n');



recompute_corner = 0;

if recompute_corner & ~exist(['xproj_' num2str(ind_proc(1))]),
   if exist('projector_data'),
      load projector_data;
   else
      recompute_corner = 0;
      disp('WARNING: Cannot recompute corners. Data need to be extracted at least once');
   end;   
end;

if ~recompute_corner,
   disp('Manual extraction mode');
else
   disp('Automatic recomputation of the corners');
end;

% extract the projector corners:


for kk = ind_proc,
   
   projector_ima_corners   
   
end;


string_save = 'save projector_data ';

for kk = ind_active,
   string_save = [string_save ' xproj_' num2str(kk) ' x_proj_' num2str(kk)];
end;
eval(string_save);




return;


i = 18;

figure(4)
image(I_29);
colormap(gray(256));
hold on;
plot(x_29(1,:)+1,x_29(2,:)+1,'r+','markersize',13,'linewidth',3)
hold off;
axis image
axis off;
