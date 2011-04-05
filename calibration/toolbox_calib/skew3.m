function [S,dSdT] = skew3(T);

S = [   0  -T(3)  T(2)
      T(3)   0   -T(1)
     -T(2)  T(1)   0 ];

dSdT = [0 0 0;0 0 1;0 -1 0 ;0 0 -1;0 0 0;1 0 0 ;0 1 0;-1 0 0; 0 0 0];

return;


% Test of Jacobian:

T1 = randn(3,1);

dT = 0.001*randn(3,1);

T2 = T1 + dT;

[S1,dSdT] = skew3(T1);
[S2] = skew3(T2);

S2app = S1;
S2app(:) = S2app(:) + dSdT*dT;


norm(S1 - S2) / norm(S2app - S2)
