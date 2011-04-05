function [Xc3,tri3,xc3,xp3,dc3,xc_texture,nc3,conf_nc3,Nn3] = Meshing(Xc2,xc2,xp2,Thresh_connect,N_smoothing,om,T,N_x,N_y,fc,cc,kc,alpha_c,fp,cp,kp,alpha_p),

% scaled connection threshold

T_connect = Thresh_connect; 	% scaled threshold

fprintf(1,'Organizing the data...\n');

xp_frac = rem(xp2,1);
xc_frac = rem(xc2(1,:),1);

if std(xp_frac) > std(xc_frac),
    disp('Dense depth map in the image coordinates');
    temporal = 1;
    spatial = 0;
else
    disp('Dense depth map in the cross image and projector frame');
    temporal = 0;
    spatial = 1;
end;


if spatial,
    
    % Something to fix the organization:
    xpmin = min(xp2);
    xp_ind = round(unique(xp2 - xpmin));
    step_xp = min(diff(xp_ind)); %xp_ind(2) - xp_ind(1);
    xp4 = (xp2 - xpmin)/step_xp + xpmin;
    
    xpmin = min(xp4);
    xpmax = max(xp4);
    
    xcmin = min(xc2(2,:));
    xcmax = max(xc2(2,:));
    
else
    
    % Something to fix the organization:
    
    xp4 = xc2(1,:);
    
    xpmin = min(xp4);
    xpmax = max(xp4);
    
    xcmin = min(xc2(2,:));
    xcmax = max(xc2(2,:));
    
end;


Nrow = xcmax - xcmin + 1;
Ncol = xpmax - xpmin + 1;

Xmesh = zeros(Nrow,Ncol);
Ymesh = zeros(Nrow,Ncol);
Zmesh =  zeros(Nrow,Ncol);
Cmesh = zeros(Nrow,Ncol);
xcmesh = zeros(Nrow,Ncol);
ycmesh = zeros(Nrow,Ncol);

ind_col = round(xp4 - xpmin + 1);
ind_row = xc2(2,:) - xcmin + 1;
ind = ind_row + (ind_col-1)*Nrow;
ni = length(ind);


% Good format for ivview:
Xmesh(ind) = Xc2(1,:);
Ymesh(ind) = Xc2(2,:); 		% tries to have it in the right position
Zmesh(ind) = Xc2(3,:); 		% tries to have it in the right position
Cmesh(ind) = ones(1,ni);
xcmesh(ind) = xc2(1,:);
ycmesh(ind) = xc2(2,:);

% Hypothesis on the triangles:

D1 = Cmesh(2:Nrow,1:(Ncol-1)) & Cmesh(1:(Nrow-1),2:Ncol);
F1 = Cmesh(1:(Nrow-1),1:(Ncol-1)) & D1;
F2 = Cmesh(2:Nrow,2:Ncol) & D1;
C1 =  (F1 | F2);

D2 = Cmesh(1:(Nrow-1),1:(Ncol-1)) & Cmesh(2:Nrow,2:Ncol);
F3 = Cmesh(1:(Nrow-1),2:Ncol) & D2;
F4 = Cmesh(2:Nrow,1:(Ncol-1)) & D2;
C2 = (F3 | F4);

Ambi = C1 & C2; 			% ambiguous zones
Div1 = C1 & ~C2; 			% needs to check relative distance of points
Div2 = ~C1 & C2; 			% needs to check relative distance of points

% diagonal measure:

%Dm1 = abs(Zmesh(2:Nrow,1:(Ncol-1)) -  Zmesh(1:(Nrow-1),2:Ncol));


Dm1 =( Xmesh(2:Nrow,1:(Ncol-1)) -  Xmesh(1:(Nrow-1),2:Ncol)).^2 + (Ymesh(2:Nrow,1:(Ncol-1)) -  Ymesh(1:(Nrow-1),2:Ncol)).^2 + (Zmesh(2:Nrow,1:(Ncol-1)) -  Zmesh(1:(Nrow-1),2:Ncol)).^2;

%Dm2 = abs(Zmesh(1:(Nrow-1),1:(Ncol-1)) - Zmesh(2:Nrow,2:Ncol));

