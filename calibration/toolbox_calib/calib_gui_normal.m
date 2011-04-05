%function calib_gui_normal,


cell_list = {};


%-------- Begin editable region -------------%
%-------- Begin editable region -------------%


fig_number = 1;

title_figure = 'Camera Calibration Toolbox - Standard Version';

clear fc cc kc KK
kc = zeros(5,1);
clearwin;

cell_list{1,1} = {'Image names','data_calib;'};
cell_list{1,2} = {'Read images','ima_read_calib;'};
cell_list{1,3} = {'Extract grid corners','click_calib;'};
cell_list{1,4} = {'Calibration','go_calib_optim;'};
cell_list{2,1} = {'Show Extrinsic','ext_calib;'};
cell_list{2,2} = {'Reproject on images','reproject_calib;'};
cell_list{2,3} = {'Analyse error','analyse_error;'};
cell_list{2,4} = {'Recomp. corners','recomp_corner_calib;'};
cell_list{3,1} = {'Add/Suppress images','add_suppress;'};
cell_list{3,2} = {'Save','saving_calib;'};
cell_list{3,3} = {'Load','loading_calib;'};
cell_list{3,4} = {'Exit',['disp(''Bye. To run again, type calib_gui.''); close(' num2str(fig_number) ');']}; %{'Exit','calib_gui;'};
cell_list{4,1} = {'Comp. Extrinsic','extrinsic_computation;'};
cell_list{4,2} = {'Undistort image','undistort_image;'};
cell_list{4,3} = {'Export calib data','export_calib_data;'};
cell_list{4,4} = {'Show calib results','show_calib_results;'};
%cell_list{5,1} = {'Smooth images','smooth_images;'};


show_window(cell_list,fig_number,title_figure,130,18,0,'clean',12);


%-------- End editable region -------------%
%-------- End editable region -------------%

