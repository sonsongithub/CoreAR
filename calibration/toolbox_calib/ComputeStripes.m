function [xc,xp,nx,ny] = ComputeStripes(fname,graphout);

%[xc,xp] = ComputeStripes(fname,graphout)
%
% This function computes the projector stripe coordinate (at subpixel
% accuracy) at every pixel in the image. The algorithm used in temporal
% processing (with a translationnal pattern of period 32 pixels). A coarse
% to fine pattern projection helpresolve for the period ambiguity (in a
% Gray-Code Scheme).
%
% The naming convention is,
% 
% 	fname_pat##p.ras    --> for the positive image from pass ##
% 	fname_pat##n.ras	--> for the negative image from pass ##
%
% 	##=00: Black and White images
%
%   ##=[01 - 10] : Coarse to fine projection (Gary-Scale projection)
%   ##=[11 - 42 ]: 32 translational patterns of period 32 pixels (for
%                   temporal processing)
% INPUT:
%	fname   --> base name of the images
%   graphout --> Set to 1 to show graphical figures
%
% OUTPUT:
%	xc  is a 2 by N matrix of the point in the image plane
%       (convention: (0,0) -> center of the upper left pixel in the camera image)
%	xp	is a N vector of the corresponding projector stripe numbers (at subpixel accuracy).
%       (convention: (0,0) -> center of the upper left pixel in the projector image)
%   (nx,ny): Size of the camera image
%
%	(c) in 1996 by Jean-Yves Bouguet - Updated 11/26/2003


if nargin < 2,
    graphout = 0;
end;


N = 10;


%-- Load the white and black images:

blackIm = imread([fname '_pat00p.bmp']);
whiteIm = imread([fname '_pat00n.bmp']);

if size(blackIm,3) > 1,
    blackIm = 0.299 * double(blackIm(:,:,1)) + 0.5870 * double(blackIm(:,:,2)) + 0.114 * double(blackIm(:,:,3));
    whiteIm = 0.299 * double(whiteIm(:,:,1)) +  0.5870 * double(whiteIm(:,:,2)) + 0.114 * double(whiteIm(:,:,3));
else
    blackIm = double(blackIm);
    whiteIm = double(whiteIm);
end;

[ny,nx] = size(blackIm);


%%% Contrast Thresholding

%% good value for cthresh: 20

totContr = whiteIm - blackIm;
totContr(totContr < 0) = 0;

cthresh = 3; %--> totContr is larger than cthresh for valid pixels

% In order to remove the highlights (reject image regions where whiteIm >254)
hightlight_reject = 1;



%-- Enable processing of a small region of the image instead of the whole image:

xs = 1;
xe = nx;
ys = 1;
ye = ny;

totContr = totContr(ys:ye,xs:xe);
whiteIm = whiteIm(ys:ye,xs:xe);
blackIm = blackIm(ys:ye,xs:xe);

[yPixels xPixels] = size(totContr);


good1 = find((totContr > cthresh)&(whiteIm <= 254)); % the first mask!!! (no need to compute anything outside of this mask)
Ng1 = length(good1);





%--------------------------------------------------------------------------
%-- STEP 1: TEMPORAL PROCESSING -> Finding the edge time at every pixel in the image
%--------------------------------------------------------------------------

period = 32; % Total Period size in pixels of the projected pattern

index_list2 = (0:period-1) + N + 1;


% Read all temporal images (and compute max and min images):

for kk=0:period-1,
    
    tmp = imread([fname '_pat' sprintf('%.2d',index_list2(kk+1)) 'p.bmp']);
    
    if size(tmp,3) > 1,
        tmp = 0.299 * double(tmp(ys:ye,xs:xe,1)) + 0.5870 * double(tmp(ys:ye,xs:xe,2)) + 0.114 * double(tmp(ys:ye,xs:xe,3));
    else
        tmp = double(tmp(ys:ye,xs:xe));
    end;
    
    
    eval(['I_' num2str(kk) '= tmp;']);
    
    if kk == 0,
        Imin = tmp;
        Imax = tmp;
    else
        Imin = min(Imin,tmp);
        Imax = max(Imax,tmp);
    end;
    
end;   


% Substract opposite images (to compute a zero crossing):
for kk = 0:period-1,
    
    eval(['I_kk = I_' num2str(kk) ';']);
    eval(['I_kk2 = I_' num2str(mod(kk+period/2,period)) ';']);
    
    eval(['J_' num2str(kk) ' = I_kk - I_kk2;']);
    
end;


% Start computing the edge points:

not_computed = ones(yPixels,xPixels);
xp_crossings = -ones(yPixels,xPixels);


