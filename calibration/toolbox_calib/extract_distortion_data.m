%%% Small script file that etst 

%load Calib_Results;

% Collect all the points distorted (xd) and undistorted (xn) from the
% images:

xn = [];
xd = [];
for kk = ind_active,
    eval(['x_kk = x_' num2str(kk) ';']);
    xd_kk = normalize_pixel(x_kk,fc,cc,zeros(5,1),alpha_c);
    eval(['X_kk = X_' num2str(kk) ';']);
    eval(['omckk = omc_' num2str(kk) ';']);
    eval(['Tckk = Tc_' num2str(kk) ';']);
    xn_kk = project_points2(X_kk,omckk,Tckk);
    xd = [xd xd_kk];
    xn = [xn xn_kk];
end;


% Data points:
r = sqrt(sum(xn.^2)); % The undistorted radii
rp = sqrt(sum(xd.^2)); % The distorted radii

%--- Try different analytical models to fit r_prime = D(r)

ri = 0.005:.005:max(r);

% Calibration toolbox model:
rt = ri .* (1 + kc(1)*ri.^2 + kc(2)*ri.^4 + kc(5)*ri.^6);



return;


figure(10);
clf;
h1 = plot(r,rp,'r.','markersize',.1); hold on;
h2 = plot(ri,rt,'r-','linewidth',.1);
title('Radial distortion function (with unit focal) - r prime = D(r)');
xlabel('r');
ylabel('r prime');
zoom on;

