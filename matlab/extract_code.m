function extract_code()

% read image
img = imread('./4.png');

% ar condition, focal length and code size
ar.fx = 649.590771179639773;
ar.fy = 653.240978126455161;
ar.codeSize = 100;
ar.imageSize = size(rgb2gray(img));
   
% code original coordinates
codeOriginalPositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);

% extract corners
corners = locate_code(img);

for i=1:size(corners, 1)
    corner = corners(i);
    
    corner.firstCorner = (corner.firstCorner - ar.imageSize/2) ./ [ar.fx ar.fy];
    corner.secondCorner = (corner.secondCorner - ar.imageSize/2) ./ [ar.fx ar.fy];
    corner.thirdCorner = (corner.thirdCorner - ar.imageSize/2) ./ [ar.fx ar.fy];
    corner.fourthCorner = (corner.thirdCorner - ar.imageSize/2) ./ [ar.fx ar.fy];
    
    normalizedCodeProjectedPosition = zeros(2, 4);
    
    normalizedCodeProjectedPosition(:,1) = (corner.firstCorner)';
    normalizedCodeProjectedPosition(:,2) = (corner.secondCorner)';
    normalizedCodeProjectedPosition(:,3) = (corner.thirdCorner)';
    normalizedCodeProjectedPosition(:,4) = (corner.fourthCorner)';
    
    normalizedCodeProjectedPosition
    
    estimatedP = pose_estimation(ar, normalizedCodeProjectedPosition);
    
    % rotate and translate code by pose matrix
    codePositionWorld = estimatedP * codeOriginalPositionWorld;
    
    line([0 codePositionWorld(1,1)], [0 codePositionWorld(3,1)], [0 codePositionWorld(2,1)]);
    line([0 codePositionWorld(1,2)], [0 codePositionWorld(3,2)], [0 codePositionWorld(2,2)]);
    line([0 codePositionWorld(1,3)], [0 codePositionWorld(3,3)], [0 codePositionWorld(2,3)]);
    line([0 codePositionWorld(1,4)], [0 codePositionWorld(3,4)], [0 codePositionWorld(2,4)]);
end

daspect([1 1 1]);
hold off;
view(45, 30);

end

function drawCode(code, img)
% exchenge y-z in order to assign z axis to a depth direction 
x = [[code(1,1) code(1,2)]; [code(1,4) code(1,3)]];
z = [[code(2,1) code(2,2)]; [code(2,4) code(2,3)]];
y = [[code(3,1) code(3,2)]; [code(3,4) code(3,3)]];
h = surf(x,y,z, img,...
         'FaceColor','texturemap',...
         'EdgeColor','none');
end