for kk = 1:period,
    
    eval(['Ja = J_' num2str(mod(kk-3,period)) ';']);
    eval(['Jb = J_' num2str(mod(kk-2,period)) ';']);
    eval(['Jc = J_' num2str(mod(kk-1,period)) ';']);
    eval(['Jd = J_' num2str(mod(kk,period)) ';']);
    eval(['Je = J_' num2str(mod(kk+1,period)) ';']);
    eval(['Jf = J_' num2str(mod(kk+2,period)) ';']);
    
    % Temporal Smoothing: (before zero crossing computation)
    J_current = (Jb + 4*Jc + 6*Jd + 4*Je + Jf)/16;
    J_prev = (Ja + 4*Jb + 6*Jc + 4*Jd + Je)/16;
    
    ind_found = find( (J_current >= 0) & (J_prev < 0) & (not_computed) );
    
    J_current = J_current(ind_found);
    J_prev = J_prev(ind_found);
    
    xp_crossings(ind_found) = (kk - (J_current ./ (J_current - J_prev))) - 0.5;
    
    not_computed(ind_found) = zeros(length(ind_found),1);
    
end;

% Final temporal solution:
xp_crossings = mod(xp_crossings,period);

if graphout,
    figure(3);
    image(xp_crossings*8);
    colormap(gray(256));
    title('STEP1: Subpixel projector coordinate with a 32 pixel ambiguity');
    drawnow;
end;


%--------------------------------------------------------------------------
%-- STEP 2: SPATIAL PROCESSING -> Coarse to fine processing to resolve ambiguity
%--------------------------------------------------------------------------

bin_current = zeros(yPixels,xPixels);

num_period = zeros(yPixels,xPixels);

for i = 1:N-log2(period),
    
    
    tmpN = imread([fname '_pat' sprintf('%.2d',i) 'p.bmp']);
    tmpI = imread([fname '_pat' sprintf('%.2d',i) 'n.bmp']); 
    
    if size(tmpN,3) > 1,
        tmpN = 0.299 * double(tmpN(ys:ye,xs:xe,1)) + 0.5870 * double(tmpN(ys:ye,xs:xe,2)) + 0.114 * double(tmpN(ys:ye,xs:xe,3));
        tmpI = 0.299 * double(tmpI(ys:ye,xs:xe,1)) + 0.5870 * double(tmpI(ys:ye,xs:xe,2)) + 0.114 * double(tmpI(ys:ye,xs:xe,3));
    else
        tmpN = double(tmpN(ys:ye,xs:xe));
        tmpI = double(tmpI(ys:ye,xs:xe));
    end;
    
    diffI = (tmpN-tmpI)>0;
    
    bin_current = xor(bin_current,diffI);
    
    num_period = num_period + (2^(N-i))*bin_current;
    
end;


if graphout,
    figure(4);
    image(num_period/4);
    colormap(gray(256));
    title('STEP2: Period number (for removing the periodic ambiguity)');
    drawnow;
end;


% Finish off the spatial processing to higher resolution:

xp_spatial = num_period;

finer_image = 2;

for i = N-log2(period)+1:N-finer_image+1,
    
    
    tmpN = imread([fname '_pat' sprintf('%.2d',i) 'p.bmp']);
    tmpI = imread([fname '_pat' sprintf('%.2d',i) 'n.bmp']); 
    
    if size(tmpN,3) > 1,
        tmpN = 0.299 * double(tmpN(ys:ye,xs:xe,1)) + 0.5870 * double(tmpN(ys:ye,xs:xe,2)) + 0.114 * double(tmpN(ys:ye,xs:xe,3));
        tmpI = 0.299 * double(tmpI(ys:ye,xs:xe,1)) + 0.5870 * double(tmpI(ys:ye,xs:xe,2)) + 0.114 * double(tmpI(ys:ye,xs:xe,3));
    else
        tmpN = double(tmpN(ys:ye,xs:xe));
        tmpI = double(tmpI(ys:ye,xs:xe));
    end;
    
    diffI = (tmpN-tmpI)>0;
    
    bin_current = xor(bin_current,diffI);
    
    xp_spatial = xp_spatial + (2^(N-i))*bin_current;
    
end;


% Final spatial solution:
xp_spatial = xp_spatial + (2^(finer_image-1)-1);




%--------------------------------------------------------------------------
%-- STEP 3: Solve for periodic ambiguity, and fixing gliches of the temporal processing (due to noise)
% In order to compare  xp_spatial and  xp_crossings; Not discussed in class
%--------------------------------------------------------------------------


% Fix glitches at the stripe boundaries (of width 4 pixels):

