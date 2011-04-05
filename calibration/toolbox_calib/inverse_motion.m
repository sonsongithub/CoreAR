function [om2,T2,dom2dom,dom2dT,dT2dom,dT2dT] = inverse_motion(om,T);

% This function computes the inverse motion corresponding to (om,T)


om2 = -om;
dom2dom = -eye(3);
dom2dT = zeros(3,3);


[R,dRdom] = rodrigues(om);
Rinv = R';
dRinvdR = zeros(9,9);
dRinvdR([1 4 7],[1 2 3]) = eye(3);
dRinvdR([2 5 8],[4 5 6]) = eye(3);
dRinvdR([3 6 9],[7 8 9]) = eye(3);
dRinvdom = dRinvdR * dRdom;

Tt = Rinv * T;
[dTtdRinv,dTtdT] = dAB(Rinv,T);

T2 = -Tt;

dT2dom = - dTtdRinv * dRinvdom;
dT2dT = - dTtdT;


return;

% Test of the Jacobians:

om = randn(3,1);
T = 10*randn(3,1);
[om2,T2,dom2dom,dom2dT,dT2dom,dT2dT] = inverse_motion(om,T);

dom = randn(3,1) / 100000;
dT  = randn(3,1) / 100000;

[om3r,T3r] = inverse_motion(om+dom,T+dT);

om3p = om2 + dom2dom*dom +  dom2dT*dT;
T3p  =  T2 + dT2dom*dom  +  dT2dT*dT;

%norm(om3r - om2) / norm(om3r - om3p)  %-> Leads to infinity, since the opreation is linear!
norm(T3r - T2) / norm(T3r - T3p)
