function [fc,cc,kc,alpha_c,Rc,Tc,omc,nx,ny,x_dist,xd] = willson_convert(Ncx,Nfx,dx,dy,dpx,dpy,Cx,Cy,sx,f,kappa1,Tx,Ty,Tz,Rx,Ry,Rz,p1,p2);

%Conversion from Reg Willson's calibration format to my format

% Conversion:

% Focal length:
fc = [sx/dpx ; 1/dpy]*f;

% Principal point;
cc = [Cx;Cy];

% Skew:
alpha_c = 0;

% Extrinsic parameters:
Rx = rodrigues([Rx;0;0]);
Ry = rodrigues([0;Ry;0]);
Rz = rodrigues([0;0;Rz]);

Rc = Rz * Ry * Rx;

omc = rodrigues(Rc);

Tc = [Tx;Ty;Tz];


% More tricky: Take care of the distorsion:

Nfy = round(Nfx * 3/4);

nx = Nfx;
ny = Nfy;

% Select a set of DISTORTED coordinates uniformely distributed across the image:

[xp_dist,yp_dist] = meshgrid(0:Nfx-1,0:Nfy);

xp_dist = xp_dist(:)';
yp_dist = yp_dist(:)';


% Apply UNDISTORTION according to Willson:

xp_sensor_dist = dpx*(xp_dist - Cx)/sx;
yp_sensor_dist = dpy*(yp_dist - Cy);

dist_fact = 1 + kappa1*(xp_sensor_dist.^2 + yp_sensor_dist.^2);

xp_sensor = xp_sensor_dist .* dist_fact;
yp_sensor = yp_sensor_dist .* dist_fact;

xp = xp_sensor * sx / dpx  + Cx;
yp = yp_sensor / dpy  + Cy;

ind= find((xp > 0) & (xp < Nfx-1) & (yp > 0) & (yp < Nfy-1));

xp = xp(ind);
yp = yp(ind);
xp_dist = xp_dist(ind);
yp_dist = yp_dist(ind);


% Now, find my own set of parameters:

x_dist = [(xp_dist - cc(1))/fc(1);(yp_dist - cc(2))/fc(2)];
x_dist(1,:) = x_dist(1,:) - alpha_c * x_dist(2,:);

x = [(xp - cc(1))/fc(1);(yp - cc(2))/fc(2)];
x(1,:) = x(1,:) - alpha_c * x(2,:);

k = [0;0;0;0;0];

for kk = 1:5,
	
	[xd,dxddk] = apply_distortion(x,k);

	err = x_dist - xd;

	%norm(err)
   
   k_step = inv(dxddk'*dxddk)*(dxddk')*err(:);
   
   k = k + k_step; %inv(dxddk'*dxddk)*(dxddk')*err(:);
   
   %norm(k_step)/norm(k)
   
   if norm(k_step)/norm(k) < 10e-10,
      break;
   end;
   
end;


kc = k;
