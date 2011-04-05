% Point Distribution

colors = 'brgkcm';

if ~exist('n_ima')|~exist('fc'),
   fprintf(1,'No calibration data available.\n');
   return;
end;

check_active_images;

if ~exist(['ex_' num2str(ind_active(1)) ]),
   fprintf(1,'Need to calibrate before analysing reprojection error. Maybe need to load Calib_Results.mat file.\n');
   return;
end;

figure(6);

for kk=1:n_ima

	if exist(['x_' num2str(kk)]),

	if active_images(kk) & eval(['~isnan(x_' num2str(kk) '(1,1))']),

		eval(['plot(x_' num2str(kk) '(1,:),x_' num2str(kk) '(2,:),''' colors(rem(kk-1,6)+1) '+'');']);
		
		hold on;
	end;
	
	end;

end;

axis('equal');

axis([0 nx 0 ny]);

title1=pwd;
title1=strrep(title1,'_','\_');

title({'Point Distribution in Images',title1});

xlabel('x');

ylabel('y');
