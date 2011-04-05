function [omckk,Tckk,Rckk] = compute_extrinsic_init_fisheye(x_kk,X_kk,fc,cc,kc,alpha_c)

%compute_extrinsic
%
%[omckk,Tckk,Rckk] = compute_extrinsic_init_fisheye(x_kk,X_kk,fc,cc,kc,alpha_c)
%
%Computes the extrinsic parameters attached to a 3D structure X_kk given its projection
%on the image plane x_kk and the intrinsic camera parameters fc, cc and kc.
%Works with planar and non-planar structures.
%
%INPUT: x_kk: Feature locations on the images
%       X_kk: Corresponding grid coordinates
%       fc: Camera focal length
%       cc: Principal point coordinates
%       kc: Distortion coefficients
%       alpha_c: Skew coefficient
%
%OUTPUT: omckk: 3D rotation vector attached to the grid positions in space
%        Tckk: 3D translation vector attached to the grid positions in space
%        Rckk: 3D rotation matrices corresponding to the omc vectors
%
%Method: Computes the normalized point coordinates, then computes the 3D pose
%
%Important functions called within that program:
%
%normalize_pixel: Computes the normalize image point coordinates.
%
%pose3D: Computes the 3D pose of the structure given the normalized image projection.
%
%project_points.m: Computes the 2D image projections of a set of 3D points



if nargin < 6,
   alpha_c = 0;
	if nargin < 5,
   	kc = zeros(5,1);
   	if nargin < 4,
      	cc = zeros(2,1);
      	if nargin < 3,
         	fc = ones(2,1);
         	if nargin < 2,
            	error('Need 2D projections and 3D points (in compute_extrinsic.m)');
            	return;
         	end;
      	end;
   	end;
	end;
end;


%keyboard;

% Compute the normalized coordinates:

xn = normalize_pixel_fisheye(x_kk,fc,cc,kc,alpha_c);



Np = size(xn,2);

%% Check for planarity of the structure:
%keyboard;

X_mean = mean(X_kk')';

Y = X_kk - (X_mean*ones(1,Np));

YY = Y*Y';

[U,S,V] = svd(YY);

r = S(3,3)/S(2,2);

%keyboard;


if (r < 1e-3)|(Np < 5), %1e-3, %1e-4, %norm(X_kk(3,:)) < eps, % Test of planarity
   
   %fprintf(1,'Planar structure detected: r=%f\n',r);

   % Transform the plane to bring it in the Z=0 plane:
   
   R_transform = V';
   
   %norm(R_transform(1:2,3))
   
   if norm(R_transform(1:2,3)) < 1e-6,
      R_transform = eye(3);
   end;
   
   if det(R_transform) < 0, R_transform = -R_transform; end;
   
	T_transform = -(R_transform)*X_mean;

	X_new = R_transform*X_kk + T_transform*ones(1,Np);
   
   
   % Compute the planar homography:
   
   H = compute_homography(xn,X_new(1:2,:));
   
   % De-embed the motion parameters from the homography:
   
   sc = mean([norm(H(:,1));norm(H(:,2))]);
   
   H = H/sc;
   
   % Extra normalization for some reasons...
   %H(:,1) = H(:,1)/norm(H(:,1));
   %H(:,2) = H(:,2)/norm(H(:,2));
   
   if 0, %%% Some tests for myself... the opposite sign solution leads to negative depth!!!
       
       % Case#1: no opposite sign:
       
       omckk1 = rodrigues([H(:,1:2) cross(H(:,1),H(:,2))]);
       Rckk1 = rodrigues(omckk1);
       Tckk1 = H(:,3);
       
       Hs1 = [Rckk1(:,1:2) Tckk1];
       xn1 = Hs1*[X_new(1:2,:);ones(1,Np)];
       xn1 = [xn1(1,:)./xn1(3,:) ; xn1(2,:)./xn1(3,:)];
       e1 = xn1 - xn;
       
       % Case#2: opposite sign:
       
       omckk2 = rodrigues([-H(:,1:2) cross(H(:,1),H(:,2))]);
       Rckk2 = rodrigues(omckk2);
       Tckk2 = -H(:,3);
       
       Hs2 = [Rckk2(:,1:2) Tckk2];
       xn2 = Hs2*[X_new(1:2,:);ones(1,Np)];
       xn2 = [xn2(1,:)./xn2(3,:) ; xn2(2,:)./xn2(3,:)];
       e2 = xn2 - xn;
       
       if 1, %norm(e1) < norm(e2),
           omckk = omckk1;
           Tckk = Tckk1;
           Rckk = Rckk1;
       else
           omckk = omckk2;
           Tckk = Tckk2;
           Rckk = Rckk2;
       end;
       
   else
       
       u1 = H(:,1);
       u1 = u1 / norm(u1);
       u2 = H(:,2) - dot(u1,H(:,2)) * u1;
       u2 = u2 / norm(u2);
       u3 = cross(u1,u2);
       RRR = [u1 u2 u3];
       omckk = rodrigues(RRR);

       %omckk = rodrigues([H(:,1:2) cross(H(:,1),H(:,2))]);
       Rckk = rodrigues(omckk);
       Tckk = H(:,3);
       
   end;
   
      
   
   %If Xc = Rckk * X_new + Tckk, then Xc = Rckk * R_transform * X_kk + Tckk + T_transform
   
   Tckk = Tckk + Rckk* T_transform;
   Rckk = Rckk * R_transform;

   omckk = rodrigues(Rckk);
   Rckk = rodrigues(omckk);
   
   
else
   
   %fprintf(1,'Non planar structure detected: r=%f\n',r);

   % Computes an initial guess for extrinsic parameters (works for general 3d structure, not planar!!!):
   % The DLT method is applied here!!
   
   J = zeros(2*Np,12);
	
	xX = (ones(3,1)*xn(1,:)).*X_kk;
	yX = (ones(3,1)*xn(2,:)).*X_kk;
	
	J(1:2:end,[1 4 7]) = -X_kk';
	J(2:2:end,[2 5 8]) = X_kk';
	J(1:2:end,[3 6 9]) = xX';
	J(2:2:end,[3 6 9]) = -yX';
	J(1:2:end,12) = xn(1,:)';
	J(2:2:end,12) = -xn(2,:)';
	J(1:2:end,10) = -ones(Np,1);
	J(2:2:end,11) = ones(Np,1);
	
	JJ = J'*J;
	[U,S,V] = svd(JJ);
   
   RR = reshape(V(1:9,12),3,3);
   
   if det(RR) < 0,
      V(:,12) = -V(:,12);
      RR = -RR;
   end;
   
   [Ur,Sr,Vr] = svd(RR);
   
   Rckk = Ur*Vr';
   
   sc = norm(V(1:9,12)) / norm(Rckk(:));
   Tckk = V(10:12,12)/sc;
   
	omckk = rodrigues(Rckk);
   Rckk = rodrigues(omckk);
   
end;
