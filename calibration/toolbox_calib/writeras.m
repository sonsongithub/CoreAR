function writeras(filename, image, map);
%WRITERAS Write an image file in sun raster format.
% 	  WRITERAS('imagefile.ras', image_matrix, map) writes a 
%	  "sun.raster" image file.

%	  Written by Thomas K. Leung 3/30/93.
%	  @ California Institute of Technology.


% PC and UNIX version of writeras - Jean-Yves Bouguet - Dec. 1998

dot = max(find(filename == '.'));
suffix = filename(dot+1:dot+3);

if nargin < 3,
   map = [];
end;

if(strcmp(suffix, 'ras'))
	%Write header

	fp = fopen(filename, 'wb');
	if(fp < 0) error(['Cannot open ' filename '.']), end

	[height, width] = size(image);
	image = image - 1;
	mapsize = size(map, 1)*size(map,2);
	%fwrite(fp, ...
	%       [1504078485, width, height, 8, height*width, 1, 1, mapsize], ...
   %       'long');
   
   
   zero_str = '00000000';
   
   % MAGIC NUMBER:
   

	fwrite(fp,89,'uchar');
   fwrite(fp,166,'uchar');
   fwrite(fp,106,'uchar');
   fwrite(fp,149,'uchar');

   width_str = dec2hex(width);
	width_str = [zero_str(1:8-length(width_str)) width_str];
   
   for ii = 1:2:7,
   	fwrite(fp,hex2dec(width_str(ii:ii+1)),'uchar');
	end;
   
   
   height_str = dec2hex(height);
	height_str = [zero_str(1:8-length(height_str)) height_str];
   
   for ii = 1:2:7,
   	fwrite(fp,hex2dec(height_str(ii:ii+1)),'uchar');
   end;
   
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,8,'uchar');
   
   ll = height*width;
   ll_str = dec2hex(ll);
   ll_str = [zero_str(1:8-length(ll_str)) ll_str];
   
   for ii = 1:2:7,
   	fwrite(fp,hex2dec(ll_str(ii:ii+1)),'uchar');
	end;
  
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,1,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,0,'uchar');
   fwrite(fp,~~mapsize,'uchar');

   mapsize_str = dec2hex(mapsize);
   mapsize_str = [zero_str(1:8-length(mapsize_str)) mapsize_str];
   
   %keyboard;
   
   for ii = 1:2:7,
   	fwrite(fp,hex2dec(mapsize_str(ii:ii+1)),'uchar');
	end;
 
   
	if mapsize ~= 0
		map = min(255, fix(255*map));
		fwrite(fp, map, 'uchar');
	end
	if rem(width,2) == 1
		image = [image'; zeros(1, height)]';
		top = 255 * ones(size(image));
		fwrite(fp, min(top,image)', 'uchar');
	else
		top = 255 * ones(size(image));
		fwrite(fp, min(top,image)', 'uchar');
	end
	fclose(fp);
else
	error('Image file name must end in either ''ras'' or ''rast''.');
end
