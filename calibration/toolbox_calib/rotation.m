function [] = rotation(st);

if nargin < 1,
   st= 1;
end;


fig = gcf;

ax = gca;

vv = get(ax,'view');

az = vv(1);
el = vv(2);

for azi = az:-abs(st):az-360,
   
   set(ax,'view',[azi el]);
   figure(fig);
   drawnow;
   
end;
