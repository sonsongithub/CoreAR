%%% ERROR_ANALYSIS
%%% This simulation helps coputing the acturacies of calibration
%%% Run it after the main calibration



N_runs = 200;

%N_ima_active = 4;

saving = 1;

if 1, %~exist('fc_list'), % initialization
   
   % Initialization:
   
   load Calib_Results;
   check_active_images;
   
	fc_list = [];
	cc_list = [];
	kc_list = [];
   active_images_list = [];
   
   
	for kk=1:n_ima,
   	
   	eval(['omc_list_' num2str(kk) ' = [];']);
   	eval(['Tc_list_' num2str(kk) ' = [];']);
      
   end;
	
	%sx = median(abs(ex(1,:)))*1.4836;
	%sy = median(abs(ex(2,:)))*1.4836;
	
	sx = std(ex(1,:));
	sy = std(ex(2,:));
   
	% Saving the feature locations:

	for kk = 1:n_ima,
   	
   	eval(['x_save_' num2str(kk) ' = x_' num2str(kk) ';']);
   	eval(['y_save_' num2str(kk) ' = y_' num2str(kk) ';']);

	end;
   
   active_images_save = active_images;
   ind_active_save = ind_active;
   
   fc_save = fc;
   cc_save = cc;
   kc_save = kc;
   KK_save = KK;
   

end;




%%% The main loop:


for ntrial = 1:N_runs,
   
   fprintf(1,'\nRun number: %d\n',ntrial);
   fprintf(1,  '----------\n');
   
   for kk = 1:n_ima,
      
      eval(['y_kk = y_save_' num2str(kk) ';'])
      
      if active_images(kk) & ~isnan(y_kk(1,1)),
         
         Nkk = size(y_kk,2);
         
         x_kk_new = y_kk + [sx * randn(1,Nkk);sy*randn(1,Nkk)];
         
         eval(['x_' num2str(kk) ' = x_kk_new;']);
         
      end;
      
   end;
   
   N_active = length(ind_active_save);
   junk = randn(1,N_active);
   [junk,junk2] = sort(junk);
   
   active_images = zeros(1,n_ima);
   active_images(ind_active_save(junk2(1:N_ima_active))) = ones(1,N_ima_active);
   
   fc = fc_save;
   cc = cc_save;
   kc = kc_save;
   KK = KK_save;
   
   go_calib_optim;
   
   fc_list = [fc_list fc];
   cc_list = [cc_list cc];
   kc_list = [kc_list kc];
   active_images_list = [active_images_list active_images'];
   
   for kk=1:n_ima,
   
   	eval(['omc_list_' num2str(kk) ' = [ omc_list_' num2str(kk) ' omc_' num2str(kk) ' ];']);
   	eval(['Tc_list_' num2str(kk) ' = [ Tc_list_' num2str(kk) ' Tc_' num2str(kk) ' ];']);
   
	end;

end;




if 0,

% Restoring the feature locations:

for kk = 1:n_ima,
   
   eval(['x_' num2str(kk) ' = x_save_' num2str(kk) ';']);
   
end;

fprintf(1,'\nFinal run (with the real data)\n');
fprintf(1,  '------------------------------\n');

active_images = active_images_save;
ind_active = ind_active_save;

go_calib_optim;
   
fc_list = [fc_list fc];
cc_list = [cc_list cc];
kc_list = [kc_list kc];
active_images_list = [active_images_list active_images'];

for kk=1:n_ima,
   
   eval(['omc_list_' num2str(kk) ' = [ omc_list_' num2str(kk) ' omc_' num2str(kk) ' ];']);
   eval(['Tc_list_' num2str(kk) ' = [ Tc_list_' num2str(kk) ' Tc_' num2str(kk) ' ];']);
   
end;

end;





if saving,
   
disp(['Save Calibration accuracy results under Calib_Accuracies_' num2str(N_ima_active) '.mat']);

string_save = ['save Calib_Accuracies_' num2str(N_ima_active) ' active_images n_ima N_ima_active N_runs active_images_list fc cc kc fc_list cc_list kc_list'];

for kk = 1:n_ima,
   string_save = [string_save ' Tc_list_' num2str(kk) ' omc_list_' num2str(kk)  ' Tc_' num2str(kk) ' omc_' num2str(kk) ];
end;

eval(string_save);

end;


return;

std(fc_list')

std(cc_list')

std(kc_list')

for kk = 1:n_ima,
   
   eval(['std(Tc_list_'  num2str(kk) ''')'])
   
end;


