%LOADPGM	Load a PGM image
%
%	I = loadpgm(filename)
%
%	Returns a matrix containing the image loaded from the PGM format
%	file filename.  Handles ASCII (P2) and binary (P5) PGM file formats.
%
%	If the filename has no extension, and open fails, a '.pgm' will
%	be appended.
%
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994

function I = loadpgm(file)
	white = [' ' 9 10 13];	% space, tab, lf, cr
	white = setstr(white);

	fid = fopen(file, 'r');
	if fid < 0,
		fid = fopen([file '.pgm'], 'r');
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
	while 1
		c = fread(fid,1,'char');
		if c == '#',
			fgetl(fid);
		elseif ~any(c == white)
			fseek(fid, -1, 'cof');	% unputc()
			break;
		end
	end
	if magic(1) == 'P',
		if magic(2) == '2',
			%disp(['ASCII PGM file ' num2str(rows) ' x ' num2str(cols)])
			I = fscanf(fid, '%d', [cols rows])';
		elseif magic(2) == '5',
			%disp(['Binary PGM file ' num2str(rows) ' x ' num2str(cols)])
			if maxval == 1,
				fmt = 'unint1';
			elseif maxval == 15,
				fmt = 'uint4';
			elseif maxval == 255,
				fmt = 'uint8';
			elseif maxval == 2^32-1,
				fmt = 'uint32';
			end
			I = fread(fid, [cols rows], fmt)';
		else
			disp('Not a PGM file');
		end
	end
	fclose(fid);
