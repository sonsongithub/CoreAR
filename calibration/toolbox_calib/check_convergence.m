%%% Replay the set of solution vectors:


if ~exist('param_list'),
   if ~exist('solution');
      fprintf(1,'Error: Need to calibrate first\n');
      return;
   else
      param_list = solution;
   end;
end;

N_iter = size(param_list,2);

if N_iter == 1, 
   fprintf(1,'Warning: There is a unique state in the list of parameters.\n');
end;



%M = moviein(N_iter);

for nn = 1:N_iter,
   
   solution = param_list(:,nn);
   
   extract_parameters;
   comp_error_calib;
   
   ext_calib;
   
   drawnow;
   
%   Mnn = getframe(gcf);
   
%   M(:,nn) = Mnn;
   
end;

%fig = gcf;


%figure(fig+1);
%close;
%figure(fig+1);

%clf;
%movie(M,20);