Dm2 = (Xmesh(1:(Nrow-1),1:(Ncol-1)) - Xmesh(2:Nrow,2:Ncol)).^2 + (Ymesh(1:(Nrow-1),1:(Ncol-1)) - Ymesh(2:Nrow,2:Ncol)).^2 + (Zmesh(1:(Nrow-1),1:(Ncol-1)) - Zmesh(2:Nrow,2:Ncol)).^2 ;

Div1n = Div1 | ((Dm1 <= Dm2)&Ambi);
Div2n = Div2 | ((Dm2 < Dm1)&Ambi);

Div11 = Div1n & F1;
Div12 = Div1n & F2;
Div21 = Div2n & F3;
Div22 = Div2n & F4;


% look at local difference:

dZ_r = abs(Zmesh(:,2:Ncol)-Zmesh(:,1:(Ncol-1)));
dZ_c = abs(Zmesh(2:Nrow,:)-Zmesh(1:(Nrow-1),:));

Div11 = Div11 & (dZ_r(1:(Nrow-1),:)<T_connect) & (dZ_c(:,1:(Ncol-1))<T_connect); % & (Dm1 < T_connect);
Div12 = Div12 & (dZ_r(2:Nrow,:)<T_connect) & (dZ_c(:,2:Ncol)<T_connect); %& (Dm1 < T_connect);

Div21 = Div21 & (dZ_r(1:(Nrow-1),:)<T_connect) & (dZ_c(:,2:Ncol)<T_connect); % & (Dm2 < T_connect);
Div22 = Div22 & (dZ_r(2:Nrow,:)<T_connect) & (dZ_c(:,1:(Ncol-1))<T_connect); % & (Dm2 < T_connect);


%%% Smoothing:

