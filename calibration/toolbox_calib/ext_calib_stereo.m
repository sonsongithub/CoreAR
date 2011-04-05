
%%%%%%%%%%%%%%%%%%%% SHOW EXTRINSIC RESULTS %%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('n_ima')|~exist('fc_right')|~exist('fc_left'),
   fprintf(1,'No stereo calibration data available.\n');
   return;
end;

ind_active = find(active_images);

no_grid = 0;

if ~exist(['n_sq_x_' num2str(ind_active(1))]),
   no_grid = 1;
end;

% Color code for each image:

colors = 'brgkcm';


%%% Show the extrinsic parameters

if ~exist('dX'),
   eval(['dX = norm(Tc_left_' num2str(ind_active(1)) ')/10;']);
   dY = dX;
end;

%normT = min(norm(T)/2,2*dX);
normT = 2*dX;


IP_left = normT *[1 -alpha_c_left 0;0 1 0;0 0 1]*[1/fc_left(1) 0 0;0 1/fc_left(2) 0;0 0 1]*[1 0 -cc_left(1);0 1 -cc_left(2);0 0 1]*[0 nx-1 nx-1 0 0 ; 0 0 ny-1 ny-1 0;1 1 1 1 1];
BASE_left = normT *([0 1 0 0 0 0;0 0 0 1 0 0;0 0 0 0 0 1]);
IP_left  = reshape([IP_left ;BASE_left(:,1)*ones(1,5);IP_left ],3,15);

IP_right = normT *[1 -alpha_c_right 0;0 1 0;0 0 1]*[1/fc_right(1) 0 0;0 1/fc_right(2) 0;0 0 1]*[1 0 -cc_right(1);0 1 -cc_right(2);0 0 1]*[0 nx-1 nx-1 0 0 ; 0 0 ny-1 ny-1 0;1 1 1 1 1];
IP_right = reshape([IP_right;BASE_left(:,1)*ones(1,5);IP_right],3,15);

% Relative position of right camera wrt left camera: (om,T)
R = rodrigues(om);


% Change of reference:
BASE_right = R'*(BASE_left - repmat(T,[1 6]));
IP_right = R'*(IP_right - repmat(T,[1 15]));


if ishandle(4),
	figure(4);
   [a,b] = view;
else
   figure(4);
   a = 50;
   b = 20;
end;

 
figure(4);
plot3(BASE_left(1,:),BASE_left(3,:),-BASE_left(2,:),'b-','linewidth',2');
hold on;
plot3(IP_left(1,:),IP_left(3,:),-IP_left(2,:),'r-','linewidth',2);
text(BASE_left(1,2),BASE_left(3,2),-BASE_left(2,2),'X','HorizontalAlignment','center','FontWeight','bold');
text(BASE_left(1,6),BASE_left(3,6),-BASE_left(2,6),'Z','HorizontalAlignment','center','FontWeight','bold');
text(BASE_left(1,4),BASE_left(3,4),-BASE_left(2,4),'Y','HorizontalAlignment','center','FontWeight','bold');
text(BASE_left(1,1),BASE_left(3,1),-BASE_left(2,1),'Left Camera','HorizontalAlignment','center','FontWeight','bold');
plot3(BASE_right(1,:),BASE_right(3,:),-BASE_right(2,:),'b-','linewidth',2');
plot3(IP_right(1,:),IP_right(3,:),-IP_right(2,:),'r-','linewidth',2);
text(BASE_right(1,2),BASE_right(3,2),-BASE_right(2,2),'X','HorizontalAlignment','center','FontWeight','bold');
text(BASE_right(1,6),BASE_right(3,6),-BASE_right(2,6),'Z','HorizontalAlignment','center','FontWeight','bold');
text(BASE_right(1,4),BASE_right(3,4),-BASE_right(2,4),'Y','HorizontalAlignment','center','FontWeight','bold');
text(BASE_right(1,1),BASE_right(3,1),-BASE_right(2,1),'Right Camera','HorizontalAlignment','center','FontWeight','bold');

for kk = 1:n_ima,
    
    if active_images(kk);
        
        if exist(['X_left_' num2str(kk)]) & exist(['omc_left_' num2str(kk)]),
            
            eval(['XX_kk = X_left_' num2str(kk) ';']);
            
            if ~isnan(XX_kk(1,1))
                
                eval(['omc_kk = omc_left_' num2str(kk) ';']);
                eval(['Tc_kk = Tc_left_' num2str(kk) ';']);
                N_kk = size(XX_kk,2);
                
                if ~exist(['n_sq_x_' num2str(kk)]),
                    no_grid = 1;
                else
                    eval(['n_sq_x = n_sq_x_' num2str(kk) ';']);
                    if isnan(n_sq_x(1)),
                        no_grid = 1;
                    end;  
                end;
                
                if ~no_grid,
                    eval(['n_sq_x = n_sq_x_' num2str(kk) ';']);
                    eval(['n_sq_y = n_sq_y_' num2str(kk) ';']);
                    if (N_kk ~= ((n_sq_x+1)*(n_sq_y+1))),
                        no_grid = 1;
                    end;
                end;
                
                if ~isnan(omc_kk(1,1)),
                    
                    R_kk = rodrigues(omc_kk);
                    
                    YY_kk = R_kk * XX_kk + Tc_kk * ones(1,length(XX_kk));
                    
                    uu = [-dX;-dY;0]/2;
                    uu = R_kk * uu + Tc_kk; 
                    
                    if ~no_grid,
                        YYx = zeros(n_sq_x+1,n_sq_y+1);
                        YYy = zeros(n_sq_x+1,n_sq_y+1);
                        YYz = zeros(n_sq_x+1,n_sq_y+1);
                        
                        YYx(:) = YY_kk(1,:);
                        YYy(:) = YY_kk(2,:);
                        YYz(:) = YY_kk(3,:);
                        
                        
                        figure(4);
                        hhh= mesh(YYx,YYz,-YYy);
                        set(hhh,'edgecolor',colors(rem(kk-1,6)+1),'linewidth',1); %,'facecolor','none');
                        text(uu(1),uu(3),-uu(2),num2str(kk),'fontsize',14,'color',colors(rem(kk-1,6)+1),'HorizontalAlignment','center');
                    else
                        
                        figure(4);
                        plot3(YY_kk(1,:),YY_kk(3,:),-YY_kk(2,:),['.' colors(rem(kk-1,6)+1)]);
                        text(uu(1),uu(3),-uu(2),num2str(kk),'fontsize',14,'color',colors(rem(kk-1,6)+1),'HorizontalAlignment','center');
                        
                    end;
                    
                end;
                
            end;
            
        end;
        
    end;
    
end;

figure(4);rotate3d on;
axis('equal');
title('Extrinsic parameters');
view(a,b);
grid on;
hold off;
axis vis3d;
axis tight;
set(4,'color',[1 1 1]);

set(4,'Name','3D','NumberTitle','off');


if exist('h_switch')==1,
    if ishandle(h_switch),
        delete(h_switch);
    end;
end;

if exist('h_switch2')==1,
    if ishandle(h_switch2),
        delete(h_switch2);
    end;
end;