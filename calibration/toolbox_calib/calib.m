function calib(mode),

% calib(mode)
%
% Runs the Camera Calibration Toolbox.
% Set mode to 1 to run the memory efficient version.
% Any other value for mode will run the normal version (see documentation)


if nargin < 1,
    
    calib_gui;
    
else

    calib_gui(mode);

end;