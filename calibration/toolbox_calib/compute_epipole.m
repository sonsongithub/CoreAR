function [epipole] = compute_epipole(xLp,R,T,fc_right,cc_right,kc_right,alpha_c_right,fc_left,cc_left,kc_left,alpha_c_left,D);

if ~exist('D'),
    D = 400;
end;

uo = [ normalize_pixel(xLp,fc_left,cc_left,kc_left,alpha_c_left); 1 ];

S = [   0  -T(3)  T(2)
    T(3)   0   -T(1)
    -T(2)  T(1)   0 ];

l_epipole = (S*R)*uo;

KK_right = [fc_right(1) alpha_c_right * fc_right(1) cc_right(1) ; 0 fc_right(2) cc_right(2) ; 0 0 1];

N_line = 800;

if norm(l_epipole(2)) > norm(l_epipole(1)),
    
    % Horizontal line:
    
    limit_x_pos = ((xLp(1) + D/2) - cc_right(1)) / fc_right(1);
    limit_x_neg = ((xLp(1) - D/2) - cc_right(1)) / fc_right(1);
    
    
    %limit_x_pos = ((nx-1) - cc_right(1)) / fc_right(1);
    %limit_x_neg = (0 - cc_right(1)) / fc_right(1);
    
    x_list = (limit_x_pos - limit_x_neg) * ((0:(N_line-1)) / (N_line-1)) + limit_x_neg;
    
    
    pt = cross(repmat(l_epipole,1,N_line),[ones(1,N_line);zeros(1,N_line);-x_list]);
    
    
else
    
    limit_y_pos = ((xLp(2) + D/2) - cc_right(2)) / fc_right(2);
    limit_y_neg = ((xLp(2) - D/2) - cc_right(2)) / fc_right(2);
    
    %limit_y_pos = ((ny-1) - cc_right(2)) / fc_right(2);
    %limit_y_neg = (0 - cc_right(2)) / fc_right(2);
    
    y_list = (limit_y_pos - limit_y_neg) * ((0:(N_line-1)) / (N_line-1)) + limit_y_neg;
    
    
    pt = cross(repmat(l_epipole,1,N_line),[zeros(1,N_line);ones(1,N_line);-y_list]);
    
    
end;


pt = [pt(1,:) ./ pt(3,:) ; pt(2,:)./pt(3,:)];
ptd = apply_distortion(pt,kc_right);
epipole = KK_right * [ ptd ; ones(1,N_line)];

epipole = epipole(1:2,:);