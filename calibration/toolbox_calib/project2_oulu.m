function [x] = project2_oulu(X,R,T,f,t,k)
%PROJECT     Subsidiary to calib

%         (c) Pietro Perona -- March 24, 1994
%         California Institute of Technology
%         Pasadena, CA
%         
%         Renamed because project exists in matlab 5.2!!!
%         Now uses the more elaborate intrinsic model from Oulu



[m,n] = size(X);

Y = R*X + T*ones(1,n);
Z = Y(3,:);

f = f(:); %% make a column vector
if length(f)==1,
   f = [f f]';
end;

x = (Y(1:2,:) ./ (ones(2,1) * Z)) ;


radius_2 = x(1,:).^2 + x(2,:).^2;

if length(k) > 1,

   radial_distortion = 1 + ones(2,1) * ((k(1) * radius_2) + (k(2) * radius_2.^2));
   
   if length(k) < 4,
      
      delta_x = zeros(2,n); 
      
   else
   
      delta_x = [2*k(3)*x(1,:).*x(2,:) + k(4)*(radius_2 + 2*x(1,:).^2) ;
	    k(3) * (radius_2 + 2*x(2,:).^2)+2*k(4)*x(1,:).*x(2,:)];
      
   end;
      

else
   
   radial_distortion = 1 + ones(2,1) * ((k(1) * radius_2));

   delta_x = zeros(2,n);
   
end;


x = (x .* radial_distortion + delta_x).* (f * ones(1,n))  + t*ones(1,n);
