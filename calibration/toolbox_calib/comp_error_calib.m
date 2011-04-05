%%%%%%%%%%%%%%%%%%%% RECOMPUTES THE REPROJECTION ERROR %%%%%%%%%%%%%%%%%%%%%%%%

check_active_images;

% Reproject the patterns on the images, and compute the pixel errors:

ex = []; % Global error vector
x = []; % Detected corners on the image plane
y = []; % Reprojected points

if ~exist('alpha_c'),
   alpha_c = 0;
end;

for kk = 1:n_ima,
   
   eval(['omckk = omc_' num2str(kk) ';']);
   eval(['Tckk = Tc_' num2str(kk) ';']);   
   
   if active_images(kk) & (~isnan(omckk(1,1))),
      
      %Rkk = rodrigues(omckk);
      
      eval(['y_' num2str(kk) '  = project_points2(X_' num2str(kk) ',omckk,Tckk,fc,cc,kc,alpha_c);']);
      
      eval(['ex_' num2str(kk) ' = x_' num2str(kk) ' - y_' num2str(kk) ';']);
      
      eval(['x_kk = x_' num2str(kk) ';']);
      
      eval(['ex = [ex ex_' num2str(kk) '];']);
      eval(['x = [x x_' num2str(kk) '];']);
      eval(['y = [y y_' num2str(kk) '];']);
      
   else
      
      %	eval(['y_' num2str(kk) '  = NaN*ones(2,1);']);

   
      % If inactivated image, the error does not make sense:
      eval(['ex_' num2str(kk) ' = NaN*ones(2,1);']);
      
   end;
   
end;

err_std = std(ex')';
