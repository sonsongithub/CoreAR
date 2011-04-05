% Function that clears all the wintx_i and winty_i
% In normal operation of the toolbox, this function should not be
% useful.
% only in cases where you want to re-extract corners using the Extract grid corners another time... not common. You might as well use the Recomp. corners.

if exist('n_ima','var')~=1
    return;
end;

for kk = 1:n_ima,
   
   eval(['clear wintx_' num2str(kk) ' winty_' num2str(kk)]);
   
end;
