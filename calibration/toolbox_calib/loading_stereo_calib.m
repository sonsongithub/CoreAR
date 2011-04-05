if exist('Calib_Results_stereo.mat')~=2,
    fprintf(1,'\nStereo calibration file Calib_Results_stereo.mat not found!\n');
    return;
end;

fprintf(1,'Loading stereo calibration results from Calib_Results_stereo.mat...\n');
load('Calib_Results_stereo.mat');
