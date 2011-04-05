
      satis_distort = 0;
      
      while ~satis_distort,

          k_g_save = k_g;
          
	 k_g = input(['Guess for distortion factor kc ([]=' num2str(k_g_save) '): ']);
	 
	 if isempty(k_g), k_g = k_g_save; end;

    
x_n = (x - c_g(1))/f_g;
y_n = (y - c_g(2))/f_g;

[x_pn] = comp_fisheye_distortion([x_n' ; y_n'],[k_g;0;0;0]);


% Compute the inside points through computation of the planar homography (collineation)

a00 = [x_pn(1,1);x_pn(2,1);1];
a10 = [x_pn(1,2);x_pn(2,2);1];
a11 = [x_pn(1,3);x_pn(2,3);1];
a01 = [x_pn(1,4);x_pn(2,4);1];

% Compute the planar collineation: (return the normalization matrix as well)
[Homo,Hnorm,inv_Hnorm] = compute_homography([a00 a10 a11 a01],[0 1 1 0;0 0 1 1;1 1 1 1]);


% Build the grid using the planar collineation:

x_l = ((0:n_sq_x)'*ones(1,n_sq_y+1))/n_sq_x;
y_l = (ones(n_sq_x+1,1)*(0:n_sq_y))/n_sq_y;
pts = [x_l(:) y_l(:) ones((n_sq_x+1)*(n_sq_y+1),1)]';

XXpn = Homo*pts;
XXpn = XXpn(1:2,:) ./ (ones(2,1)*XXpn(3,:));

XX = apply_fisheye_distortion(XXpn,[k_g;0;0;0]);

XX(1,:) = f_g*XX(1,:) + c_g(1);
XX(2,:) = f_g*XX(2,:) + c_g(2);

     
     
     
     
     
	 
	 figure(2);
	 image(I);
	 colormap(map);
	 zoom on;
	 hold on;
	 plot(XX(1,:),XX(2,:),'r+');
	 title('The red crosses should be on the grid corners...');
	 hold off;
	 
	 satis_distort = input('Satisfied with distortion? ([]=no, other=yes) ');
	 
	 satis_distort = ~isempty(satis_distort);
	 
	 
      end;
      