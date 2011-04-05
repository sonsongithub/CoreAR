function [dABdA,dABdB] = dAB(A,B);

%      [dABdA,dABdB] = dAB(A,B);
%
%      returns : dABdA and dABdB

[p,n] = size(A); [n2,q] = size(B);

if n2 ~= n,
   error(' A and B must have equal inner dimensions');
end;

if issparse(A) |  issparse(B) | p*q*p*n>625 ,
  dABdA=spalloc(p*q,p*n,p*q*n);
else
  dABdA=zeros(p*q,p*n);
end;


for i=1:q,
   for j=1:p,
   ij = j + (i-1)*p;
      for k=1:n,
         kj = j + (k-1)*p;
         dABdA(ij,kj) = B(k,i);
      end;
   end;
end;


if issparse(A) |  issparse(B) | p*q*n*q>625 ,
  dABdB=spalloc(p*q,n*q,p*q*n);
else
  dABdB=zeros(p*q,q*n);
end;

for i=1:q
   dABdB([i*p-p+1:i*p]',[i*n-n+1:i*n]) = A;
end;
