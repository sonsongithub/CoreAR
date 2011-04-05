function ns = count_squares(I,x1,y1,x2,y2,win);

[ny,nx] = size(I);

if ((x1-win <= 0) || (x1+win >= nx) || (y1-win <= 0) || (y1+win >= ny) || ...
        (x2-win <= 0) || (x2+win >= nx) || (y2-win <= 0) || (y2+win >= ny))
    ns = -1;
    return;
end;

if ((x1 - x2)^2+(y1-y2)^2) <  win,
    ns = -1;
    return;
end;

lambda = [y1 - y2;x2 - x1;x1*y2 - x2*y1];
lambda = 1/sqrt(lambda(1)^2 + lambda(2)^2) * lambda;
l1 = lambda + [0;0;win];
l2 = lambda - [0;0;win];
dx = x2-x1;
dy = y2 - y1;

if abs(dx) > abs(dy),   
   if x2 > x1,
      xs = x1:x2;
   else
      xs = x1:-1:x2;
   end;
   ys = -(lambda(3) + lambda(1)*xs)/lambda(2);
else
   if y2 > y1,
       ys = y1:y2;
   else
       ys = y1:-1:y2;
   end;
   xs = -(lambda(3) + lambda(2)*ys)/lambda(1);
end;

Np = length(xs);
xs_mat = ones(2*win + 1,1)*xs;
ys_mat = ones(2*win + 1,1)*ys;
win_mat = (-win:win)'*ones(1,Np);
xs_mat2 = round(xs_mat - win_mat * lambda(1));
ys_mat2 = round(ys_mat - win_mat * lambda(2));
ind_mat = (xs_mat2 - 1) * ny + ys_mat2;
ima_patch = zeros(2*win + 1,Np);
ima_patch(:) = I(ind_mat(:));

%ima2 = ima_patch(:,win+1:end-win);

filtk = [ones(win,Np);zeros(1,Np);-ones(win,Np)];
out_f = sum(filtk.*ima_patch);
out_f_f = conv2(out_f,[1/4 1/2 1/4],'same');
out_f_f = out_f_f(win+1:end-win);
ns = length(find(((out_f_f(2:end)>=0)&(out_f_f(1:end-1)<0)) | ((out_f_f(2:end)<=0)&(out_f_f(1:end-1)>0))))+1;

return;
