function [fc_2,Rc_2,Tc_2,H_2,distance,V_vert,V_hori,x_all_c,V_hori_pix,V_vert_pix,V_diag1_pix,V_diag2_pix]=Distor2Calib(k_dist,grid_pts_centered,n_sq_x,n_sq_y,Np,W,L,Xgrid_2,f_ini,N_iter,two_focal);

% Computes the calibration parameters knowing the
% distortion factor k_dist

% grid_pts_centered are the grid point coordinates after substraction of
% the optical center.

% can give an optional guess for the focal length f_ini (can set to [])
% can provide the number of iterations for the Iterative Vanishing Point Algorithm

% if the focal length is known perfectly, then, there is no need to iterate,
% and therefore, one can fix: N_iter = 0;

% California Institute of Technology
% (c) Jean-Yves Bouguet - October 7th, 1997



%keyboard;

if exist('two_focal'),
   if isempty(two_focal),
      two_focal=0;
   end;
else
   two_focal = 0;
end;


if exist('N_iter'),
   if ~isempty(N_iter),
      disp('Use number of iterations provided');
   else
      N_iter = 10;
   end;
else
   N_iter = 10;
end;

if exist('f_ini'),
   if ~isempty(f_ini),
      disp('Use focal provided');
      if length(f_ini)<2, f_ini=[f_ini;f_ini]; end;
      fc_2 = f_ini;
      x_all_c = [grid_pts_centered(1,:)/fc_2(1);grid_pts_centered(2,:)/fc_2(2)];
      x_all_c = comp_distortion(x_all_c,k_dist); % we can this time!!!
   else
     fc_2 = [1;1];
     x_all_c = grid_pts_centered;
   end;
else
   fc_2 = [1;1];
   x_all_c = grid_pts_centered;
end;


dX = W/n_sq_x;
dY = L/n_sq_y;


N_x = n_sq_x+1;
N_y = n_sq_y+1;


x_grid = zeros(N_x,N_y);
y_grid = zeros(N_x,N_y);





%%% Computation of the four vanishing points in pixels


   x_grid(:) = grid_pts_centered(1,:);
   y_grid(:) = grid_pts_centered(2,:);
         
   for k=1:n_sq_x+1,
      [U,S,V] = svd([x_grid(k,:);y_grid(k,:);ones(1,n_sq_y+1)]);
      vert(:,k) = U(:,3);
   end;
   
   for k=1:n_sq_y+1,
      [U,S,V] = svd([x_grid(:,k)';y_grid(:,k)';ones(1,n_sq_x+1)]);
      hori(:,k) = U(:,3);
   end;
   
   % 2 principle Vanishing points:
   [U,S,V] = svd(vert);
   V_vert = U(:,3);
   [U,S,V] = svd(hori);
   V_hori = U(:,3);
   
   

   % Square warping:
   
   
   vert_first = vert(:,1) - dot(V_vert,vert(:,1))/dot(V_vert,V_vert) * V_vert;
   vert_last = vert(:,n_sq_x+1) - dot(V_vert,vert(:,n_sq_x+1))/dot(V_vert,V_vert) * V_vert;
   
   hori_first = hori(:,1) - dot(V_hori,hori(:,1))/dot(V_hori,V_hori) * V_hori;
   hori_last = hori(:,n_sq_y+1) - dot(V_hori,hori(:,n_sq_y+1))/dot(V_hori,V_hori) * V_hori;
   
   
   x1 = cross(hori_first,vert_first);
   x2 = cross(hori_first,vert_last);
   x3 = cross(hori_last,vert_last);
   x4 = cross(hori_last,vert_first);
   
   x1 = x1/x1(3);
   x2 = x2/x2(3);
   x3 = x3/x3(3);
   x4 = x4/x4(3);
   
   
   
   [square] = Rectangle2Square([x1 x2 x3 x4],W,L);

   y1 = square(:,1);
   y2 = square(:,2);
   y3 = square(:,3);
   y4 = square(:,4);

   H2 = cross(V_vert,V_hori);
   
   V_diag1 = cross(cross(y1,y3),H2);
   V_diag2 = cross(cross(y2,y4),H2);

   V_diag1 = V_diag1 / norm(V_diag1);
   V_diag2 = V_diag2 / norm(V_diag2);

   V_hori_pix = V_hori;
   V_vert_pix = V_vert;
   V_diag1_pix = V_diag1;
   V_diag2_pix = V_diag2;


