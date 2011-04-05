function [xc,good,bad,type] = cornerfinder2(xt,I,wintx,winty,wx2,wy2);

%[xc] = cornerfinder(xt,I);
%
%Finds the sub-pixel corners on the image I with initial guess xt
%xt and xc are 2xN matrices. The first component is the x coordinate
%(horizontal) and the second component is the y coordinate (vertical)
% 
%Based on Harris corner finder method
%
%Finds corners to a precision below .1 pixel!
%Oct. 14th, 1997 - UPDATED to work with vertical and horizontal edges as well!!!
%Sept 1998 - UPDATED to handle diverged points: we keep the original points
%good is a binary vector indicating wether a feature point has been properly
%found.
%
%Add a zero zone of size wx2,wy2
%July 15th, 1999 - Bug on the mask building... fixed + change to Gaussian mask with higher
%resolution and larger number of iterations.


% California Institute of Technology
% (c) Jean-Yves Bouguet -- Oct. 14th, 1997



line_feat = 1; % set to 1 to allow for extraction of line features.

xt = xt';
xt = fliplr(xt);


if nargin < 4,
   winty = 5;
   if nargin < 3,
      wintx = 5;
   end;
end;


if nargin < 6,
   wx2 = -1;
   wy2 = -1;
end;


%mask = ones(2*wintx+1,2*winty+1);
mask = exp(-((-wintx:wintx)'/(wintx)).^2) * exp(-((-winty:winty)/(winty)).^2);


% another mask:
[X,Y] = meshgrid(-winty:winty,-wintx:wintx);
mask2 = X.^2 + Y.^2;
mask2(wintx+1,winty+1) = 1;
mask2 = 1./mask2;
%mask - mask2;


if (wx2>0) & (wy2>0),
   if ((wintx - wx2)>=2)&((winty - wy2)>=2),
      mask(wintx+1-wx2:wintx+1+wx2,winty+1-wy2:winty+1+wy2)= zeros(2*wx2+1,2*wy2+1);
   end;
end;

offx = [-wintx:wintx]'*ones(1,2*winty+1);
offy = ones(2*wintx+1,1)*[-winty:winty];

resolution = 0.005;

MaxIter = 10;

[nx,ny] = size(I);
N = size(xt,1);

xc = xt; % first guess... they don't move !!!

type = zeros(1,N);


for i=1:N,
   
   v_extra = resolution + 1; 		% just larger than resolution
   
   compt = 0; 				% no iteration yet
   
   while (norm(v_extra) > resolution) & (compt<MaxIter),
      
      cIx = xc(i,1); 			%
      cIy = xc(i,2); 			% Coords. of the point
      crIx = round(cIx); 		% on the initial image
      crIy = round(cIy); 		%      
      itIx = cIx - crIx; 		% Coefficients
      itIy = cIy - crIy; 		% to compute
      if itIx > 0, 			% the sub pixel
	 vIx = [itIx 1-itIx 0]'; 	% accuracy.
      else
	 vIx = [0 1+itIx -itIx]';
      end;
      if itIy > 0,
	 vIy = [itIy 1-itIy 0];
      else
	 vIy = [0 1+itIy -itIy];
      end;

      
      % What if the sub image is not in?
      
      if (crIx-wintx-2 < 1), xmin=1; xmax = 2*wintx+5;
      elseif (crIx+wintx+2 > nx), xmax = nx; xmin = nx-2*wintx-4;
      else
	 xmin = crIx-wintx-2; xmax = crIx+wintx+2;
      end;

      if (crIy-winty-2 < 1), ymin=1; ymax = 2*winty+5;
      elseif (crIy+winty+2 > ny), ymax = ny; ymin = ny-2*winty-4;
      else
	 ymin = crIy-winty-2; ymax = crIy+winty+2;
      end;
      
      
      SI = I(xmin:xmax,ymin:ymax); % The necessary neighborhood
      SI = conv2(conv2(SI,vIx,'same'),vIy,'same');
      SI = SI(2:2*wintx+4,2:2*winty+4); % The subpixel interpolated neighborhood
      [gy,gx] = gradient(SI); 		% The gradient image
      gx = gx(2:2*wintx+2,2:2*winty+2); % extraction of the useful parts only
      gy = gy(2:2*wintx+2,2:2*winty+2); % of the gradients
      
      px = cIx + offx;
      py = cIy + offy;
      
      gxx = gx .* gx .* mask;
      gyy = gy .* gy .* mask;
      gxy = gx .* gy .* mask;
   
      
      bb = [sum(sum(gxx .* px + gxy .* py)); sum(sum(gxy .* px + gyy .* py))];
      
      a = sum(sum(gxx));
      b = sum(sum(gxy));
      c = sum(sum(gyy));
      
      dt = a*c - b^2;
      
      xc2 = [c*bb(1)-b*bb(2) a*bb(2)-b*bb(1)]/dt;
      
      
      %keyboard;
      
      if line_feat,
      
	 G = [a b;b c];
	 [U,S,V]  = svd(G);
	 
	 %keyboard;
	 
	 % If non-invertible, then project the point onto the edge orthogonal:
	 
	 if (S(1,1)/S(2,2) > 50),
	    % projection operation:
	    xc2 = xc2 + sum((xc(i,:)-xc2).*(V(:,2)'))*V(:,2)';
	    type(i) = 1;
	 end;
      
      end;
      
      
      %keyboard;
      
%      G = [a b;b c];
%      [U,S,V]  = svd(G);


%      if S(1,1)/S(2,2) > 150,
%	 bb2 = U'*bb;
%	 xc2 = (V*[bb2(1)/S(1,1) ;0])';
%      else
%	 xc2 = [c*bb(1)-b*bb(2) a*bb(2)-b*bb(1)]/dt;
%      end;
      
      
      %if (abs(a)> 50*abs(c)),
%	 xc2 = [(c*bb(1)-b*bb(2))/dt xc(i,2)];
%      elseif (abs(c)> 50*abs(a))
%	 xc2 = [xc(i,1) (a*bb(2)-b*bb(1))/dt];
%      else
%	 xc2 = [c*bb(1)-b*bb(2) a*bb(2)-b*bb(1)]/dt;
%      end;
      
      %keyboard;
      
      v_extra = xc(i,:) - xc2;
      
      xc(i,:) = xc2;
      
%      keyboard;

      compt = compt + 1;
      
   end
end;


% check for points that diverge:

delta_x = xc(:,1) - xt(:,1);
delta_y = xc(:,2) - xt(:,2);

%keyboard;


bad = (abs(delta_x) > wintx) | (abs(delta_y) > winty);
good = ~bad;
in_bad = find(bad);

% For the diverged points, keep the original guesses:

xc(in_bad,:) = xt(in_bad,:);

xc = fliplr(xc);
xc = xc';

bad = bad';
good = good';
