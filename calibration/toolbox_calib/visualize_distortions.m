% visualize_distortions
%
%
% A script to run in conjunction with calib_gui in TOOLBOX_calib to plot
% the distortion models.
%
% This is a slightly modified version of the script plot_CCT_distortion.m written by Mr. Oshel
% Thank you Mr. Oshel for your contribution!


[mx,my] = meshgrid(0:nx/20:(nx-1),0:ny/20:(ny-1));
[nnx,nny]=size(mx);
px=reshape(mx',nnx*nny,1);
py=reshape(my',nnx*nny,1);
kk_new=[fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2);0 0 1];
rays=inv(kk_new)*[px';py';ones(1,length(px))];
x=[rays(1,:)./rays(3,:);rays(2,:)./rays(3,:)];


title2=strcat('Complete Distortion Model');

fh1 = 2;

%if ishandle(fh1),
%    close(fh1);
%end;
figure(fh1); clf;
xd=apply_distortion(x,kc);
px2=fc(1)*(xd(1,:)+alpha_c*xd(2,:))+cc(1);
py2=fc(2)*xd(2,:)+cc(2);
dx=px2'-px;
dy=py2'-py;
Q=quiver(px+1,py+1,dx,dy);
hold on;
plot(cc(1)+1,cc(2)+1,'o');
plot((nx-1)/2+1,(ny-1)/2+1,'x');
dr=reshape(sqrt((dx.*dx)+(dy.*dy)),nny,nnx)';
[C,h]=contour(mx,my,dr,'k');
clabel(C,h);
Mean=mean(mean(dr));
Max=max(max(dr));
title(title2);

axis ij;
axis([1 nx 1 ny])
axis equal;
axis tight;

position=get(gca,'Position');
shr = 0.9;
position(1)=position(1)+position(3)*((1-shr)/2);
position(2)=position(2)+position(4)*(1-shr)+0.03;
position(3:4)=position(3:4)*shr;
set(gca,'position',position);
set(gca,'fontsize',8,'fontname','clean')

gh = gca;

line1=sprintf('Principal Point               = (%0.6g, %0.6g)',cc(1),cc(2));
line2=sprintf('Focal Length                 = (%0.6g, %0.6g)',fc(1),fc(2));
line3=sprintf('Radial coefficients         = (%0.4g, %0.4g, %0.4g)',kc(1),kc(2),kc(5));
line4=sprintf('Tangential coefficients  = (%0.4g, %0.4g)',kc(3),kc(4));
line5=sprintf('+/- [%0.4g, %0.4g]',cc_error(1),cc_error(2));
line6=sprintf('+/- [%0.4g, %0.4g]',fc_error(1),fc_error(2));
line7=sprintf('+/- [%0.4g, %0.4g, %0.4g]',kc_error(1),kc_error(2),kc_error(5));
line8=sprintf('+/- [%0.4g, %0.4g]',kc_error(3),kc_error(4));
line9=sprintf('Pixel error                      = [%0.4g, %0.4g]',err_std(1),err_std(2));
line10=sprintf('Skew                              = %0.4g',alpha_c);
line11=sprintf('+/- %0.4g',alpha_c_error);


axes('position',[0 0 1 1],'visible','off');
th=text(0.11,0,{line9,line2,line1,line10,line3,line4},'horizontalalignment','left','verticalalignment','bottom','fontsize',8,'fontname','clean');
th2=text(0.9,0.,{line6,line5,line11,line7,line8},'horizontalalignment','right','verticalalignment','bottom','fontsize',8,'fontname','clean');
%set(th,'FontName','fixed');
axes(gh);

set(fh1,'color',[1,1,1]);

hold off;





title2=strcat('Tangential Component of the Distortion Model');

fh2 = 3;

%if ishandle(fh2),
%    close(fh2);
%end;
figure(fh2); clf;
xd=apply_distortion(x,[0 0 kc(3) kc(4) 0]);
px2=fc(1)*(xd(1,:)+alpha_c*xd(2,:))+cc(1);
py2=fc(2)*xd(2,:)+cc(2);
dx=px2'-px;
dy=py2'-py;
Q=quiver(px+1,py+1,dx,dy);
hold on;
plot(cc(1)+1,cc(2)+1,'o');
plot((nx-1)/2+1,(ny-1)/2+1,'x');
dr=reshape(sqrt((dx.*dx)+(dy.*dy)),nny,nnx)';
[C,h]=contour(mx,my,dr,'k');
clabel(C,h);
Mean=mean(mean(dr));
Max=max(max(dr));
title(title2);

axis ij;
axis([1 nx 1 ny])
axis equal;
axis tight;

position=get(gca,'Position');
shr = 0.9;
position(1)=position(1)+position(3)*((1-shr)/2);
position(2)=position(2)+position(4)*(1-shr)+0.03;
position(3:4)=position(3:4)*shr;
set(gca,'position',position);
set(gca,'fontsize',8,'fontname','clean')

gh = gca;

line1=sprintf('Principal Point               = (%0.6g, %0.6g)',cc(1),cc(2));
line2=sprintf('Focal Length                 = (%0.6g, %0.6g)',fc(1),fc(2));
line3=sprintf('Radial coefficients         = (%0.4g, %0.4g, %0.4g)',kc(1),kc(2),kc(5));
line4=sprintf('Tangential coefficients  = (%0.4g, %0.4g)',kc(3),kc(4));
line5=sprintf('+/- [%0.4g, %0.4g]',cc_error(1),cc_error(2));
line6=sprintf('+/- [%0.4g, %0.4g]',fc_error(1),fc_error(2));
line7=sprintf('+/- [%0.4g, %0.4g, %0.4g]',kc_error(1),kc_error(2),kc_error(5));
line8=sprintf('+/- [%0.4g, %0.4g]',kc_error(3),kc_error(4));
line9=sprintf('Pixel error                      = [%0.4g, %0.4g]',err_std(1),err_std(2));
line10=sprintf('Skew                              = %0.4g',alpha_c);
line11=sprintf('+/- %0.4g',alpha_c_error);


axes('position',[0 0 1 1],'visible','off');
th=text(0.11,0,{line9,line2,line1,line10,line3,line4},'horizontalalignment','left','verticalalignment','bottom','fontsize',8,'fontname','clean');
th2=text(0.9,0.,{line6,line5,line11,line7,line8},'horizontalalignment','right','verticalalignment','bottom','fontsize',8,'fontname','clean');
%set(th,'FontName','fixed');
axes(gh);

set(fh2,'color',[1,1,1]);

hold off;








title2=strcat('Radial Component of the Distortion Model');

fh3 = 4;

%if ishandle(fh3),
%    close(fh3);
%end;
figure(fh3); clf;
xd=apply_distortion(x,[kc(1) kc(2) 0 0 kc(5)]);
px2=fc(1)*(xd(1,:)+alpha_c*xd(2,:))+cc(1);
py2=fc(2)*xd(2,:)+cc(2);
dx=px2'-px;
dy=py2'-py;
Q=quiver(px+1,py+1,dx,dy);
hold on;
plot(cc(1)+1,cc(2)+1,'o');
plot((nx-1)/2+1,(ny-1)/2+1,'x');
dr=reshape(sqrt((dx.*dx)+(dy.*dy)),nny,nnx)';
[C,h]=contour(mx,my,dr,'k');
clabel(C,h);
Mean=mean(mean(dr));
Max=max(max(dr));
title(title2);

axis ij;
axis([1 nx 1 ny])
axis equal;
axis tight;

position=get(gca,'Position');
shr = 0.9;
position(1)=position(1)+position(3)*((1-shr)/2);
position(2)=position(2)+position(4)*(1-shr)+0.03;
position(3:4)=position(3:4)*shr;
set(gca,'position',position);
set(gca,'fontsize',8,'fontname','clean')

gh = gca;

line1=sprintf('Principal Point               = (%0.6g, %0.6g)',cc(1),cc(2));
line2=sprintf('Focal Length                 = (%0.6g, %0.6g)',fc(1),fc(2));
line3=sprintf('Radial coefficients         = (%0.4g, %0.4g, %0.4g)',kc(1),kc(2),kc(5));
line4=sprintf('Tangential coefficients  = (%0.4g, %0.4g)',kc(3),kc(4));
line5=sprintf('+/- [%0.4g, %0.4g]',cc_error(1),cc_error(2));
line6=sprintf('+/- [%0.4g, %0.4g]',fc_error(1),fc_error(2));
line7=sprintf('+/- [%0.4g, %0.4g, %0.4g]',kc_error(1),kc_error(2),kc_error(5));
line8=sprintf('+/- [%0.4g, %0.4g]',kc_error(3),kc_error(4));
line9=sprintf('Pixel error                      = [%0.4g, %0.4g]',err_std(1),err_std(2));
line10=sprintf('Skew                              = %0.4g',alpha_c);
line11=sprintf('+/- %0.4g',alpha_c_error);


axes('position',[0 0 1 1],'visible','off');
th=text(0.11,0,{line9,line2,line1,line10,line3,line4},'horizontalalignment','left','verticalalignment','bottom','fontsize',8,'fontname','clean');
th2=text(0.9,0.,{line6,line5,line11,line7,line8},'horizontalalignment','right','verticalalignment','bottom','fontsize',8,'fontname','clean');
%set(th,'FontName','fixed');
axes(gh);

set(fh3,'color',[1,1,1]);

hold off;

figure(fh1);