% end of computation of the vanishing points in pixels.








if two_focal, % only if we attempt to estimate two focals...
   % Use diagonal lines also to add two extra vanishing points (?)
   N_min = min(N_x,N_y);
   
   if N_min < 2,
      use_diag = 0;
      two_focal = 0;
      disp('Cannot estimate two focals (no existing diagonals)');   
   else
      use_diag = 1;
      Delta_N = abs(N_x-N_y);
      N_extra = round((N_min - Delta_N - 1)/2);
      diag_list = -N_extra:Delta_N+N_extra;
      N_diag = length(diag_list);
      diag_1 = zeros(3,N_diag);
      diag_2 = zeros(3,N_diag);
   end;
else   
   % Give up the use of the diagonals (so far)
   % it seems that the error is increased
   use_diag = 0;
end;



% The vertical lines: vert, Horizontal lines: hori
vert = zeros(3,n_sq_x+1);
hori = zeros(3,n_sq_y+1);
 
for counter_k = 1:N_iter, 	% the Iterative Vanishing Points Algorithm to
                                % estimate the focal length accurately
   
   x_grid(:) = x_all_c(1,:);
   y_grid(:) = x_all_c(2,:);
         
   for k=1:n_sq_x+1,
      [U,S,V] = svd([x_grid(k,:);y_grid(k,:);ones(1,n_sq_y+1)]);
      vert(:,k) = U(:,3);
   end;
   
   for k=1:n_sq_y+1,
      [U,S,V] = svd([x_grid(:,k)';y_grid(:,k)';ones(1,n_sq_x+1)]);
      hori(:,k) = U(:,3);
   end;
   
   % 2 principle Vanishing points:
   [U,S,V] = svd(vert);
   V_vert = U(:,3);
   [U,S,V] = svd(hori);
   V_hori = U(:,3);
   
   

   % Square warping:
   
   
   vert_first = vert(:,1) - dot(V_vert,vert(:,1))/dot(V_vert,V_vert) * V_vert;
   vert_last = vert(:,n_sq_x+1) - dot(V_vert,vert(:,n_sq_x+1))/dot(V_vert,V_vert) * V_vert;
   
   hori_first = hori(:,1) - dot(V_hori,hori(:,1))/dot(V_hori,V_hori) * V_hori;
   hori_last = hori(:,n_sq_y+1) - dot(V_hori,hori(:,n_sq_y+1))/dot(V_hori,V_hori) * V_hori;
   
   
   x1 = cross(hori_first,vert_first);
   x2 = cross(hori_first,vert_last);
   x3 = cross(hori_last,vert_last);
   x4 = cross(hori_last,vert_first);
   
   x1 = x1/x1(3);
   x2 = x2/x2(3);
   x3 = x3/x3(3);
   x4 = x4/x4(3);
   
   
   
   [square] = Rectangle2Square([x1 x2 x3 x4],W,L);

   y1 = square(:,1);
   y2 = square(:,2);
   y3 = square(:,3);
   y4 = square(:,4);

   H2 = cross(V_vert,V_hori);
   
   V_diag1 = cross(cross(y1,y3),H2);
   V_diag2 = cross(cross(y2,y4),H2);

   V_diag1 = V_diag1 / norm(V_diag1);
   V_diag2 = V_diag2 / norm(V_diag2);

   
   
   
   % Estimation of the focal length, and normalization:
   
   % Compute the ellipsis of (1/f^2) positions:
   % a * (1/fx)^2 + b * (1/fx)^2 = -c
   
   
   a1 = V_hori(1);
   b1 = V_hori(2);
   c1 = V_hori(3);
   
   a2 = V_vert(1);
   b2 = V_vert(2);
   c2 = V_vert(3);
   
   a3 = V_diag1(1);
   b3 = V_diag1(2);
   c3 = V_diag1(3);
   
   a4 = V_diag2(1);
   b4 = V_diag2(2);
   c4 = V_diag2(3);
   
   
   if two_focal,
      
      
      A = [a1*a2 b1*b2;a3*a4 b3*b4];
      b = -[c1*c2;c3*c4];
      
      f = sqrt(abs(1./(inv(A)*b)));

   else
      
      f = sqrt(abs(-(c1*c2*(a1*a2 + b1*b2) + c3*c4*(a3*a4 + b3*b4))/(c1^2*c2^2 + c3^2*c4^2)));
      
      f = [f;f];
      
   end;
   

   
   % REMARK:
   % if both a and b are small, the calibration is impossible.
   % if one of them is small, only the other focal length is observable
   % if none is small, both focals are observable
   
   
   fc_2 = fc_2 .* f;
   
      
   % DEBUG PART: fix focal to 500...
   %fc_2= [500;500]; disp('Line 293 to be earased in Distor2Calib.m');
   
   
   % end of focal compensation
   
   % normalize by the current focal:
   
   x_all = [grid_pts_centered(1,:)/fc_2(1);grid_pts_centered(2,:)/fc_2(2)];
   
   % Compensate by the distortion factor:
   
   x_all_c = comp_distortion(x_all,k_dist);
   
