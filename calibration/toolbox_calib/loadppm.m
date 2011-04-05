%LOADPPM	Load a PPM image
%
%	I = loadppm(filename)
%
%	Returns a matrix containing the image loaded from the PPM format
%	file filename.  Handles ASCII (P3) and binary (P6) PPM file formats.
%
%	If the filename has no extension, and open fails, a '.ppm' and
%	'.pnm' extension will be tried.
%
% SEE ALSO:	saveppm loadpgm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994

function I = loadppm(file)
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	fid = fopen(file, 'r');
	if fid < 0,
		fid = fopen([file '.ppm'], 'r');
	end
	if fid < 0,
		fid = fopen([file '.pnm'], 'r');
	end
	if fid < 0,
		error('Couldn''t open file');
	end
		
	magic = fread(fid, 2, 'char');
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	cols = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	rows = fscanf(fid, '%d', 1);
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
   maxval = fscanf(fid, '%d', 1);
   
   % assume a carriage return only:
   
   c = fread(fid,1,'char');
   
   % bug: because the image might be starting with special characters!
   %while 1
	%	c = fread(fid,1,'char');
	%	if c == '#',
	%		fgetl(fid);
	%	elseif ~any(c == white)
	%		fseek(fid, -1, 'cof');	% unputc()
	%		break;
	%	end
	%end
	if magic(1) == 'P',
		if magic(2) == '3',
			%disp(['ASCII PPM file ' num2str(rows) ' x ' num2str(cols)])
			I = fscanf(fid, '%d', [cols*3 rows]);
		elseif magic(2) == '6',
			%disp(['Binary PPM file ' num2str(rows) ' x ' num2str(cols)])
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols*3 rows], fmt);
		else
			disp('Not a PPM file');
		end
	end
	%
	% now the matrix has interleaved columns of R, G, B
	%
	I = I';
	size(I);
	R = I(:,1:3:(cols*3));
	G = I(:,2:3:(cols*3));
	B = I(:,3:3:(cols*3));
	fclose(fid);
   
   
   I = zeros(rows,cols,3);
   I(:,:,1) = R;
   I(:,:,2) = G;
   I(:,:,3) = B;
   I = uint8(I);
   