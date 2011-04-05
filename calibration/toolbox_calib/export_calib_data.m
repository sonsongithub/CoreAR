%% Export calibration data (corners + 3D coordinates) to
%% text files (in Willson-Heikkila's format or Zhang's format)

%% Thanks to Michael Goesele (from the Max-Planck-Institut) for the original suggestion
%% of adding this export function to the toolbox.


if ~exist('n_ima'),
   fprintf(1,'ERROR: No calibration data to export\n');
   
else

    if n_ima == 0,
        fprintf(1,'ERROR: No calibration data to export\n');
        return;
    end;
    
	check_active_images;

	check_extracted_images;

	check_active_images;
   
   fprintf(1,'Tool that exports calibration data to Willson-Heikkila or Zhang formats\n');
   
   qformat = -1;
   
   while (qformat ~=0)&(qformat ~=1),
      
      fprintf(1,'Two possible formats of export: 0=Willson and Heikkila, 1=Zhang\n')
      qformat = input('Format of export (enter 0 or 1): ');
      
      if isempty(qformat)
         qformat = -1;
      end;
      
      if (qformat ~=0)&(qformat ~=1),
         
         fprintf(1,'Invalid entry. Try again.\n')
         
      end;
      
   end;
   
   if qformat == 0,
      
		fprintf(1,'\nExport of calibration data to text files (Willson and Heikkila''s format)\n');
		outputfile = input('File basename: ','s');
	
		for kk = ind_active,
   	
   		eval(['X_kk = X_' num2str(kk) ';']);
      	eval(['x_kk = x_' num2str(kk) ';']);
         
         Xx = [X_kk ; x_kk]';
         
			file_name = [outputfile num2str(kk)];
	
			disp(['Exporting calibration data (3D world + 2D image coordinates) of image ' num2str(kk) ' to file ' file_name '...']);
         
         eval(['save ' file_name ' Xx -ASCII']);
      
   	end;
      
   else
      
      fprintf(1,'\nExport of calibration data to text files (Zhang''s format)\n');
      modelfile = input('File basename for the 3D world coordinates: ','s');
      datafile = input('File basename for the 2D image coordinates: ','s');
      
      for kk = ind_active,
         
   		eval(['X_kk = X_' num2str(kk) ';']);
         eval(['x_kk = x_' num2str(kk) ';']);
         
         if ~exist(['n_sq_x_' num2str(kk)]),
            n_sq_x = 1;
            n_sq_y = size(X_kk,2);
         else
            eval(['n_sq_x = n_sq_x_' num2str(kk) ';']);
         	eval(['n_sq_y = n_sq_y_' num2str(kk) ';']);
         end;
         
 	      X = reshape(X_kk(1,:)',n_sq_x+1,n_sq_y+1)';
 	      Y = reshape(X_kk(2,:)',n_sq_x+1,n_sq_y+1)';
         XY = reshape([X;Y],n_sq_y+1,2*(n_sq_x+1));
          
         x = reshape(x_kk(1,:)',n_sq_x+1,n_sq_y+1)';
 	      y = reshape(x_kk(2,:)',n_sq_x+1,n_sq_y+1)';
         xy = reshape([x;y],n_sq_y+1,2*(n_sq_x+1));
         
         disp(['Exporting calibration data of image ' num2str(kk) ' to files ' modelfile num2str(kk) '.txt and ' datafile num2str(kk) '.txt...']);

         eval(['save ' modelfile num2str(kk) '.txt XY -ASCII']);
         eval(['save ' datafile num2str(kk) '.txt xy -ASCII']);
               
   	end;

      
end;

fprintf(1,'done\n');
   
end;
