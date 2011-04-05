function err_shape = error_depth(param_dist,xcn,xpn,R,T,X_shape,ind);



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



%err_depth = Z_new - Z_ref;
