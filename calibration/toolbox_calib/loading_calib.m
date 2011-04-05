if ~exist('Calib_Results.mat'),
   fprintf(1,'\nCalibration file Calib_Results.mat not found!\n');
   return;
end;

fprintf(1,'\nLoading calibration results from Calib_Results.mat\n');

load Calib_Results

fprintf(1,'done\n');