end;
   
% At that point, we hope that the distortion is gone...

x_grid(:) = x_all_c(1,:);
y_grid(:) = x_all_c(2,:);

for k=1:n_sq_x+1,
   [U,S,V] = svd([x_grid(k,:);y_grid(k,:);ones(1,n_sq_y+1)]);
   vert(:,k) = U(:,3);
end;

for k=1:n_sq_y+1,
   [U,S,V] = svd([x_grid(:,k)';y_grid(:,k)';ones(1,n_sq_x+1)]);
   hori(:,k) = U(:,3);
end;

% Vanishing points:
[U,S,V] = svd(vert);
V_vert = U(:,3);
[U,S,V] = svd(hori);
V_hori = U(:,3);

% Horizon:

H_2 = cross(V_vert,V_hori);
   
%   H_2 = cross(V_vert,V_hori);

% pick a plane in front of the camera (positive depth)
if H_2(3) < 0, H_2 = -H_2; end;


% Rotation matrix:

if V_hori(1) < 0, V_hori = -V_hori; end;

V_hori = V_hori/norm(V_hori);
H_2 = H_2/norm(H_2);

V_hori = V_hori - dot(V_hori,H_2)*H_2;

Rc_2 = [V_hori cross(H_2,V_hori) H_2];

Rc_2 = Rc_2 / det(Rc_2);

%omc_2 = rodrigues(Rc_2);

%Rc_2 = rodrigues(omc_2);

% Find the distance of the plane for translation vector:

xc_2 = [x_all_c;ones(1,Np)];

Zc_2 = 1./sum(xc_2 .* (Rc_2(:,3)*ones(1,Np)));

Xo_2 = [sum(xc_2 .* (Rc_2(:,1)*ones(1,Np))).*Zc_2 ; sum(xc_2 .* (Rc_2(:,2)*ones(1,Np))).*Zc_2];

XXo_2 = Xo_2 - mean(Xo_2')'*ones(1,Np);

distance_x = norm(Xgrid_2(1,:))/norm(XXo_2(1,:));
distance_y = norm(Xgrid_2(2,:))/norm(XXo_2(2,:));


distance = sum(sum(XXo_2(1:2,:).*Xgrid_2(1:2,:)))/sum(sum(XXo_2(1:2,:).^2));

alpha = abs(distance_x - distance_y)/distance;

if (alpha>0.1)&~two_focal,
   disp('Should use two focals in x and y...');
end;

% Deduce the translation vector:

Tc_2 = distance * H_2;





return;

   V_hori_pix/V_hori_pix(3)
   V_vert_pix/V_vert_pix(3)
   V_diag1_pix/V_diag1_pix(3)
   V_diag2_pix/V_diag2_pix(3)
