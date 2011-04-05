function err_total = error_depth_list(param_dist,xcn_list,xpn_list,R,T,X_shape_list,ind_list);


N_view = length(ind_list);

err_total = [];

N_pts = zeros(1,N_view);

for kk = 1:N_view,
   
   xcn = xcn_list{kk};
   xpn = xpn_list{kk};
   ind = ind_list{kk};
   
   xpn = xpn([1 3],:);
   
   X_shape = X_shape_list{kk};
   
   
X_new = depth_compute(xcn,xpn,[param_dist],R,T);


N_pt_calib = size(xcn,2);

% UnNormalized shape extraction:

X_shape2 = X_new;
X_shape2 = X_shape2 - (X_shape2(:,1)*ones(1,N_pt_calib));

% map the second vector at [1;0;0]:

omu = -cross([1;0;0],X_shape2(:,2));
omu = acos((dot([1;0;0],X_shape2(:,2)))/norm(X_shape2(:,2)))*(omu / norm(omu));
Ru = rodrigues(omu);

X_shape2 = Ru* X_shape2;

omu2 = -cross([0;1;0],[0;X_shape2(2:3,ind)]);
omu2 = acos((dot([0;1;0],[0;X_shape2(2:3,ind)]))/norm([0;X_shape2(2:3,ind)]))*(omu2 / norm(omu2));
Ru2 = rodrigues(omu2);

X_shape2 = Ru2* X_shape2;


% Error:

err_shape = X_shape2(:,2:end) - X_shape(:,2:end);

err_shape = err_shape(:);

N_pts(kk) = N_pt_calib;

err_total = [ err_total ; err_shape ];

end;


%err_depth = Z_new - Z_ref;
