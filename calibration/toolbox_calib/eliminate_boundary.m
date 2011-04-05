function Im2 = eliminate_boundary(Im);


[nny,nnx] = size(Im);

Im2 = zeros(nny,nnx);

Im2(2:end-1,2:end-1) = (Im(2:end-1,2:end-1) & Im(1:end-2,2:end-1) & Im(1:end-2,1:end-2) & Im(1:end-2,3:end) & ...
   Im(3:end,2:end-1) & Im(3:end,1:end-2) & Im(3:end,3:end) & Im(2:end-1,1:end-2) & Im(2:end-1,3:end));
