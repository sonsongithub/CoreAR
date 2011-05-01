function pose_estimation()

clear;

%% condition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% 2d code
codeSize = 101.6;

%% imac setting
%% camera parameter
fx = 649.590771179639773;
fy = 653.240978126455161;
imageSize = [320 240];

p = getRTMatrix([pi/6, pi, 0], [0 10 1000])

codePositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * codeSize * 0.5, [1 1 1 1])

normalizedCodeProjectedPosition = project(fx, fy, p * codePositionWorld)

h = getHomographyMatrix(codePositionWorld, normalizedCodeProjectedPosition)

return;

%% XYZ real world points
x_original = [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * codeSize * 0.5;
x_original = cat(1, x_original, [1 1 1 1]);

%% image
x_image = [143 53; 268 56;256 205;137 174]';
% normalize
x_image = x_image - repmat([imageSize(1)/2;imageSize(2)/2], 1, 4);

%% make camera parameter matrix
k(1,:) = [fx, 0, 0, 0];
k(2,:) = [0, fy, 0, 0];
k(3,:) = [0, 0, 1, 0];

%% estimation p matrix using correspoding points
homography = zeros(3, 4);

datamatrix = zeros(8, 8);
datavector = zeros(8, 1);

x_image_normalize(1,:) = x_image(1,:) / fx;    %% normalize image coordinate with f value
x_image_normalize(2,:) = x_image(2,:) / fy;

%% get homography matrix
for i=0:3
    X = x_original(1, i+1);
    Y = x_original(2, i+1);
    x = x_image_normalize(1, i+1);
    y = x_image_normalize(2, i+1);
    datamatrix(i*2+1,:) = [X Y 1 0 0 0 -x*X -x*Y];
    datamatrix(i*2+2,:) = [0 0 0 X Y 1 -y*X -y*Y];
    datavector(i*2+1,:) = x;
    datavector(i*2+2,:) = y;
end

datamatrix
datavector

temp = inv(datamatrix) * datavector;
homography(1,:) = [temp(1) temp(2) 0 temp(3)];
homography(2,:) = [temp(4) temp(5) 0 temp(6)];
homography(3,:) = [temp(7) temp(8) 1 1];

%% estimate p matrix from homography matrix
estimated_p = zeros(4, 4);
estimated_p(1,:) = [temp(1) temp(2) 0 temp(3)];
estimated_p(2,:) = [temp(4) temp(5) 0 temp(6)];
estimated_p(3,:) = [temp(7) temp(8) 0 1];
estimated_p(4,:) = [0 0 0 1];
estimated_p(1:3,3) = cross(estimated_p(1:3,1), estimated_p(1:3,2));
estimated_p(:,1:3) = estimated_p(:,1:3) ./ repmat(sqrt(sum(estimated_p(:,1:3).*estimated_p(:,1:3), 1)), 4, 1);

%% estimate real distance between code and camera
x1 = cat(1, x_image_normalize(1:2,1), [1])
x3 = cat(1, x_image_normalize(1:2,3), [1])
ez = estimated_p(1:3,3);

v = (x3' * ez )/ (x1' * ez) * x1 - x3
length = sqrt(sum(v .* v, 1))

s3 = codeSize * sqrt(2) / length;
s1 = (x3' * ez )/ (x1' * ez) * s3;

estimated_p(1:3,4) = s1 * 0.5 * x1 + s3 * 0.5 * x3;

p = estimated_p(1:3,4);

estimated_p

%% rendering Real world %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);

%% rendering projected points
temp = cat(1, cat(2, x_image_normalize, x_image_normalize(:,1)), [1 1 1 1 1]);
plot3(temp(1,:), temp(2,:), temp(3,:), 'g-');


hold on;
%% rendering projecting ray
%% project estimated points coordinate
estimated_x_world = estimated_p * x_original;

for i=1:4
    plot3([0 estimated_x_world(1,i)], [0 estimated_x_world(2,i)], [0 estimated_x_world(3,i)], 'b-');
end


temp = cat(2, estimated_x_world, estimated_x_world(:,1));
plot3(temp(1,:), temp(2,:), temp(3,:), 'k-');

