%SAVEPPM	Write a PPM format file
%
%	SAVEPPM(filename, I)
%
%	Saves the specified red, green and blue planes in a binary (P6)
%	format PPM image file.
%
% SEE ALSO:	loadppm
%
%	Copyright (c) Peter Corke, 1999  Machine Vision Toolbox for Matlab


% Peter Corke 1994

function saveppm(fname, I)

I = double(I);

if size(I,3) == 1,
   R = I;
   G = I;
   B = I;
else
   R = I(:,:,1);
   G = I(:,:,2);
   B = I(:,:,3);
end;

%keyboard;

	fid = fopen(fname, 'w');
	[r,c] = size(R');
	fprintf(fid, 'P6\n');
	fprintf(fid, '%d %d\n', r, c);
   fprintf(fid, '255\n');
   R = R';
   G = G';
   B = B';
	im = [R(:) G(:) B(:)];
   %im = reshape(im,r,c*3);
   im = im';
   %im = im(:);
   fwrite(fid, im, 'uchar');
   fclose(fid);
   
