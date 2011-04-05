%SAVEINR	Write an INRIMAGE format file
%
%	SAVEINR(filename, im)
%
%	Saves the specified image array in a INRIA image format file.
%
% SEE ALSO:	loadinr
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab

% Peter Corke 1996

function saveinr(fname, im)

	fid = fopen(fname, 'w');
	[r,c] = size(im');

	% build the header
	hdr = [];
	s = sprintf('#INRIMAGE-4#{\n');
	hdr = [hdr s];
	s = sprintf('XDIM=%d\n',c);
	hdr = [hdr s];
	s = sprintf('YDIM=%d\n',r);
	hdr = [hdr s];
	s = sprintf('ZDIM=1\n');
	hdr = [hdr s];
	s = sprintf('VDIM=1\n');
	hdr = [hdr s];
	s = sprintf('TYPE=float\n');
	hdr = [hdr s];
	s = sprintf('PIXSIZE=32\n');
	hdr = [hdr s];
	s = sprintf('SCALE=2**0\n');
	hdr = [hdr s];
	s = sprintf('CPU=sun\n#');
	hdr = [hdr s];

	% make it 256 bytes long and write it
	hdr256 = zeros(1,256);
	hdr256(1:length(hdr)) = hdr;
	fwrite(fid, hdr256, 'uchar');

	% now the binary data
	fwrite(fid, im', 'float32');
	fclose(fid)
