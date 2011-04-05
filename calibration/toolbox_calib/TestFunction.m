function [cdist, dcdistdom, dcdistdT, r, drdom, drdT] = TestFunction(X,om,T,k);

[m,n] = size(X);

[Y,dYdom,dYdT] = rigid_motion(X,om,T);


inv_Z = 1./Y(3,:);

x = (Y(1:2,:) .* (ones(2,1) * inv_Z)) ;


bb = (-x(1,:) .* inv_Z)'*ones(1,3);
cc = (-x(2,:) .* inv_Z)'*ones(1,3);


dxdom = zeros(2*n,3);
dxdom(1:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdom(1:3:end,:) + bb .* dYdom(3:3:end,:);
dxdom(2:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdom(2:3:end,:) + cc .* dYdom(3:3:end,:);

dxdT = zeros(2*n,3);
dxdT(1:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdT(1:3:end,:) + bb .* dYdT(3:3:end,:);
dxdT(2:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdT(2:3:end,:) + cc .* dYdT(3:3:end,:);


% Add fisheye distortion:

r2 = x(1,:).^2 + x(2,:).^2;

dr2dom = 2*((x(1,:)')*ones(1,3)) .* dxdom(1:2:end,:) + 2*((x(2,:)')*ones(1,3)) .* dxdom(2:2:end,:);
dr2dT = 2*((x(1,:)')*ones(1,3)) .* dxdT(1:2:end,:) + 2*((x(2,:)')*ones(1,3)) .* dxdT(2:2:end,:);


% Radial distance:
r = sqrt(r2);
drdr2 = 1 ./ (2*r);

drdom = [ (drdr2').*dr2dom(:,1)   (drdr2').*dr2dom(:,2)  (drdr2').*dr2dom(:,3)  ];
drdT = [ (drdr2').*dr2dT(:,1)   (drdr2').*dr2dT(:,2)  (drdr2').*dr2dT(:,3)  ];

% Angle of the incoming ray:
theta = atan(r);
dthetadr = 1 ./ (1 + r2);

dthetadom = [ (dthetadr').*drdom(:,1)   (dthetadr').*drdom(:,2)  (dthetadr').*drdom(:,3)  ];
dthetadT = [ (dthetadr').*drdT(:,1)   (dthetadr').*drdT(:,2)  (dthetadr').*drdT(:,3)  ];



% Add the distortion:

theta2 = theta.^2;
theta3 = theta.^3;
theta4 = theta.^4;
theta5 = theta.^5;
theta6 = theta.^6;

theta_d = theta + k(1)*theta2 + k(2)*theta3 + k(3)*theta4 + k(4)*theta5 + k(5)*theta6;

dtheta_ddtheta = 1 + 2*k(1)*theta + 3*k(2)*theta2 + 4*k(3)*theta3 + 5*k(4)*theta4 + 6*k(5)*theta5;

dtheta_ddom = [ (dtheta_ddtheta').*dthetadom(:,1)   (dtheta_ddtheta').*dthetadom(:,2)  (dtheta_ddtheta').*dthetadom(:,3)  ];
dtheta_ddT = [ (dtheta_ddtheta').*dthetadT(:,1)   (dtheta_ddtheta').*dthetadT(:,2)  (dtheta_ddtheta').*dthetadT(:,3)  ];
dtheta_ddk = [theta2' theta3' theta4' theta5' theta6'];


r_d = tan(theta_d);
dr_ddtheta_d = 1 ./ ((cos(theta_d)).^2);

dr_ddom = [ (dr_ddtheta_d').*dtheta_ddom(:,1) (dr_ddtheta_d').*dtheta_ddom(:,2) (dr_ddtheta_d').*dtheta_ddom(:,3) ];
dr_ddT = [ (dr_ddtheta_d').*dtheta_ddT(:,1) (dr_ddtheta_d').*dtheta_ddT(:,2) (dr_ddtheta_d').*dtheta_ddT(:,3) ];



%cdist = r_d;
%dcdistdom = dr_ddom;
%dcdistdT = dr_ddT;

%return;

% ratio:
inv_r = 1./r;
cdist = r_d ./ r;
dcdistdom = [ ((inv_r').*(dr_ddom(:,1) - (cdist').*drdom(:,1)))  ((inv_r').*(dr_ddom(:,2) - (cdist').*drdom(:,2)))   ((inv_r').*(dr_ddom(:,3) - (cdist').*drdom(:,3))) ];
dcdistdT = [ ((inv_r').*(dr_ddT(:,1) - (cdist').*drdT(:,1)))  ((inv_r').*(dr_ddT(:,2) - (cdist').*drdT(:,2)))   ((inv_r').*(dr_ddT(:,3) - (cdist').*drdT(:,3))) ];






return;

% Test of the Jacobians:

n = 10;

X = 10*randn(3,n);
om = randn(3,1);
T = [10*randn(2,1);40];
k = 0.5*randn(5,1);

[theta,dthetadom,dthetadT,r,drdom,drdT] = TestFunction(X,om,T,k);


% Test on om:
dom = 0.00000000001 * norm(om)*randn(3,1);
om2 = om + dom;

[theta2] = TestFunction(X,om2,T,k);
theta_pred = theta + reshape(dthetadom*dom,1,n);
norm(theta2 - theta)/norm(theta2 - theta_pred)


% Test on T:
dT = 0.0000001 * norm(T)*randn(3,1);
T2 = T + dT;

[theta2] = TestFunction(X,om,T2,k);
theta_pred = theta + reshape(dthetadT*dT,1,n);
norm(theta2 - theta)/norm(theta2 - theta_pred)

