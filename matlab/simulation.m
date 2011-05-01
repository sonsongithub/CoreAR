function simulation()

ar.fx = 1;649.590771179639773*2;
ar.fy = 1;653.240978126455161*2;
ar.codeSize = 1;
   
% 2d code
p = getRTMatrix([0, pi/3, 0], [0 0 10]);

codePositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);

x = p * codePositionWorld;

codeProjectedPosition = project(ar.fx, ar.fy, p * codePositionWorld);

normalizedCodeProjectedPosition = codeProjectedPosition ./ repmat([ar.fx ar.fy]', 1, 4);

estimatedP = pose_estimation(ar, normalizedCodeProjectedPosition);

img = imread('../resource/code02.png');

x = p * codePositionWorld

drawCode(x, img);

hold on;

line([-0.5 0.5 0.5 -0.5 -0.5], [1 1 1 1 1], [-0.5 -0.5 0.5 0.5 -0.5]);


line([0 x(1,1)], [0 x(3,1)], [0 x(2,1)]);
line([0 x(1,2)], [0 x(3,2)], [0 x(2,2)]);
line([0 x(1,3)], [0 x(3,3)], [0 x(2,3)]);
line([0 x(1,4)], [0 x(3,4)], [0 x(2,4)]);

%%fill3([-0.5 0.5 0.5 -0.5], [1 1 1 1], [-0.5 -0.5 0.5 0.5], [1 0 0]);

drawCode(cat(1, normalizedCodeProjectedPosition*1, [1 1 1 1]), img);


hold off;

view(225, 30);

end

function drawCode(code, img)

x = [[code(1,1) code(1,4)]; [code(1,3) code(1,2)]];
z = [[code(2,1) code(2,4)]; [code(2,3) code(2,2)]];
y = [[code(3,1) code(3,4)]; [code(3,3) code(3,2)]];
 
warp(x, y, z, img);

end