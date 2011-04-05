
set1 = load(data_set1); % part1\Calib_Results;
set2 = load(data_set2); % part2\Calib_Results;

shift = set1.n_ima;

for kk = 1:set1.n_ima

eval(['X_' num2str(kk) ' = set1.X_' num2str(kk) ';']);

eval(['dX_' num2str(kk) ' = set1.dX_' num2str(kk) ';']);
eval(['dY_' num2str(kk) ' = set1.dY_' num2str(kk) ';']);

eval(['wintx_' num2str(kk) ' = set1.wintx_' num2str(kk) ';']);
eval(['winty_' num2str(kk) ' = set1.winty_' num2str(kk) ';']);

eval(['x_' num2str(kk) ' = set1.x_' num2str(kk) ';']);

if isfield(set1,'y')
    eval(['y_' num2str(kk) ' = set1.y_' num2str(kk) ';']);
else
    eval(['y_' num2str(kk) ' = [NaN];']);
end;

eval(['n_sq_x_' num2str(kk) ' = set1.n_sq_x_' num2str(kk) ';']);
eval(['n_sq_y_' num2str(kk) ' = set1.n_sq_y_' num2str(kk) ';']);


if isfield(set1,['omc_' num2str(kk+shift)])
    eval(['omc_' num2str(kk+shift) ' = set1.omc_' num2str(kk) ';']);
    eval(['Tc_' num2str(kk+shift) ' = set1.Tc_' num2str(kk) ';']);
else
    eval(['omc_' num2str(kk+shift) ' = [NaN;NaN;NaN];']);
    eval(['Tc_' num2str(kk+shift) ' = [NaN;NaN;NaN];']);
end;

end;

for kk = 1:set2.n_ima

eval(['X_' num2str(kk+shift) ' = set2.X_' num2str(kk) ';']);

    
eval(['dX_' num2str(kk+shift) ' = set2.dX_' num2str(kk) ';']);
eval(['dY_' num2str(kk+shift) ' = set2.dY_' num2str(kk) ';']);

eval(['wintx_' num2str(kk+shift) ' = set2.wintx_' num2str(kk) ';']);
eval(['winty_' num2str(kk+shift) ' = set2.winty_' num2str(kk) ';']);

eval(['x_' num2str(kk+shift) ' = set2.x_' num2str(kk) ';']);

if isfield(set2,'y')
    eval(['y_' num2str(kk) ' = set2.y_' num2str(kk) ';']);
else
    eval(['y_' num2str(kk) ' = [NaN];']);
end;

eval(['n_sq_x_' num2str(kk+shift) ' = set2.n_sq_x_' num2str(kk) ';']);
eval(['n_sq_y_' num2str(kk+shift) ' = set2.n_sq_y_' num2str(kk) ';']);



if isfield(set2,['omc_' num2str(kk+shift)])
    eval(['omc_' num2str(kk+shift) ' = set2.omc_' num2str(kk) ';']);
    eval(['Tc_' num2str(kk+shift) ' = set2.Tc_' num2str(kk) ';']);
else
    eval(['omc_' num2str(kk+shift) ' = [NaN;NaN;NaN];']);
    eval(['Tc_' num2str(kk+shift) ' = [NaN;NaN;NaN];']);
end;

end;


fc = set2.fc;
kc = set2.kc;
cc = set2.cc;
alpha_c = set2.alpha_c;
KK = set2.KK;
inv_KK = set2.inv_KK;


n_ima = set1.n_ima + set2.n_ima;
active_images = [set1.active_images set2.active_images];

no_image = 1;
