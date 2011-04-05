%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-- Main 3D Scanning Script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if exist('calib_cam_proj_optim.mat')~=2,
    error('The scanner calibration file does not exist. Make sure to go to the directory where the scanning images and the calibration file are located (folder scanning_example)');
end;

% Loading the scanner calibration parameters:
fprintf(1,'Loading the scanner calibration data...\n');
load calib_cam_proj_optim;


% Choose a dataset (scan #20 for example)
ind_view = 20;
stripe_image = ['strip' sprintf('%.4d',ind_view) ];

if exist([stripe_image '_pat00p.bmp'])~=2,
    error('The scanning images cannot be found. Make sure to go to the directory where the scanning images are located (folder scanning_example)');
end;


% Compute the projector coordinates at every pixel in the camera image:
fprintf(1,'Computing the subpixel projector coordinates at every pixel in the camera image...\n');
[xc,xp,nx,ny] = ComputeStripes(stripe_image,1);


% Triangulate the 3D geometry:
fprintf(1,'Triangulating the 3D geometry...\n');
[Xc,Xp] = Compute3D(xc,xp,R,T,fc,fp,cc,cp,kc,kp,alpha_c,alpha_p);


% Meshing the points:
Thresh_connect = 15;
N_smoothing = 1;
fprintf(1,'Computing the 3D surface mesh...\n');
[Xc2,tri2,xc2,xp2,dc2,xc_texture,nc2,conf_nc2,Nn2] = Meshing(Xc,xc,xp,Thresh_connect,N_smoothing,om,T,nx,ny,fc,cc,kc,alpha_c,fp,cp,kp,alpha_p);


% Display the 3D mesh:
figure(7);
h = trimesh(tri2,Xc2(1,:),Xc2(3,:),-Xc2(2,:));
set(h,'EdgeColor', 'b');
xlabel('X');
ylabel('Y');
zlabel('Z');
axis('equal');
rotate3d on;
view(0.5,12);
axis equal



% Save the mesh in a VRML file:
TT = [0;0;0];
wwn = [1;0;0];
nw = pi;
fieldOfView = 3*atan((ny/2)/fc(2));

filename_VRML = ['mesh' sprintf('%.4d',ind_view) '.wrl'];

fprintf(1,'Saving Geometry in the VRML file %s...(use Cosmo Player to visualize the mesh)\n',filename_VRML);

file = fopen(filename_VRML,'wt');
fprintf(file ,'#VRML V2.0 utf8\n');
fprintf(file,'Transform { children [ Viewpoint {position %.4f %.4f %.4f orientation  %.4f %.4f %.4f %.4f fieldOfView %.4f } \n',[TT ; wwn ; nw;  fieldOfView]);
%fprintf(file,'Transform { children [ Viewpoint {position %.4f %.4f %.4f orientation  %.4f %.4f %.4f %.4f fieldOfView %.4f } \n',[TT ; wwn ; 0;  atan((ny/2)/fc(2))]);
fprintf(file ,'Transform { children [ Shape { appearance   Appearance {  material Material { }} geometry IndexedFaceSet { coord  Coordinate { point  [\n');
fprintf(file,'%.3f %.3f %.3f,\n',Xc2);
fprintf(file ,']} coordIndex [\n');
fprintf(file,'%d,%d,%d,-1,\n',tri2'-1);
fprintf(file ,']}}]}\n');
fprintf(file,']} ');
fclose(file) ;
