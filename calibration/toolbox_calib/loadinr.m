%LOADINR	Load an INRIMAGE format file
%
%	LOADINR(filename, im)
%
%	Load an INRIA image format file and return it as a matrix
%
% SEE ALSO:	saveinr
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1996

function im = loadinr(fname, im)

	fid = fopen(fname, 'r');

	s = fgets(fid);
	if strcmp(s(1:12), '#INRIMAGE-4#') == 0,
		error('not INRIMAGE format');
	end

	% not very complete, only looks for the X/YDIM keys
	while 1,
		s = fgets(fid);
		n = length(s) - 1;
		if s(1) == '#',
			break
		end
		if strcmp(s(1:5), 'XDIM='),
			cols = str2num(s(6:n));
		end
		if strcmp(s(1:5), 'YDIM='),
			rows = str2num(s(6:n));
		end
		if strcmp(s(1:4), 'CPU='),
			if strcmp(s(5:n), 'sun') == 0,
				error('not sun data ordering');
			end
		end
		
	end
	disp(['INRIMAGE format file ' num2str(rows) ' x ' num2str(cols)])

	% now the binary data
	fseek(fid, 256, 'bof');
	[im count] = fread(fid, [cols rows], 'float32');
	im = im';
	if count ~= (rows*cols),
		error('file too short');
	end
	fclose(fid);
