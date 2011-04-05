%%% Program that launchs the complete 

for N_ima_active = 1:30,
   
   error_analysis;
   
end;



return;


f = [];
f_std = [];

c = [];
c_std = [];

k = [];
k_std = [];

NN = 30;

for rr = 1:NN,
   
   load(['Calib_Accuracies_' num2str(rr)]);
   
   [m1,s1] = mean_std_robust(fc_list(1,:));
   [m2,s2] = mean_std_robust(fc_list(2,:));
   
   f = [f [m1;m2]];
   f_std = [f_std [s1;s2]];
   
   [m1,s1] = mean_std_robust(cc_list(1,:));
   [m2,s2] = mean_std_robust(cc_list(2,:));
   
   c = [c [m1;m2]];
   c_std = [c_std [s1;s2]];
      
   [m1,s1] = mean_std_robust(kc_list(1,:));
   [m2,s2] = mean_std_robust(kc_list(2,:));
   [m3,s3] = mean_std_robust(kc_list(3,:));
   [m4,s4] = mean_std_robust(kc_list(4,:));
   
   k = [k [m1;m2;m3;m4]];
   k_std = [k_std [s1;s2;s3;s4]];
   
end;

figure(1);
errorbar([1:NN;1:NN]',f',f_std');
figure(2);
errorbar([1:NN;1:NN]',c',c_std');
figure(3);
errorbar([1:NN;1:NN;1:NN;1:NN]',k',k_std');

figure(4);
semilogy(f_std');

figure(5);
semilogy(c_std');

figure(6);
semilogy(k_std');
