function extract_code()

% read image
img = imread('./3.png');

% dummy visual code image
codeImg = imread('./dummyCode.png');

% ar condition, focal length and code size
ar.fx = 649.590771179639773;
ar.fy = 653.240978126455161;
ar.codeSize = 1.5;
ar.imageSize = size(rgb2gray(img));
   
% code original coordinates
codeOriginalPositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);

% extract corners
corners = locate_code(img);
    
% normalized input image coordinates
imageX = [ar.imageSize(2)/ar.fx/2 -ar.imageSize(2)/ar.fx/2 -ar.imageSize(2)/ar.fx/2  ar.imageSize(2)/ar.fx/2];
imageY = [ar.imageSize(1)/ar.fy/2  ar.imageSize(1)/ar.fy/2 -ar.imageSize(1)/ar.fy/2 -ar.imageSize(1)/ar.fy/2];
imageZ = [1 1 1 1];

% draw input image
drawCode([imageX;imageY;imageZ], img);

hold on;

% view setting
view(60, 15);
fontsize = 40;

maximum_z = 0;

for i=1:size(corners, 2)
    corner = corners(i);
    % make visual code's corner position normalized.
    corner.codeProjectedPosition = (repmat([ar.imageSize(2) ar.imageSize(1)]', 1, 4) - corner.codeProjectedPosition)
    corner.codeProjectedPosition = corner.codeProjectedPosition - repmat([ar.imageSize(2)/2 ar.imageSize(1)/2]', 1, 4);
    corner.codeProjectedPosition = corner.codeProjectedPosition ./ repmat([ar.fx ar.fy]', 1, 4);

    % estimate visual code's pose
    estimatedP = pose_estimation(ar, corner.codeProjectedPosition)

    % estimate visual code position on camera world.
    codePositionWorld = estimatedP * codeOriginalPositionWorld;
    
    if maximum_z < codePositionWorld(3, 4)
        maximum_z = codePositionWorld(3, 4)
    end

    % draw projective line
    line([0 codePositionWorld(1,1)], [0 codePositionWorld(3,1)], [0 codePositionWorld(2,1)]);
    line([0 codePositionWorld(1,2)], [0 codePositionWorld(3,2)], [0 codePositionWorld(2,2)]);
    line([0 codePositionWorld(1,3)], [0 codePositionWorld(3,3)], [0 codePositionWorld(2,3)]);
    line([0 codePositionWorld(1,4)], [0 codePositionWorld(3,4)], [0 codePositionWorld(2,4)]);

    % draw dummy code
    drawCode(codePositionWorld, codeImg);
    
    % draw coordinate sysytem description
    text(   'Interpreter','latex',...
            'String','$$\leftarrow X$$',...
            'Position',[codePositionWorld(1,1), codePositionWorld(3,1), codePositionWorld(2,1)],...
            'FontSize', fontsize,...
            'Color', 'r')
    text(   'Interpreter','latex',...
            'String','$$\leftarrow \hat{X}$$',...
            'Position',[corner.codeProjectedPosition(1,1), 1, corner.codeProjectedPosition(2,1)],...
            'FontSize', fontsize,...
            'Color', 'r')
    text(   'Interpreter','latex',...
            'String','$$\leftarrow x$$',...
            'Position',[corner.codeProjectedPosition(1,3), 1, corner.codeProjectedPosition(2,3)],...
            'FontSize', fontsize,...
            'Color', 'r')
end

% draw axis of camera coordinate system
line([-1 1], [0 0], [0 0], 'Color', 'k', 'LineStyle', '--');
line([ 0 0], [0 0], [-1 1], 'Color', 'k', 'LineStyle', '--');
line([ 0 0], [-1 maximum_z*1.5], [0 0], 'Color', 'k', 'LineStyle', '--');
text(   'Interpreter','latex',...
        'String','$$O$$',...
        'Position',[0 0 0],...
        'FontSize', fontsize,...
        'Color', 'k')

daspect([1 1 1]);
hold off;

end

function drawCode(code, img)
    % exchenge y-z in order to assign z axis to a depth direction 
    x = [[code(1,1) code(1,2)]; [code(1,4) code(1,3)]];
    z = [[code(2,1) code(2,2)]; [code(2,4) code(2,3)]];
    y = [[code(3,1) code(3,2)]; [code(3,4) code(3,3)]];
    h = surf(x,y,z,img,'FaceColor','texturemap','EdgeColor','none');
end