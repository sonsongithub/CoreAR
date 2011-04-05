function ns = count_squares_fisheye_distorted(I,x1,y1,x2,y2,win, fg, cg, kg);

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

nX = round(sqrt((x1-x2)^2 + (y1-y2)^2));
alpha_x = (0:nX)/nX;

pt1n = normalize_pixel_fisheye([x1;y1]-1,fg,cg,kg,0);
pt2n = normalize_pixel_fisheye([x2;y2]-1,fg,cg,kg,0);

ptsn = repmat(pt1n,[1 nX+1]) + (pt2n - pt1n)*alpha_x;

pts = apply_fisheye_distortion(ptsn,kg);
pts(1,:) = fg(1)*pts(1,:) + cg(1);
pts(2,:) = fg(2)*pts(2,:) + cg(2);

% Check that the curve is within the image:
good_line = (min(pts(1,:))-win > 0) && (max(pts(1,:))+win < (nx-1)) && ...
    (min(pts(2,:))-win > 0) && (max(pts(2,:))+win <(ny-1));

if ~good_line,
    ns = -1;
    return;
end;

% Deviate the trajectory orthogonally:
lambda = [y1 - y2 ; x2 - x1];
lambda = lambda / sqrt(sum(lambda.^2));

Np = size(pts,2);
xs_mat = ones(2*win + 1,1)*pts(1,:);
ys_mat = ones(2*win + 1,1)*pts(2,:);
win_mat = (-win:win)'*ones(1,Np);
xs_mat2 = round(xs_mat - win_mat * lambda(1));
ys_mat2 = round(ys_mat - win_mat * lambda(2));
ind_mat = (xs_mat2) * ny + ys_mat2 + 1;
ima_patch = zeros(2*win + 1,Np);
ima_patch(:) = I(ind_mat(:));

filtk = [ones(win,Np);zeros(1,Np);-ones(win,Np)];
out_f = sum(filtk.*ima_patch);
out_f_f = conv2(out_f,[1/4 1/2 1/4],'same');
out_f_f = out_f_f(win+1:end-win);
ns = length(find(((out_f_f(2:end)>=0)&(out_f_f(1:end-1)<0)) | ((out_f_f(2:end)<=0)&(out_f_f(1:end-1)>0))))+1;
