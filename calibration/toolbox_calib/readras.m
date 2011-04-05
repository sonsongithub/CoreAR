function [X, map] = readras(filename, ys, ye, xs, xe);
%READRAS Read an image file in sun raster format.
% 	 READRAS('imagefile.ras') reads a "sun.raster" image file.
%	 [X, map] = READRAS('imagefile.ras') returns both the image and a 
%	 color map, so that
%		[X, map] = readras('imagefile.ras');
%		image(X) 
%		colormap(map)
%               axis('equal')
%	 will display the result with the proper colors.
%	 NOTE: readras cannot deal with complicated color maps.  
%	       In fact, Matlab doesn't quite allow to work with colormaps
%	       with more than 64 entries.
%

%%
%%	 (C) Thomas K. Leung 3/30/93.
%%	 California Institute of Technology.
%%	 Modified by Andrea Mennucci to deal with color images
%%

% PC and UNIX version of readras - Jean-Yves Bouguet - Dec. 1998

dot = max(find(filename == '.'));
suffix = filename(dot+1:dot+3);

if(strcmp(lower(suffix), 'ras'))			% raster file format %
	fp = fopen(filename, 'rb');
	if(fp<0) error(['Cannot open ' filename '.']), end

	%Read and crack the 32-byte header
	fseek(fp, 4, -1);  

	width 	= 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	height 	= 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	depth  	= 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	length 	= 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	type   	= 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	maptype = 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	maplen  = 2^24 * fread(fp, 1, 'uchar') + 2^16 * fread(fp, 1, 'uchar') + 2^8 * fread(fp, 1, 'uchar') + fread(fp, 1, 'uchar');

	maplen = maplen / 3;

	if maptype == 2					% RMT_RAW
		map = fread(fp, [maplen, 3], 'uchar')/255;
%		if maplen<64, map=[map',zeros(3,64-maplen)]';maplen=64; end;
	elseif maptype == 1				% RMT_EQUAL_RGB
		map(:,1) = fread(fp, [maplen], 'uchar');
		map(:,2) = fread(fp, [maplen], 'uchar');
		map(:,3) = fread(fp, [maplen], 'uchar');
		%maxmap = max(max(map));
		map = map/255;
	        if maplen<64, map=[map',zeros(3,64-maplen)]'; maplen=64; end;
	else 						% RMT_NONE
		map = [];
	end
%	if maplen>64,
%            map=[map',zeros(3,256-maplen)]';
%	end;

	% Read the image

	if rem(width,2) == 1
		Xt = fread(fp, [width+1, height], 'uchar');
		X = Xt(1:width, :)';
	else
		Xt = fread(fp, [width, height], 'uchar');
		X = Xt';
	end
	X = X + 1;
	fclose(fp);
else
	error('Image file name must end in either ''ras'' or ''rast''.');
end


if nargin == 5

	X = X(ys:ye, xs:xe);

end