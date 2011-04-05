function A = affine(X,n,om,T,fc,cc,alpha_c)

if nargin < 7,
   alpha_c = 0;
   if nargin < 6,
      cc = [0;0];
      if nargin < 5,
         fc = [1;1];
         if nargin < 4,
            T = zeros(3,1);
            if nargin < 3,
               om = zeros(3,1);
               if nargin < 2,
                  n = [0;0;-1];
                  if nargin < 1,
                     error('Error: affine needs some arguments: A = affine(X,n,om,T,fc,cc,alpha_c);');
                  end;
               end;
            end;
         end;
      end;
   end;
end;


KK = [fc(1) alpha_c*fc(1) cc(1); 0 fc(2) cc(2);0 0 1];
R = rodrigues(om);
omega = n / dot(n,X);
x = X/X(3);

H = KK * [R + T*omega'] * inv(KK);

A = (H(3,3)*H(1:2,1:2) - H(1:2,3)*H(3,1:2) + (H(3,2)*H(1:2,1) - H(3,1)*H(1:2,2))*[x(2) -x(1)])/(H(3,:)*x)^2;
