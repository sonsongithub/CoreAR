
      satis_distort = 0;
      
      disp(['Estimated focal: ' num2str(f_g) ' pixels']);
      
      while ~satis_distort,

	 k_g = input('Guess for distortion factor kc ([]=0): ');
	 
	 if isempty(k_g), k_g = 0; end;
      
	 xy_corners_undist = comp_distortion2([x' - c_g(1);y'-c_g(2)]/f_g,k_g);
	 
	 xu = xy_corners_undist(1,:)';
	 yu = xy_corners_undist(2,:)';
	 
	 [XXu] = projectedGrid ( [xu(1);yu(1)], [xu(2);yu(2)],[xu(3);yu(3)], [xu(4);yu(4)],n_sq_x+1,n_sq_y+1); % The full grid
	 
	 XX = (ones(2,1)*(1 + k_g * sum(XXu.^2))) .* XXu;
	 XX(1,:) = f_g*XX(1,:)+c_g(1);
	 XX(2,:) = f_g*XX(2,:)+c_g(2);
	 
	 figure(2);
	 image(I);
	 colormap(map);
	 zoom on;
	 hold on;
	 %plot(f_g*XXu(1,:)+c_g(1),f_g*XXu(2,:)+c_g(2),'ro');
	 plot(XX(1,:),XX(2,:),'r+');
	 title('The red crosses should be on the grid corners...');
	 hold off;
	 
	 satis_distort = input('Satisfied with distortion? ([]=no, other=yes) ');
	 
	 satis_distort = ~isempty(satis_distort);
	 
	 
      end;
      