temp = [-imageSize(1)/2 imageSize(2)/2; imageSize(1)/2 imageSize(2)/2; imageSize(1)/2 -imageSize(2)/2; -imageSize(1)/2 -imageSize(2)/2; -imageSize(1)/2 imageSize(2)/2]';
temp(1,:) = temp(1,:) / fx;
temp(2,:) = temp(2,:) / fy;
temp = cat(1, temp, [1 1 1 1 1]);
plot3(temp(1,:), temp(2,:), temp(3,:), 'k-');

xlim([-0.5 0.5]);
ylim([-0.5 0.5]);

hold off;

%% rendering 2d image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
temp = cat(2, x_image, x_image(:,1));
temp(1,:) = temp(1,:) + imageSize(1)/2;
temp(2,:) = temp(2,:) + imageSize(2)/2;
plot(temp(1,:), temp(2,:), 'g-');

hold on;
rectangle('Position',[0,0,imageSize(1), imageSize(2)], 'LineWidth',1,'LineStyle','-');
xlim([0 320]);
ylim([0 240]);

% render virtual object on 2d code
x_3d = [-1 1 0;1 1 0;1 -1 0;-1 -1 0;-1 1 0]' * codeSize * 0.5;
x_3d(3,:) = codeSize;
x_3d = cat(1, x_3d, [1 1 1 1 1]);


temp = k * estimated_p * x_3d;
x_3d_image = temp(1:2,:) ./ repmat(temp(3,:), 2, 1);


x_3d_image(1,:) = x_3d_image(1,:) + imageSize(1)/2;
x_3d_image(2,:) = x_3d_image(2,:) + imageSize(2)/2;

temp = cat(2, x_image, x_image(:,1));
temp(1,:) = temp(1,:) + imageSize(1)/2;
temp(2,:) = temp(2,:) + imageSize(2)/2;

plot(x_3d_image(1,:), x_3d_image(2,:), 'r-');

for i=1:4
plot([x_3d_image(1,i), temp(1,i)], [x_3d_image(2,i), temp(2,i)], 'r-');
end

hold off;

end

function h = getHomographyMatrix(codePositions, normalizedCodeProjectedCodePositions)
%% estimation p matrix using correspoding points
homography = zeros(3, 4);

datamatrix = zeros(8, 8);
datavector = zeros(8, 1);

%% get homography matrix
for i=0:3
    X = codePositions(1, i+1);
    Y = codePositions(2, i+1);
    x = normalizedCodeProjectedCodePositions(1, i+1);
    y = normalizedCodeProjectedCodePositions(2, i+1);
    datamatrix(i*2+1,:) = [X Y 1 0 0 0 -x*X -x*Y];
    datamatrix(i*2+2,:) = [0 0 0 X Y 1 -y*X -y*Y];
    datavector(i*2+1,:) = x;
    datavector(i*2+2,:) = y;
end

datamatrix
datavector

h = inv(datamatrix) * datavector;

h

h = cat(1, h, 1);

h = reshape(h, 3, 3)

end

function projectedPosition = project(fx, fy, positions) 

k(1,:) = [fx, 0, 0, 0];
k(2,:) = [0, fy, 0, 0];
k(3,:) = [0, 0, 1, 0];

temp = k * positions;
temp
projectedPosition = temp(1:2,:) ./ repmat(temp(3,:), 2, 1);

end

function p = getRTMatrix(deg_v, t)

degx = deg_v(1);
degy = deg_v(2);
degz = deg_v(3);
tx = t(1);
ty = t(2);
tz = t(3);

rx = [1 0 0; 0 cos(degx) -sin(degx);0 sin(degx) cos(degx)];
ry = [cos(degy) 0 sin(degy); 0 1 0;-sin(degy) 0 cos(degy)];
rz = [cos(degz) -sin(degz) 0;sin(degz) cos(degz) 0;0 0 1];
rotation = rx * ry * rz;
t = [tx ty tz]';
p = cat(1, cat(2, rotation, t), [0 0 0 1]);

end