for i = 1:N_smoothing,
    
    fprintf(1,'Surface smoothing %d\n',i);
    
    % first find the neighbor points of every point:
    
    t = zeros(Nrow,Ncol);
    b = zeros(Nrow,Ncol);
    l = zeros(Nrow,Ncol);
    r = zeros(Nrow,Ncol);
    tr = zeros(Nrow,Ncol);
    br = zeros(Nrow,Ncol);
    tl = zeros(Nrow,Ncol);
    bl = zeros(Nrow,Ncol);
    
    
    t(2:Nrow,2:Ncol) = (Div12 | Div21);
    t(2:Nrow,1:(Ncol-1)) = t(2:Nrow,1:(Ncol-1)) | (Div11 | Div22);
    b(1:(Nrow-1),2:Ncol) = (Div12 | Div21);
    b(1:(Nrow-1),1:(Ncol-1)) = b(1:(Nrow-1),1:(Ncol-1)) | (Div11 | Div22);
    r(2:Nrow,1:(Ncol-1)) = (Div12 | Div22);
    r(1:(Nrow-1),1:(Ncol-1)) = r(1:(Nrow-1),1:(Ncol-1)) | (Div11 | Div21);
    l(2:Nrow,2:Ncol) = (Div12 | Div22);
    l(1:(Nrow-1),2:Ncol) = l(1:(Nrow-1),2:Ncol) | (Div11 | Div21);
    tr(2:Nrow,1:(Ncol-1)) = Div11 | Div12;
    br(1:(Nrow-1),1:(Ncol-1)) = Div21 | Div22;
    tl(2:Nrow,2:Ncol) = Div21 | Div22;
    bl(1:(Nrow-1),2:Ncol) = Div11 | Div12;
    
    
    Nn = t + b + l + r + tr + br + tl + bl;
    
    XX = Xmesh; 		     	% zeros(Nrow,2); zeros(2,Ncol+2)];
    YY = Ymesh; 				% zeros(Nrow,2); zeros(2,Ncol+2)];
    ZZ = Zmesh; 				% zeros(Nrow,2); zeros(2,Ncol+2)];
    
    [is,js] = find(Nn);
    
    indd = find((is > 1) & (is < Nrow) & (js > 1) & (js < Ncol));
    
    is = is(indd);
    js = js(indd);
    
    sm =  is + (js-1)*(Nrow);
    sm_t = is + (js-1)*(Nrow) - 1;
    sm_b = is + (js-1)*(Nrow) + 1;
    sm_r = is + (js)*(Nrow);
    sm_l = is + (js-2)*(Nrow);
    
    sm_tr =  is + (js)*(Nrow) - 1;
    sm_br =  is + (js)*(Nrow) + 1;
    sm_tl =  is + (js-2)*(Nrow) -1;
    sm_bl =  is + (js-2)*(Nrow) + 1;
    
    
    XX(sm) = 0.5 * XX(sm) + 0.5 * ((XX(sm_t).*t(sm)+XX(sm_b).*b(sm)+XX(sm_r).*r(sm)+XX(sm_l).*l(sm)+XX(sm_tr).*tr(sm)+XX(sm_br).*br(sm)+XX(sm_tl).*tl(sm)+XX(sm_bl).*bl(sm))./Nn(sm));
    
    YY(sm) = 0.5 * YY(sm) + 0.5 * ((YY(sm_t).*t(sm)+YY(sm_b).*b(sm)+YY(sm_r).*r(sm)+YY(sm_l).*l(sm)+YY(sm_tr).*tr(sm)+YY(sm_br).*br(sm)+YY(sm_tl).*tl(sm)+YY(sm_bl).*bl(sm))./Nn(sm));
    
    ZZ(sm) = 0.5 * ZZ(sm) + 0.5 * ((ZZ(sm_t).*t(sm)+ZZ(sm_b).*b(sm)+ZZ(sm_r).*r(sm)+ZZ(sm_l).*l(sm)+ZZ(sm_tr).*tr(sm)+ZZ(sm_br).*br(sm)+ZZ(sm_tl).*tl(sm)+ZZ(sm_bl).*bl(sm))./Nn(sm));
    
    Xmesh = XX(1:Nrow,1:Ncol);
    Ymesh = YY(1:Nrow,1:Ncol);
    Zmesh = ZZ(1:Nrow,1:Ncol);
    
    
    %%% reconnect after smoothing:
    
    % diagonal measure:
    
    Dm1 =( Xmesh(2:Nrow,1:(Ncol-1)) -  Xmesh(1:(Nrow-1),2:Ncol)).^2 + (Ymesh(2:Nrow,1:(Ncol-1)) -  Ymesh(1:(Nrow-1),2:Ncol)).^2 + (Zmesh(2:Nrow,1:(Ncol-1)) -  Zmesh(1:(Nrow-1),2:Ncol)).^2;
    
    Dm2 = (Xmesh(1:(Nrow-1),1:(Ncol-1)) - Xmesh(2:Nrow,2:Ncol)).^2 + (Ymesh(1:(Nrow-1),1:(Ncol-1)) - Ymesh(2:Nrow,2:Ncol)).^2 + (Zmesh(1:(Nrow-1),1:(Ncol-1)) - Zmesh(2:Nrow,2:Ncol)).^2 ;
    
    
    Div1n = Div1 | ((Dm1 <= Dm2)&Ambi);
    Div2n = Div2 | ((Dm2 < Dm1)&Ambi);
    
    Div11 = Div1n & F1;
    Div12 = Div1n & F2;
    Div21 = Div2n & F3;
    Div22 = Div2n & F4;
    
    
    % look at local difference:
    
    dZ_r = abs(Zmesh(:,2:Ncol)-Zmesh(:,1:(Ncol-1)));
    dZ_c = abs(Zmesh(2:Nrow,:)-Zmesh(1:(Nrow-1),:));
    
    Div11 = Div11 & (dZ_r(1:(Nrow-1),:)<T_connect) & (dZ_c(:,1:(Ncol-1))<T_connect); % & (Dm1 < T_connect);
    Div12 = Div12 & (dZ_r(2:Nrow,:)<T_connect) & (dZ_c(:,2:Ncol)<T_connect); %& (Dm1 < T_connect);
    
    Div21 = Div21 & (dZ_r(1:(Nrow-1),:)<T_connect) & (dZ_c(:,2:Ncol)<T_connect); % & (Dm2 < T_connect);
    Div22 = Div22 & (dZ_r(2:Nrow,:)<T_connect) & (dZ_c(:,1:(Ncol-1))<T_connect); % & (Dm2 < T_connect);
    
end; 				% of smoothing


% At that point the Divij are the final connections

% Find the number of neighbors per points:

t = zeros(Nrow,Ncol);
b = zeros(Nrow,Ncol);
l = zeros(Nrow,Ncol);
r = zeros(Nrow,Ncol);
tr = zeros(Nrow,Ncol);
br = zeros(Nrow,Ncol);
tl = zeros(Nrow,Ncol);
bl = zeros(Nrow,Ncol);


