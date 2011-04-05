
%%% Extraction of the final intrinsic and extrinsic paramaters:


fc = solution(1:2);
kc = solution(3:6);
cc = solution(6*n_ima + 4 +3:6*n_ima + 5 +3);

% Calibration matrix:
	
KK = [fc(1) 0 cc(1);0 fc(2) cc(2); 0 0 1];
inv_KK = inv(KK);	

% Extract the extrinsic paramters, and recomputer the collineations

for kk = 1:n_ima,
   
   omckk = solution(4+6*(kk-1) + 3:6*kk + 3);
   
   Tckk = solution(6*kk+1 + 3:6*kk+3 + 3);
   
   Rckk = rodrigues(omckk);
   
   Hlkk = KK * [Rckk(:,1) Rckk(:,2) Tckk];
   
   Hlkk = Hlkk / Hlkk(3,3);
   
   eval(['omc_' num2str(kk) ' = omckk;']);
   eval(['Rc_' num2str(kk) ' = Rckk;']);
	eval(['Tc_' num2str(kk) ' = Tckk;']);
   
   eval(['Hl_' num2str(kk) '=Hlkk;']);
   
end;


