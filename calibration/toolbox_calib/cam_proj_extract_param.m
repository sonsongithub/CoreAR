
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
R = rodrigues(om);

e_proj = x_proj - project_points2(X_proj,om,T,fp,cp,kp,alpha_p);

e_global = [e_cam e_proj];

