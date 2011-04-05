function [xL,xR] = click_stereo(NUMBER_OF_POINTS,IL,IR,R,T,fc_right,cc_right,kc_right,alpha_c_right,fc_left,cc_left,kc_left,alpha_c_left);


figure(1);
image(IL);

figure(2);
image(IR);

[ny,nx] = size(IL);

xL = [];
xR = [];

for kk = 1:NUMBER_OF_POINTS,
    
    figure(1);
    hold on;
    x = ginput(1);
    plot(x(1),x(2),'g.');
    hold off;
    x = x'-1;
    
    xL = [xL x];
    
    [epipole] = compute_epipole(x,R,T,fc_right,cc_right,kc_right,alpha_c_right,fc_left,cc_left,kc_left,alpha_c_left);

    figure(2);
    hold on;
    h = plot(epipole(1,:)+1,epipole(2,:)+1,'r.','markersize',1);
    hold off;
  
    x2 = ginput(1);
    x2 = x2' - 1;
    
    NN = size(epipole,2);
    d = sum((epipole - repmat(x2,1,NN)).^2);
    [junk,indmin] = min(d);
    
    x2 = epipole(:,indmin);
    
    xR = [xR x2];
    
    delete(h);
    
    figure(2);
    hold on;
    plot(x2(1)+1,x2(2)+1,'g.');
    drawnow;
    hold off;
    
end;

