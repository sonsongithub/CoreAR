function [xp,dxpdom,dxpdT,dxpdf,dxpdc,dxpdk,dxpdalpha] = project_points_fisheye(X,om,T,f,c,k,alpha)

%project_points2.m
%
%[xp,dxpdom,dxpdT,dxpdf,dxpdc,dxpdk] = project_points_fisheye(X,om,T,f,c,k,alpha)
%
%Projects a 3D structure onto the image plane of a fisheye camera.
%
%INPUT: X: 3D structure in the world coordinate frame (3xN matrix for N points)
%       (om,T): Rigid motion parameters between world coordinate frame and camera reference frame
%               om: rotation vector (3x1 vector); T: translation vector (3x1 vector)
%       f: camera focal length in units of horizontal and vertical pixel units (2x1 vector)
%       c: principal point location in pixel units (2x1 vector)
%       k: Distortion fisheye coefficients (5x1 vector)
%       alpha: Skew coefficient between x and y pixel (alpha = 0 <=> square pixels)
%
%OUTPUT: xp: Projected pixel coordinates (2xN matrix for N points)
%        dxpdom: Derivative of xp with respect to om ((2N)x3 matrix)
%        dxpdT: Derivative of xp with respect to T ((2N)x3 matrix)
%        dxpdf: Derivative of xp with respect to f ((2N)x2 matrix if f is 2x1, or (2N)x1 matrix is f is a scalar)
%        dxpdc: Derivative of xp with respect to c ((2N)x2 matrix)
%        dxpdk: Derivative of xp with respect to k ((2N)x5 matrix)
%
%Definitions:
%Let P be a point in 3D of coordinates X in the world reference frame (stored in the matrix X)
%The coordinate vector of P in the camera reference frame is: Xc = R*X + T
%where R is the rotation matrix corresponding to the rotation vector om: R = rodrigues(om);
%call x, y and z the 3 coordinates of Xc: x = Xc(1); y = Xc(2); z = Xc(3);
%The pinehole projection coordinates of P is [a;b] where a=x/z and b=y/z.
%call r^2 = a^2 + b^2,
%call theta = atan(r),
%Fisheye distortion -> theta_d = theta * (1 + k(1)*theta^2 + k(2)*theta^4 + k(3)*theta^6 + k(4)*theta^8)
%
%The distorted point coordinates are: xd = [xx;yy] where:
%
%xx = (theta_d / r) * x
%yy = (theta_d / r) * y
%
%Finally, convertion into pixel coordinates: The final pixel coordinates vector xp=[xxp;yyp] where:
%
%xxp = f(1)*(xx + alpha*yy) + c(1)
%yyp = f(2)*yy + c(2)
%
%
%NOTE: About 90 percent of the code takes care fo computing the Jacobian matrices
%
%
%Important function called within that program:
%
%rodrigues.m: Computes the rotation matrix corresponding to a rotation vector
%
%rigid_motion.m: Computes the rigid motion transformation of a given structure


if nargin < 7,
    alpha = 0;
    if nargin < 6,
        k = zeros(4,1);
        if nargin < 5,
            c = zeros(2,1);
            if nargin < 4,
                f = ones(2,1);
                if nargin < 3,
                    T = zeros(3,1);
                    if nargin < 2,
                        om = zeros(3,1);
                        if nargin < 1,
                            error('Need at least a 3D structure to project (in project_points.m)');
                            return;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;

[m,n] = size(X);

if nargout > 1,
    [Y,dYdom,dYdT] = rigid_motion(X,om,T);
else
    Y = rigid_motion(X,om,T);
end;

inv_Z = 1./Y(3,:);

x = (Y(1:2,:) .* (ones(2,1) * inv_Z)) ;

bb = (-x(1,:) .* inv_Z)'*ones(1,3);
cc = (-x(2,:) .* inv_Z)'*ones(1,3);