t(2:Nrow,2:Ncol) = (Div12 | Div21);
t(2:Nrow,1:(Ncol-1)) = t(2:Nrow,1:(Ncol-1)) | (Div11 | Div22);
b(1:(Nrow-1),2:Ncol) = (Div12 | Div21);
b(1:(Nrow-1),1:(Ncol-1)) = b(1:(Nrow-1),1:(Ncol-1)) | (Div11 | Div22);
r(2:Nrow,1:(Ncol-1)) = (Div12 | Div22);
r(1:(Nrow-1),1:(Ncol-1)) = r(1:(Nrow-1),1:(Ncol-1)) | (Div11 | Div21);
l(2:Nrow,2:Ncol) = (Div12 | Div22);
l(1:(Nrow-1),2:Ncol) = l(1:(Nrow-1),2:Ncol) | (Div11 | Div21);
tr(2:Nrow,1:(Ncol-1)) = Div11 | Div12;
br(1:(Nrow-1),1:(Ncol-1)) = Div21 | Div22;
tl(2:Nrow,2:Ncol) = Div21 | Div22;
bl(1:(Nrow-1),2:Ncol) = Div11 | Div12;

Nn = t + b + l + r + tr + br + tl + bl;

% build up the matrix of used points: (for renumbering)
% Number of neighbor triangles:

top_left = Div12 + Div21 + Div22;
top_right = Div11 + Div12 + Div22;
bot_left = Div11 + Div12 + Div21;
bot_right = Div11 + Div21 + Div22;


Used_points = zeros(Nrow,Ncol);
Used_points(2:Nrow,2:Ncol) = Used_points(2:Nrow,2:Ncol)+top_left;
Used_points(2:Nrow,1:(Ncol-1)) = Used_points(2:Nrow,1:(Ncol-1))+top_right;
Used_points(1:(Nrow-1),2:Ncol) = Used_points(1:(Nrow-1),2:Ncol)+bot_left;
Used_points(1:(Nrow-1),1:(Ncol-1)) = Used_points(1:(Nrow-1),1:(Ncol-1))+bot_right;


[xc3_2, xp3] = find(Used_points);

ind_points = (xp3-1)*Nrow + xc3_2;

N_vertices = length(ind_points);

Ind_Mat = -ones(Nrow,Ncol);
Ind_Mat(ind_points) = (1:N_vertices)-1;



% Regenere the 3D coordinates, the image location, and the projector coordinates:

Xc3 =  [Xmesh(ind_points) Ymesh(ind_points) Zmesh(ind_points)]';

% number of neighbors:

Nn3 = Nn(ind_points)';


xc3 =  project_points2(Xc3,zeros(3,1),zeros(3,1),fc,cc,kc,alpha_c);% project2(Xc3,eye(3),[0;0;0],fc,cc,kc);

%xc3(2,:) = xc3_2' + xcmin - 1;

%xp3_2D = project_points2(Xc3,om,T,fp,cp,kp,alpha_p);

