function V = downsample(U)

% Try the 5x5 filter for building the pyramid:
% Now works with color images!

U = double(U);

[r,c,k] = size(U);

p = floor((r+1)/2); % row
q = floor((c+1)/2); % col


U2 = zeros(r+2,c+2,k);

for i=1:k

	U2(:,:,i) = [U(:,:,i) U(:,end,i)*ones(1,2); ones(2,1)*U(end,:,i) U(end,end,i)*ones(2,2)];
   
end;

cp = 2*(0:(p-1))+1; % row
cq = 2*(0:(q-1))+1; % col


r2 = length(cp);
c2 = length(cq);

e = cq+1;
ee = cq+2;
w = cq-1; w(1) = 1;
ww = cq-2; ww(1) = 1; ww(2) = 1;
n = cp-1; n(1) = 1;
nn = cp-2; nn(1) = 1; nn(2) = 1;
s = cp+1;
ss = cp+2;

V = zeros(r2,c2,k);

for i = 1:k,
   
   V(:,:,i) = (36*U2(cp,cq,i) + 24*(U2(n,cq,i) + U2(s,cq,i) + U2(cp,e,i) + U2(cp,w,i)) + ...
      16 * (U2(n,e,i) + U2(s,e,i) + U2(n,w,i) + U2(s,w,i)) + ...
      6 * (U2(nn,cq,i) + U2(ss,cq,i) + U2(cp,ee,i) + U2(cp,ww,i)) + ...
      4 * (U2(n,ww,i) + U2(nn,w,i) + U2(n,ee,i) + U2(nn,e,i) + U2(s,ww,i) + U2(ss,w,i) + U2(s,ee,i) + U2(ss,e,i)) + ...
   	(U2(nn,ee,i) + U2(ss,ee,i) + U2(nn,ww,i) + U2(ss,ww,i)))/256;
   
end;

return

% DOWNSAMPLE2	9-point subsampling (see Burt,Adelson IEEE Tcomm 31, 532)
%		V = downsample2(U)

[r,c] = size(U);

p = floor((r+1)/2);
q = floor((c+1)/2);


U2 = [U U(:,end); U(end,:) U(end,end)];


cq = 2*(0:(q-1))+1;
cp = 2*(0:(p-1))+1;

%cp = 2*([1:p]'-1)+1;
%cq = 2*([1:q]-1)+1;

e = cq+1; %e(q) = e(q)-1;
w = cq-1; w(1) = w(1)+1;
n = cp-1; n(1) = n(1)+1;
s = cp+1; %s(p) = s(p)-1;

% Interior
V = 0.25 * U2(cp,cq) + ...
	0.125*(U2(n,cq) + U2(s,cq) + U2(cp,e) + U2(cp,w)) + ...
	0.0625*(U2(n,e) + U2(s,e) + U2(n,w) + U2(s,w));
