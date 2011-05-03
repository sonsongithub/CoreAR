function extract_code()

% read image
img = imread('./1.png');

% dummy visual code image
codeImg = imread('./dummyCode.png');

% ar condition, focal length and code size
ar.fx = 649.590771179639773;
ar.fy = 653.240978126455161;
ar.codeSize = 0.2;
ar.imageSize = size(rgb2gray(img));
   
% code original coordinates
codeOriginalPositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);

% extract corners
corners = locate_code(img);
    
for i=1:size(corners, 2)

    corner = corners(i);
    
    % normalized input image coordinates
    imageX = [ar.imageSize(2)/ar.fx/2 -ar.imageSize(2)/ar.fx/2 -ar.imageSize(2)/ar.fx/2  ar.imageSize(2)/ar.fx/2];
    imageY = [ar.imageSize(1)/ar.fy/2  ar.imageSize(1)/ar.fy/2 -ar.imageSize(1)/ar.fy/2 -ar.imageSize(1)/ar.fy/2];
    imageZ = [1 1 1 1];

    % draw input image
    drawCode([imageX;imageY;imageZ], img);

    hold on;

    % make visual code's corner position normalized.
    corner.codeProjectedPosition = (repmat([ar.imageSize(2) ar.imageSize(1)]', 1, 4) - corner.codeProjectedPosition)
    corner.codeProjectedPosition = corner.codeProjectedPosition - repmat([ar.imageSize(2)/2 ar.imageSize(1)/2]', 1, 4);
    corner.codeProjectedPosition = corner.codeProjectedPosition ./ repmat([ar.fx ar.fy]', 1, 4);

    % estimate visual code's pose
    estimatedP = pose_estimation(ar, corner.codeProjectedPosition)

    % estimate visual code position on camera world.
    codePositionWorld = estimatedP * codeOriginalPositionWorld;

    % draw projective line
    line([0 codePositionWorld(1,1)], [0 codePositionWorld(3,1)], [0 codePositionWorld(2,1)]);
    line([0 codePositionWorld(1,2)], [0 codePositionWorld(3,2)], [0 codePositionWorld(2,2)]);
    line([0 codePositionWorld(1,3)], [0 codePositionWorld(3,3)], [0 codePositionWorld(2,3)]);
    line([0 codePositionWorld(1,4)], [0 codePositionWorld(3,4)], [0 codePositionWorld(2,4)]);

    % draw dummy code
    drawCode(codePositionWorld, codeImg);
end

daspect([1 1 1]);
view(60, 15);
hold off;

end

function drawCode(code, img)
    % exchenge y-z in order to assign z axis to a depth direction 
    x = [[code(1,1) code(1,2)]; [code(1,4) code(1,3)]];
    z = [[code(2,1) code(2,2)]; [code(2,4) code(2,3)]];
    y = [[code(3,1) code(3,2)]; [code(3,4) code(3,3)]];
    h = surf(x,y,z,img,'FaceColor','texturemap','EdgeColor','none');
end