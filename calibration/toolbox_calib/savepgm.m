%SAVEPGM	Write a PGM format file
%
%	SAVEPGM(filename, im)
%
%	Saves the specified image array in a binary (P5) format PGM image file.
% 
% SEE ALSO:	loadpgm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994

function savepgm(fname, im)

	fid = fopen(fname, 'w');
	[r,c] = size(im');
	fprintf(fid, 'P5\n');
	fprintf(fid, '%d %d\n', r, c);
	fprintf(fid, '255\n');
	fwrite(fid, im', 'uchar');
	fclose(fid);
