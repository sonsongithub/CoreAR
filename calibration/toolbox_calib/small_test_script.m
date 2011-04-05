% This is small script that demonstrate the computation of extrinsic 
% parameters using 3D structures.
% This test was build from data provided by Daniel Small (thank you Daniel!)


%-- Image points (in pixels):

x = [479.5200  236.0800
  608.4100  415.3700
  461.0000   40.0000
  451.4800  308.7000
  373.9900  314.8900
  299.3200  319.1300
  231.5500  321.3700
  443.7300  282.9200
  378.3600  288.3000
  314.6900  292.7400
  255.4700  296.2300]';


% 3D world coordinates:

X = [ 0         0         0
   54.0000         0         0
         0         0   40.5000
   27.0000   -8.4685   -2.3750
   27.0000  -18.4685   -2.3750
   27.0000  -28.4685   -2.3750
   27.0000  -38.4685   -2.3750
   17.0000   -8.4685   -2.3750
   17.0000  -18.4685   -2.3750
   17.0000  -28.4685   -2.3750
   17.0000  -38.4685   -2.3750]';


%------------ Intrinsic parameters:
%--- focal:
fc = [ 395.0669  357.1178 ]';
%--- Principal point:
cc = [ 380.5387  230.5278 ]';
%--- Distortion coefficients:
kc = [-0.2601    0.0702   -0.0019   -0.0003         0]';
%--- Skew coefficient:
alpha_c = 0;

%----- Computation of the pose of the object in space
%----- (or the rigid motion between world reference frame and camera ref. frame)
[om,T,R] = compute_extrinsic(x,X,fc,cc,kc,alpha_c);

%--- Try to reproject the structure to see if the computed pose makes sense:
x2 = project_points2(X_1,omckk,Tckk,fc,cc,kc,alpha_c);


% Graphical output:
figure(2);
plot(x(1,:),x(2,:),'r+');
hold on;
plot(x2(1,:),x2(2,:),'go');
hold off;
axis('equal');
axis('image');
title('red crosses: data, green circles: reprojected structure -- IT WORKS!!!');
xlabel('x');
ylabel('y');