if spatial,
    xp3 = step_xp * (xp3'-1) + xpmin;
else
    xp3_2D = project_points2(Xc3,om,T,fp,cp,kp,alpha_p);
    xp3 = xp3_2D(1,:);
end;


% Texture coordinates:
xc_texture = [(xc3(1,:)+.5)/(N_x);1-((xc3(2,:)+.5)/(N_y))];



% The boundaries faces (not fully connected):

Div11_u = Div11;
Div12_u = Div12;
Div21_u = Div21;
Div22_u = Div22;


[r11,c11] = find(Div11_u);
[r12,c12] = find(Div12_u);
[r21,c21] = find(Div21_u);
[r22,c22] = find(Div22_u);

% Work with Div11:
ind11_1 =  Nrow*c11+r11;
ind11_2 =  Nrow*(c11-1)+r11;
ind11_3 =  Nrow*(c11-1)+r11+1;

% Work with Div12:
ind12_1 =  Nrow*c12+r12;
ind12_2 =  Nrow*(c12-1)+r12+1;
ind12_3 =  Nrow*c12+r12+1;

% Work with Div21:
ind21_1 =  Nrow*c21+r21;
ind21_2 =  Nrow*(c21-1)+r21;
ind21_3 =  Nrow*c21+r21+1;

% Work with Div22:
ind22_1 =  Nrow*(c22-1)+r22;
ind22_2 =  Nrow*(c22-1)+r22+1;
ind22_3 =  Nrow*c22+r22+1;


% FaceSet
Faces11 = [Ind_Mat(ind11_1) Ind_Mat(ind11_2) Ind_Mat(ind11_3)];
Faces12 = [ Ind_Mat(ind12_1) Ind_Mat(ind12_2) Ind_Mat(ind12_3)];
Faces21 = [Ind_Mat(ind21_1) Ind_Mat(ind21_2) Ind_Mat(ind21_3)];
Faces22 = [ Ind_Mat(ind22_1) Ind_Mat(ind22_2) Ind_Mat(ind22_3)];

Faces = [Faces11;Faces12;Faces21;Faces22]';

N_triangles = size(Faces,2);


% matlab formulation:
tri3 = Faces' + 1;

% Direction of observation:
dc3 = -Xc3;
dc3 = dc3 ./ (ones(3,1) * (sqrt(sum(dc3.^2))));

% use Used_points to keep the number of neighbor triangles:

% compute the surface normals for Div11, Div12, Div21 and Div22, and then
% average them using Used_points as number of them.


nx11 = zeros(Nrow-1,Ncol-1);
ny11 = zeros(Nrow-1,Ncol-1);
nz11 = zeros(Nrow-1,Ncol-1);

nx12 = zeros(Nrow-1,Ncol-1);
ny12 = zeros(Nrow-1,Ncol-1);
nz12 = zeros(Nrow-1,Ncol-1);

nx21 = zeros(Nrow-1,Ncol-1);
ny21 = zeros(Nrow-1,Ncol-1);
nz21 = zeros(Nrow-1,Ncol-1);

nx22 = zeros(Nrow-1,Ncol-1);
ny22 = zeros(Nrow-1,Ncol-1);
nz22 = zeros(Nrow-1,Ncol-1);


u11 = [(Xmesh(ind11_2)-Xmesh(ind11_1))';(Ymesh(ind11_2)-Ymesh(ind11_1))';(Zmesh(ind11_2)-Zmesh(ind11_1))'];
v11 = [(Xmesh(ind11_3)-Xmesh(ind11_1))';(Ymesh(ind11_3)-Ymesh(ind11_1))';(Zmesh(ind11_3)-Zmesh(ind11_1))'];

nx11(r11+(c11-1)*(Nrow-1)) = u11(2,:).*v11(3,:) - u11(3,:).*v11(2,:);
ny11(r11+(c11-1)*(Nrow-1)) = u11(3,:).*v11(1,:) - u11(1,:).*v11(3,:);
nz11(r11+(c11-1)*(Nrow-1)) = u11(1,:).*v11(2,:) - u11(2,:).*v11(1,:);


u12 = [(Xmesh(ind12_2)-Xmesh(ind12_1))';(Ymesh(ind12_2)-Ymesh(ind12_1))';(Zmesh(ind12_2)-Zmesh(ind12_1))'];
v12 = [(Xmesh(ind12_3)-Xmesh(ind12_1))';(Ymesh(ind12_3)-Ymesh(ind12_1))';(Zmesh(ind12_3)-Zmesh(ind12_1))'];

nx12(r12+(c12-1)*(Nrow-1)) = u12(2,:).*v12(3,:) - u12(3,:).*v12(2,:);
ny12(r12+(c12-1)*(Nrow-1)) = u12(3,:).*v12(1,:) - u12(1,:).*v12(3,:);
nz12(r12+(c12-1)*(Nrow-1)) = u12(1,:).*v12(2,:) - u12(2,:).*v12(1,:);


u21 = [(Xmesh(ind21_2)-Xmesh(ind21_1))';(Ymesh(ind21_2)-Ymesh(ind21_1))';(Zmesh(ind21_2)-Zmesh(ind21_1))'];
v21 = [(Xmesh(ind21_3)-Xmesh(ind21_1))';(Ymesh(ind21_3)-Ymesh(ind21_1))';(Zmesh(ind21_3)-Zmesh(ind21_1))'];

nx21(r21+(c21-1)*(Nrow-1)) = u21(2,:).*v21(3,:) - u21(3,:).*v21(2,:);
ny21(r21+(c21-1)*(Nrow-1)) = u21(3,:).*v21(1,:) - u21(1,:).*v21(3,:);
nz21(r21+(c21-1)*(Nrow-1)) = u21(1,:).*v21(2,:) - u21(2,:).*v21(1,:);



u22 = [(Xmesh(ind22_2)-Xmesh(ind22_1))';(Ymesh(ind22_2)-Ymesh(ind22_1))';(Zmesh(ind22_2)-Zmesh(ind22_1))'];
v22 = [(Xmesh(ind22_3)-Xmesh(ind22_1))';(Ymesh(ind22_3)-Ymesh(ind22_1))';(Zmesh(ind22_3)-Zmesh(ind22_1))'];

nx22(r22+(c22-1)*(Nrow-1)) = u22(2,:).*v22(3,:) - u22(3,:).*v22(2,:);
ny22(r22+(c22-1)*(Nrow-1)) = u22(3,:).*v22(1,:) - u22(1,:).*v22(3,:);
nz22(r22+(c22-1)*(Nrow-1)) = u22(1,:).*v22(2,:) - u22(2,:).*v22(1,:);


% Sum all the relevant normal components for each vertice:

nx = zeros(Nrow,Ncol);
ny = zeros(Nrow,Ncol);
nz = zeros(Nrow,Ncol);

nx(1:(Nrow-1),1:(Ncol-1)) = nx11 + nx21 + nx22;
nx(2:Nrow,1:(Ncol-1)) = nx(2:Nrow,1:(Ncol-1)) + nx11 + nx12 + nx22;
nx(1:(Nrow-1),2:Ncol) = nx(1:(Nrow-1),2:Ncol) + nx11 + nx12 + nx21;
nx(2:Nrow,2:Ncol) = nx(2:Nrow,2:Ncol) + nx12 + nx21 + nx22;

ny(1:(Nrow-1),1:(Ncol-1)) = ny11 + ny21 + ny22;
ny(2:Nrow,1:(Ncol-1)) = ny(2:Nrow,1:(Ncol-1)) + ny11 + ny12 + ny22;
ny(1:(Nrow-1),2:Ncol) = ny(1:(Nrow-1),2:Ncol) + ny11 + ny12 + ny21;
ny(2:Nrow,2:Ncol) = ny(2:Nrow,2:Ncol) + ny12 + ny21 + ny22;

nz(1:(Nrow-1),1:(Ncol-1)) = nz11 + nz21 + nz22;
nz(2:Nrow,1:(Ncol-1)) = nz(2:Nrow,1:(Ncol-1)) + nz11 + nz12 + nz22;
nz(1:(Nrow-1),2:Ncol) = nz(1:(Nrow-1),2:Ncol) + nz11 + nz12 + nz21;
nz(2:Nrow,2:Ncol) = nz(2:Nrow,2:Ncol) + nz12 + nz21 + nz22;


% Vertice normals:
nc3 =  [nx(ind_points)';ny(ind_points)';nz(ind_points)'];


% normalization of the normals:

conf_nc3 = sum(nc3.^2);
Norms = sqrt(conf_nc3);

nc3 = nc3 ./ (ones(3,1)*Norms);

% update of the normal components:

nx(ind_points) = nc3(1,:);
ny(ind_points) = nc3(2,:);
nz(ind_points) = nc3(3,:);



%clear Ambi C1 C2 Cmesh D1 D2 Div Div1 Div11 Div11_u Div12 Div12_u Div2 Div21 Div21_u Div22 Div22_u Div1n Div2n Dm1 Dm2 F1 F2 F3 F4 Faces Faces11 Faces12 Faces21 Faces22 Header Ind_Mat Light Ncol Nn Norms Nrow Stripe T_connect Used_points Vertice_norm XX Xc3 Xmesh YY Ymesh ZZ Zmesh b bl bot_left bot_right br c11 c12 c21 c22 coeff dZ_c dZ_r day dot file i ind ind11_1 ind11_2 ind11_3 ind12_1 ind12_2 ind12_3 ind21_3 ind21_1 ind21_2 ind21_3 ind22_1 ind22_2 ind22_3 ind_col ind_row indd is js l ni nx nx11 nx12 nx21 nx22 ny ny11 ny12 ny21 ny22 nz nz11 nz12 nz21 nz22 r r11 r12 r21 r22 rasterimage sm sm_b sm_bl sm_br sm_l sm_r sm_t sm_tl sm_tr t tl top_left top_right tr u11 u12 u21 u22 unshading v v11 v12 v21 v22 Xc3 xc3_2 xc_texture xcmax xcmesh xcmin xp3 xpmax xpmin ycmesh xc3 ind_points