if nargout > 1,
    dxdom = zeros(2*n,3);
    dxdom(1:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdom(1:3:end,:) + bb .* dYdom(3:3:end,:);
    dxdom(2:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdom(2:3:end,:) + cc .* dYdom(3:3:end,:);

    dxdT = zeros(2*n,3);
    dxdT(1:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdT(1:3:end,:) + bb .* dYdT(3:3:end,:);
    dxdT(2:2:end,:) = ((inv_Z')*ones(1,3)) .* dYdT(2:3:end,:) + cc .* dYdT(3:3:end,:);
end;

% Add fisheye distortion:

r2 = x(1,:).^2 + x(2,:).^2;

if nargout > 1,
    dr2dom = 2*((x(1,:)')*ones(1,3)) .* dxdom(1:2:end,:) + 2*((x(2,:)')*ones(1,3)) .* dxdom(2:2:end,:);
    dr2dT = 2*((x(1,:)')*ones(1,3)) .* dxdT(1:2:end,:) + 2*((x(2,:)')*ones(1,3)) .* dxdT(2:2:end,:);
end;

% Radial distance:
r = sqrt(r2);
if nargout > 1,
    drdr2 = ones(1,length(r));
    drdr2(r>1e-8) = 1 ./ (2*r(r>1e-8));

    drdom = [ (drdr2').*dr2dom(:,1)   (drdr2').*dr2dom(:,2)  (drdr2').*dr2dom(:,3)  ];
    drdT = [ (drdr2').*dr2dT(:,1)   (drdr2').*dr2dT(:,2)  (drdr2').*dr2dT(:,3)  ];
end;

% Angle of the incoming ray:
theta = atan(r);
if nargout > 1,
    dthetadr = 1 ./ (1 + r2);

    dthetadom = [ (dthetadr').*drdom(:,1)   (dthetadr').*drdom(:,2)  (dthetadr').*drdom(:,3) ];
    dthetadT = [ (dthetadr').*drdT(:,1)   (dthetadr').*drdT(:,2)  (dthetadr').*drdT(:,3) ];
end;

% Add the fisheye distortion:

theta2 = theta.^2;
theta3 = theta2.*theta;
theta4 = theta2.^2;
theta5 = theta4.*theta;
theta6 = theta3.^2;
theta7 = theta6.*theta;
theta8 = theta4.*theta4;
theta9 = theta8.*theta;

% Fisheye distortion -> theta_d = theta * (1 + k(1)*theta2 + k(2)*theta4 + k(3)*theta6 + k(4)*theta8)

theta_d = theta + k(1)*theta3 + k(2)*theta5 + k(3)*theta7 + k(4)*theta9;

if nargout > 1,
    dtheta_ddtheta = 1 + 3*k(1)*theta2 + 5*k(2)*theta4 + 7*k(3)*theta6 + 9*k(4)*theta8;
    dtheta_ddom = [ (dtheta_ddtheta').*dthetadom(:,1)   (dtheta_ddtheta').*dthetadom(:,2)  (dtheta_ddtheta').*dthetadom(:,3) ];
    dtheta_ddT = [ (dtheta_ddtheta').*dthetadT(:,1)   (dtheta_ddtheta').*dthetadT(:,2)  (dtheta_ddtheta').*dthetadT(:,3) ];
    dtheta_ddk = [theta3' theta5' theta7' theta9'];
end;

% ratio:
inv_r = ones(1,length(r));
inv_r(r>1e-8) = 1./r(r>1e-8);

cdist = ones(1,length(r));
cdist(r > 1e-8) = theta_d(r > 1e-8) ./ r(r > 1e-8);

if nargout > 1,
    dcdistdom = [ ((inv_r').*(dtheta_ddom(:,1) - (cdist').*drdom(:,1)))  ((inv_r').*(dtheta_ddom(:,2) - (cdist').*drdom(:,2)))   ((inv_r').*(dtheta_ddom(:,3) - (cdist').*drdom(:,3))) ];
    dcdistdT = [ ((inv_r').*(dtheta_ddT(:,1) - (cdist').*drdT(:,1)))  ((inv_r').*(dtheta_ddT(:,2) - (cdist').*drdT(:,2)))   ((inv_r').*(dtheta_ddT(:,3) - (cdist').*drdT(:,3))) ];
    dcdistdk = [ (inv_r'.*dtheta_ddk(:,1)) (inv_r'.*dtheta_ddk(:,2)) (inv_r'.*dtheta_ddk(:,3))  (inv_r'.*dtheta_ddk(:,4)) ];
end;

xd1 = x .* (ones(2,1)*cdist);

if nargout > 1,
    dxd1dom = zeros(2*n,3);
    dxd1dom(1:2:end,:) = (x(1,:)'*ones(1,3)) .* dcdistdom;
    dxd1dom(2:2:end,:) = (x(2,:)'*ones(1,3)) .* dcdistdom;
    coeff = (reshape([cdist;cdist],2*n,1)*ones(1,3));
    dxd1dom = dxd1dom + coeff.* dxdom;

    dxd1dT = zeros(2*n,3);
    dxd1dT(1:2:end,:) = (x(1,:)'*ones(1,3)) .* dcdistdT;
    dxd1dT(2:2:end,:) = (x(2,:)'*ones(1,3)) .* dcdistdT;
    dxd1dT = dxd1dT + coeff.* dxdT;

    dxd1dk = zeros(2*n,4);
    dxd1dk(1:2:end,:) = (x(1,:)'*ones(1,4)) .* dcdistdk;
    dxd1dk(2:2:end,:) = (x(2,:)'*ones(1,4)) .* dcdistdk;
end;

% No tangential distortion:
xd2 = xd1;
if nargout > 1,
    dxd2dom = dxd1dom;
    dxd2dT = dxd1dT;
    dxd2dk = dxd1dk;
end;

% Add Skew:
xd3 = [xd2(1,:) + alpha*xd2(2,:);xd2(2,:)];

% Compute: dxd3dom, dxd3dT, dxd3dk, dxd3dalpha
if nargout > 1,
    dxd3dom = zeros(2*n,3);
    dxd3dom(1:2:2*n,:) = dxd2dom(1:2:2*n,:) + alpha*dxd2dom(2:2:2*n,:);
    dxd3dom(2:2:2*n,:) = dxd2dom(2:2:2*n,:);
    dxd3dT = zeros(2*n,3);
    dxd3dT(1:2:2*n,:) = dxd2dT(1:2:2*n,:) + alpha*dxd2dT(2:2:2*n,:);
    dxd3dT(2:2:2*n,:) = dxd2dT(2:2:2*n,:);
    dxd3dk = zeros(2*n,4);
    dxd3dk(1:2:2*n,:) = dxd2dk(1:2:2*n,:) + alpha*dxd2dk(2:2:2*n,:);
    dxd3dk(2:2:2*n,:) = dxd2dk(2:2:2*n,:);
    dxd3dalpha = zeros(2*n,1);
    dxd3dalpha(1:2:2*n,:) = xd2(2,:)';
end;

% Pixel coordinates:
if length(f)>1,
    xp = xd3 .* (f * ones(1,n))  +  c*ones(1,n);
    if nargout > 1,
        coeff = reshape(f*ones(1,n),2*n,1);
        dxpdom = (coeff*ones(1,3)) .* dxd3dom;
        dxpdT = (coeff*ones(1,3)) .* dxd3dT;
        dxpdk = (coeff*ones(1,4)) .* dxd3dk;
        dxpdalpha = (coeff) .* dxd3dalpha;
        dxpdf = zeros(2*n,2);
        dxpdf(1:2:end,1) = xd3(1,:)';
        dxpdf(2:2:end,2) = xd3(2,:)';
    end;
else
    xp = f * xd3 + c*ones(1,n);
    if nargout > 1,
        dxpdom = f  * dxd3dom;
        dxpdT = f * dxd3dT;
        dxpdk = f  * dxd3dk;
        dxpdalpha = f .* dxd3dalpha;
        dxpdf = xd3(:);
    end;
end;

if nargout > 1,
    dxpdc = zeros(2*n,2);
    dxpdc(1:2:end,1) = ones(n,1);
    dxpdc(2:2:end,2) = ones(n,1);
end;

return;

% Test of the Jacobians:

n = 10;

X = 10*randn(3,n);
om = randn(3,1);
T = [10*randn(2,1);40];
f = 1000*rand(2,1);
c = 1000*randn(2,1);
k = 0.5*randn(4,1);
alpha = 0.01*randn(1,1);

[x,dxdom,dxdT,dxdf,dxdc,dxdk,dxdalpha] = project_points_fisheye(X,om,T,f,c,k,alpha);


% Test on om: not OK

dom = 0.00000000001 * norm(om)*randn(3,1);
om2 = om + dom;

[x2] = project_points_fisheye(X,om2,T,f,c,k,alpha);

x_pred = x + reshape(dxdom * dom,2,n);


norm(x2-x)/norm(x2 - x_pred)


% Test on T: not OK

dT = 0.0001 * norm(T)*randn(3,1);
T2 = T + dT;

[x2] = project_points_fisheye(X,om,T2,f,c,k,alpha);

x_pred = x + reshape(dxdT * dT,2,n);


norm(x2-x)/norm(x2 - x_pred)



% Test on f: OK!!

df = 0.001 * norm(f)*randn(2,1);
f2 = f + df;

[x2] = project_points_fisheye(X,om,T,f2,c,k,alpha);

x_pred = x + reshape(dxdf * df,2,n);


norm(x2-x)/norm(x2 - x_pred)


% Test on c: OK!!

dc = 0.01 * norm(c)*randn(2,1);
c2 = c + dc;

[x2] = project_points_fisheye(X,om,T,f,c2,k,alpha);

x_pred = x + reshape(dxdc * dc,2,n);

norm(x2-x)/norm(x2 - x_pred)

% Test on k: OK!!

dk = 0.00001 * norm(k)*randn(4,1);
k2 = k + dk;

[x2] = project_points_fisheye(X,om,T,f,c,k2,alpha);

x_pred = x + reshape(dxdk * dk,2,n);

norm(x2-x)/norm(x2 - x_pred)


% Test on alpha: OK!!

dalpha = 0.001 * norm(k)*randn(1,1);
alpha2 = alpha + dalpha;

[x2] = project_points_fisheye(X,om,T,f,c,k,alpha2);

x_pred = x + reshape(dxdalpha * dalpha,2,n);

norm(x2-x)/norm(x2 - x_pred)
