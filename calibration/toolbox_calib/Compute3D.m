function [Xc,Xp] = Compute3D(xc,xp,R,T,fc,fp,cc,cp,kc,kp,alpha_c,alpha_p);

% [Xc,Xp] = Compute3D(xc,xp,R,T,fc,fp,cc,cp,kc,kp,alpha_c,alpha_p);
%
% Reconstruction of the 3D structure of the striped object.
%
% Xc    : The 3D coordinates of the points in the camera reference frame
% Xp    : The 3D coordinates of the points in the projector reference frame
%
% xc, xp: Camera coordinates and projector coordinates from ComputeStripes
% R,T   : rigid motion from camera to projector: Xp = R*Xc + T
% fc,fp : Camera and Projector focal lengths
% cc,cp : Camera and Projector center of projection
% kc,kp : Camera and Projector distortion factors
% alpha_c, alpha_p: skew coefficients for camera and projector
%
% The set R,T,fc,fp,cc,cp and kc comes from the calibration.
 
% Intel Corporation - Dec. 2003
% (c) Jean-Yves Bouguet


if nargin < 12,
   alpha_p = 0;
   if nargin < 11,
      alpha_c = 0;
   end;
end;


Np = size(xc,2);


xc = normalize_pixel(xc,fc,cc,kc,alpha_c);

xp = (xp - cp(1))/fp(1);

xp_save = xp; % save the real distorted x - coordinates + alpha'ed


if (norm(kp) == 0)&(alpha_p == 0),
   N_rep = 1;
else
   N_rep = 5;
end;


% xp is the first entry of the undistorted projector coordinates (iteratively refined)
% xc is the complete undistorted camera coordinates
for kk = 1:N_rep,

	R2 = R([1 3],:);
	if length(T) > 2,
   	Tp = T([1 3]); % The old technique for calibration
	else
   	Tp = T; % The new technique for calibration (using stripes only)
	end;
	
	% Triangulation:
	
	D1 = [-xc(1,:);xc(1,:).*xp(1,:);-xc(2,:);xc(2,:).*xp(1,:);-ones(1,Np);xp(1,:)];
	D2 = R2(:)*ones(1,Np);
	
	D = sum(D1.*D2);
	N1 = [-ones(1,Np);xp(1,:)];
	N2 = -sum(N1.*(Tp*ones(1,Np)));
	Z = N2./D;
	Xc = (ones(3,1)*Z).*[xc;ones(1,Np)];
	
   % reproject on the projetor view, and apply distortion...
   
   Xp = R*Xc + T*ones(1,Np);
   
   xp_v = [Xp(1,:)./Xp(3,:); Xp(2,:)./Xp(3,:)];
   
   xp_v(1,:) = xp_v(1,:) + alpha_p * xp_v(2,:);
   
   xp_dist = apply_distortion(xp_v,kp);
   
   %norm(xp_dist(1,:) - xp_save)
   
   xp_dist(1,:) = xp_save;
   
   xp_v = comp_distortion(xp_dist,kp);
   
   xp_v(1,:) = xp_v(1,:) - alpha_p * xp_v(2,:);
   
   xp = xp_v(1,:);
   
end;
