function e_global = error_cam_proj(param);

global n_ima x_1 X_1 xproj_1 x_proj_1 x_2 X_2 xproj_2 x_proj_2 x_3 X_3 xproj_3 x_proj_3 x_4 X_4 xproj_4 x_proj_4 x_5 X_5 xproj_5 x_proj_5 x_6 X_6 xproj_6 x_proj_6 x_7 X_7 xproj_7 x_proj_7 x_8 X_8 xproj_8 x_proj_8 x_9 X_9 xproj_9 x_proj_9 x_10 X_10 xproj_10 x_proj_10 x_11 X_11 xproj_11 x_proj_11 x_12 X_12 xproj_12 x_proj_12 x_13 X_13 xproj_13 x_proj_13 x_14 X_14 xproj_14 x_proj_14 x_15 X_15 xproj_15 x_proj_15 x_16 X_16 xproj_16 x_proj_16  x_17 X_17 xproj_17 x_proj_17 x_18 X_18 xproj_18 x_proj_18 x_19 X_19 xproj_19 x_proj_19 x_20 X_20 xproj_20 x_proj_20 x_21 X_21 xproj_21 x_proj_21 x_22 X_22 xproj_22 x_proj_22 x_23 X_23 xproj_23 x_proj_23 x_24 X_24 xproj_24 x_proj_24 x_25 X_25 xproj_25 x_proj_25 x_26 X_26 xproj_26 x_proj_26  x_27 X_27 xproj_27 x_proj_27 x_28 X_28 xproj_28 x_proj_28 x_29 X_29 xproj_29 x_proj_29 x_30 X_30 xproj_30 x_proj_30 

% Computation of the errors:

fc = param(1:2);
cc = param(3:4);
alpha_c = param(5);
kc = param(6:10);

e_cam = [];

for kk = 1:n_ima,
   omckk = param(11+(kk-1)*6:11+(kk-1)*6+2);
   Tckk = param(11+(kk-1)*6+3:11+(kk-1)*6+3+2);
   
   eval(['Xkk = X_' num2str(kk) ';']);
   eval(['xkk = x_' num2str(kk) ';']);
   
   ekk = xkk - project_points2(Xkk,omckk,Tckk,fc,cc,kc,alpha_c);
   
   Rckk = rodrigues(omckk);
   eval(['omc_' num2str(kk) '= omckk;']);
   eval(['Tc_' num2str(kk) '= Tckk;']);
   eval(['Rc_' num2str(kk) '= Rckk;']);
   
   e_cam = [e_cam ekk];
   
end;

X_proj = [];
x_proj = [];

for kk = 1:n_ima,
   eval(['xproj = xproj_' num2str(kk) ';']);
   xprojn = normalize_pixel(xproj,fc,cc,kc,alpha_c);
   eval(['Rc = Rc_' num2str(kk) ';']);
   eval(['Tc = Tc_' num2str(kk) ';']);   
   Np_proj = size(xproj,2);
	Zc = ((Rc(:,3)'*Tc) * (1./(Rc(:,3)' * [xprojn; ones(1,Np_proj)])));
	Xcp = (ones(3,1)*Zc) .* [xprojn; ones(1,Np_proj)]; % % in the camera frame
   eval(['X_proj_' num2str(kk) ' = Xcp;']); % coordinates of the points in the 
   eval(['X_proj = [X_proj X_proj_' num2str(kk) '];']);
   eval(['x_proj = [x_proj x_proj_' num2str(kk) '];']);
end;

fp = param((1:2)+n_ima * 6 + 10);
cp = param((3:4)+n_ima * 6 + 10);
alpha_p = param((5)+n_ima * 6 + 10);
kp = param((6:10)+n_ima * 6 + 10);

om = param(10+n_ima*6+10+1:10+n_ima*6+10+1+2);
T = param(10+n_ima*6+10+1+2+1:10+n_ima*6+10+1+2+1+2);


e_proj = x_proj - project_points2(X_proj,om,T,fp,cp,kp,alpha_p);


e_global = [e_cam e_proj];

