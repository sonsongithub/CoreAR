function [om,T,Y] = align_structures(X1,X2),

% Find om (R) and T, such that Y = R*X1 + T is as close as
% possible to X2.

[m,n] = size(X1);

% initialization:




% initialize param to no motion:
param = zeros(6,1);
change = 1;

while change > 1e-6,
  	
	om = param(1:3);
	T = param(4:6);
	
	[Y,dYdom,dYdT] = rigid_motion(X1,om,T);
	
	J = [dYdom dYdT];
	
	err = X2(:) - Y(:);
	
   param_up = inv(J'*J)*J'*err;
   
	param = param + param_up;
   
   change = norm(param_up)/norm(param);
   
end;

om = param(1:3);

T = param(4:6);

[Y,dYdom,dYdT] = rigid_motion(X1,om,T);
