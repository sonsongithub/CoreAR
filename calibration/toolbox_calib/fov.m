% small program that computes the field of view of a camera (in degrees)

if ~exist('fc')|~exist('cc')|~exist('nx')|~exist('ny'),
   error('Need calibration results to compute FOV (fc,cc,Wcal,Hcal)');
end;

FOV_HOR = 180 * ( atan((nx - (cc(1)+.5))/fc(1))  +  atan((cc(1)+.5)/fc(1))   )/pi;

FOV_VER = 180 * ( atan((ny - (cc(2)+.5))/fc(2))  +  atan((cc(2)+.5)/fc(2))   )/pi;

fprintf(1,'Horizontal field of view = %.2f degrees\n',FOV_HOR);
fprintf(1,'Vertical field of view = %.2f degrees\n',FOV_VER);