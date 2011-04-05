function Is = anisdiff(I,sigI,NIter);

if nargin < 3,
   NIter = 4;
	if nargin < 2,
   	sigI = 10;
	end;
end;

% Function that diffuse an image anisotropially.

Is = I;

[ny,nx] = size(I);

c_n = zeros(ny-2,nx-2);
c_s = zeros(ny-2,nx-2);
c_w = zeros(ny-2,nx-2);
c_e = zeros(ny-2,nx-2);
c_nw = zeros(ny-2,nx-2);
c_ne = zeros(ny-2,nx-2);
c_sw = zeros(ny-2,nx-2);
c_se = zeros(ny-2,nx-2);
c_c = ones(ny-2,nx-2);


for k=1:NIter,
   
	dI_n = Is(2:end-1,2:end-1) - Is(1:end-2,2:end-1);
	dI_s = Is(2:end-1,2:end-1) - Is(3:end,2:end-1);
	dI_w = Is(2:end-1,2:end-1) - Is(2:end-1,1:end-2);
	dI_e = Is(2:end-1,2:end-1) - Is(2:end-1,3:end);
	dI_nw = Is(2:end-1,2:end-1) - Is(1:end-2,1:end-2);
	dI_ne = Is(2:end-1,2:end-1) - Is(1:end-2,3:end);
	dI_sw = Is(2:end-1,2:end-1) - Is(3:end,1:end-2);
	dI_se = Is(2:end-1,2:end-1) - Is(3:end,3:end);
	
	
	c_n = exp(-.5*(dI_n/sigI).^2)/8;
	c_s = exp(-.5*(dI_s/sigI).^2)/8;
	c_w = exp(-.5*(dI_w/sigI).^2)/8;
	c_e = exp(-.5*(dI_e/sigI).^2)/8;
	c_nw = exp(-.5*(dI_nw/sigI).^2)/16;
	c_ne = exp(-.5*(dI_ne/sigI).^2)/16;
	c_sw = exp(-.5*(dI_sw/sigI).^2)/16;
	c_se = exp(-.5*(dI_se/sigI).^2)/16;
	
	c_c = 1 - (c_n + c_s + c_w + c_e + c_nw + c_ne + c_sw + c_se);
	
	
	Is(2:end-1,2:end-1) = c_c .* Is(2:end-1,2:end-1)  +  c_n .* Is(1:end-2,2:end-1) + c_s .* Is(3:end,2:end-1) + ...
   	c_w .* Is(2:end-1,1:end-2) + c_e .* Is(2:end-1,3:end) + c_nw .* Is(1:end-2,1:end-2) + c_ne .* Is(1:end-2,3:end) + ... 
		c_sw .* Is(3:end,1:end-2) + c_se .* Is(3:end,3:end);
	
end;