for kkk = 1:10,
    pos_cand = ((num_period == ([1e10*ones(yPixels,1) num_period(:,1:end-1)]+period)) | (num_period == ([1e10*ones(yPixels,2) num_period(:,1:end-2)]+period)))&(xp_crossings > 5*period /6);
    neg_cand = ((num_period == ([num_period(:,2:end) zeros(yPixels,1)]-period)) | (num_period == ([num_period(:,3:end) zeros(yPixels,2)]-period)))&(xp_crossings < period /6);
    num_period = num_period - period*pos_cand + period*neg_cand;
end;

xp_crossings2 = xp_crossings + num_period;

period3 = period / 2;

% Fix the little glitch at the stripe boundaries:

% Find single glitches:

for kkk = 1:5,
    delta_x =  xp_crossings2(:,2:end)-xp_crossings2(:,1:end-1);
    
    pos_glitch = (delta_x > 3*period3/4)&(delta_x < 3*period3);
    neg_glitch = (delta_x < -period3/4)&(delta_x > -3*period3);
    no_glitch = ~pos_glitch & ~neg_glitch;
    
    % Place to subtract a period:
    sub_places = [ (neg_glitch & [zeros(yPixels,1) pos_glitch(:,1:end-1)]) zeros(yPixels,1)] ;
    add_places = [ (pos_glitch & [zeros(yPixels,1) neg_glitch(:,1:end-1)]) zeros(yPixels,1)] ;
    
    xp_crossings3 = xp_crossings2 - period3 * sub_places + period3 * add_places;
    
    xp_crossings2 = xp_crossings3;
    
end;

% Find double glitches:

for kkk = 1:5,
    delta_x =  xp_crossings2(:,2:end)-xp_crossings2(:,1:end-1);
    pos_glitch = (delta_x > 3*period3/4)&(delta_x < 3*period3);
    neg_glitch = (delta_x < -period3/4)&(delta_x > -3*period3);
    no_glitch = ~pos_glitch & ~neg_glitch;
    
    sub2_places = [((no_glitch)& [zeros(yPixels,1) pos_glitch(:,1:end-1)] & [neg_glitch(:,2:end) zeros(yPixels,1)])|(neg_glitch & [zeros(yPixels,1) no_glitch(:,1:end-1)] & [zeros(yPixels,2) pos_glitch(:,1:end-2)]) zeros(yPixels,1)];
    add2_places = [((no_glitch)& [zeros(yPixels,1) neg_glitch(:,1:end-1)] & [pos_glitch(:,2:end) zeros(yPixels,1)])|(pos_glitch & [zeros(yPixels,1) no_glitch(:,1:end-1)] & [zeros(yPixels,2) neg_glitch(:,1:end-2)]) zeros(yPixels,1)];
    
    xp_crossings3 = xp_crossings2 - period3 * sub2_places + period3 * add2_places;
    
    xp_crossings2 = xp_crossings3;
end;


% End fix


if graphout,
    figure(5);
    image(xp_crossings2/4);
    colormap(gray(256));
    title('STEP3: Subpixel projector coordinate without the 32 pixel ambiguity');
    drawnow;
end;


%--------------------------------------------------------------------------
%-- STEP 4: Compare xp_spatial and xp_crossings2 and retains the
% xp_crossings that are valid
%--------------------------------------------------------------------------

%comparison of spatial and temporal xp for rejecting the bad pixels:
err_xp = xp_spatial - xp_crossings2;

spatial_temporal_agree = (err_xp <= 2^(finer_image-1)) & (err_xp > -1);

mask_temporal = zeros(yPixels,xPixels);
mask_temporal(2:(yPixels-1),2:(xPixels-1)) = ones(yPixels-2,xPixels-2);

if hightlight_reject,
    highlight = (whiteIm > 254);
    mask_good = (totContr > cthresh) & (not_computed >= 0) & mask_temporal & spatial_temporal_agree & ~highlight;
else
    mask_good = (totContr > cthresh) & (not_computed >= 0) & mask_temporal & spatial_temporal_agree;
end;

good1 = find(mask_good);


xp_crossings3 = xp_crossings2;

xp_crossings3(~mask_good) = NaN;


if graphout,
    figure(6);
    image(xp_crossings3/4);
    colormap(gray(256));
    title('STEP4: Final clean subpixel projector coordinates');
    drawnow;
end;


%--------------------------------------------------------------------------
%-- STEP 5: Produce the camera coordinates and the projector coordinates xc, xp
%--------------------------------------------------------------------------

% extract the good pixels only:
xp = xp_crossings2(good1)';

[X,Y] = meshgrid(0:xPixels-1,0:yPixels-1);

xc = [X(good1)';Y(good1)'];

%%% Express the coordinates of the points in the original
%%% image coordinates:

xc(1,:) = xc(1,:) + xs - 1;
xc(2,:) = xc(2,:) + ys - 1;

