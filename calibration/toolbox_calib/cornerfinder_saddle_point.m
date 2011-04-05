function [xc,good,bad,type] = cornerfinder_saddle_point(xt,I,wintx,winty,wx2,wy2);

%[xc] = cornerfinder_saddle_point(xt,I,wintx,winty);
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

      
      px = cIx + offx;
      py = cIy + offy;
      
      
      if 1, %~saddle,
          [gy,gx] = gradient(SI); 		% The gradient image
          gx = gx(2:2*wintx+2,2:2*winty+2); % extraction of the useful parts only
          gy = gy(2:2*wintx+2,2:2*winty+2); % of the gradients
          gxx = gx .* gx .* mask;
          gyy = gy .* gy .* mask;
          gxy = gx .* gy .* mask;
          
          
          bb = [sum(sum(gxx .* px + gxy .* py)); sum(sum(gxy .* px + gyy .* py))];
          
          a = sum(sum(gxx));
          b = sum(sum(gxy));
          c = sum(sum(gyy));
          
          dt = a*c - b^2;
          
          xc2 = [c*bb(1)-b*bb(2) a*bb(2)-b*bb(1)]/dt;
      else
          
          SI = SI(2:2*wintx+2,2:2*winty+2);
          A =  repmat(mask(:),1,6) .* [px(:).^2 px(:).*py(:) py(:).^2 px(:) py(:) ones((2*wintx+1)*(2*winty+1),1)];
          param = inv(A'*A)*A'*( mask(:).*SI(:));
          xc2 = (-inv([2*param(1) param(2) ; param(2) 2*param(3) ]) * param(4:5))';  
          
      end;
      
      v_extra = xc(i,:) - xc2;
      
      xc(i,:) = xc2;
      
      
      compt = compt + 1;
      
  end;
  
  
  
  if 1,
      
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
      px = cIx + offx;
      py = cIy + offy;
      
      SI = SI(2:2*wintx+2,2:2*winty+2);
      A =  repmat(mask(:),1,6) .* [px(:).^2 px(:).*py(:) py(:).^2 px(:) py(:) ones((2*wintx+1)*(2*winty+1),1)];
      param = inv(A'*A)*A'*( mask(:).*SI(:));
      xc2 = (-inv([2*param(1) param(2) ; param(2) 2*param(3) ]) * param(4:5))';  
      
      
      v_extra = xc(i,:) - xc2;
      
      xc(i,:) = xc2;
  end;
  
  
  
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
