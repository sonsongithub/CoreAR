function corners = locate_code(img)

corners = [];

test_flag = false;

% test or functon mode
if (nargout == 1)
    % function mode
else
    % test mode
    test_flag = true;
    img = imread('./3x2.png');
end

% binarize
threshold = 120;
grayImg = rgb2gray(img);
binImg = (grayImg < threshold);
binImg = imfill(binImg,'holes');

% extract region
[labelImage, numberOfLabel] = bwlabeln(binImg);
labelEdgeImage = labelImage .* bwperim(labelImage,8);

% output buffer for debugging
testOutoupt = grayImg * 0.1;

for label=1:numberOfLabel
    
    [x y v] = find(labelEdgeImage == label);
    
    numberOfPoints = size(x,1);
    
    % first corner is first point of labels
    firstCorner = [x(1) y(1)];
    firstCornerIndex = 1;
    
    secondCorner = [0 0];
    secondCornerIndex = 0;
    
    thirdCorner = [0 0];
    thirdCornerIndex = 0;
    
    fourthCorner = [0 0];
    fourthCornerIndex = 0;
    
    % third point is the most far from first point
    maximum = 0;
    for pointIndex=1:numberOfPoints
        distanceFromOrigin = (x(pointIndex) - firstCorner(1)) ^ 2 + (y(pointIndex) - firstCorner(2)) ^ 2;
        
        if maximum < distanceFromOrigin
            maximum = distanceFromOrigin;
            thirdCorner = [x(pointIndex) y(pointIndex)];
            thirdCornerIndex = pointIndex;
        end
        
        testOutoupt(x(pointIndex), y(pointIndex)) = 50;
        
    end
    
    % digonal line go through first point and third point.
    diagonalLine = cross([firstCorner(1), firstCorner(2), 1], [thirdCorner(1), thirdCorner(2), 1]);
    
    % second point is the most far from diagonal line.
    maximum = 0;
    for pointIndex=firstCornerIndex+1:thirdCornerIndex
        
        distanceFromDiagonalLine = diagonalLine * [x(pointIndex) y(pointIndex) 1]';
        
        if maximum < distanceFromDiagonalLine
            maximum = distanceFromDiagonalLine;
            secondCorner = [x(pointIndex) y(pointIndex)];
            secondCornerIndex = pointIndex;
        end
        
    end
    
    % fourth point is the most far from second point
    maximum = 0;
    for pointIndex=1:numberOfPoints
        distanceFromOrigin = (x(pointIndex) - secondCorner(1)) ^ 2 + (y(pointIndex) - secondCorner(2)) ^ 2;
        
        if maximum < distanceFromOrigin
            maximum = distanceFromOrigin;
            fourthCorner = [x(pointIndex) y(pointIndex)];
            fourthCornerIndex = pointIndex;
        end
        
    end
    
    % save four points
    if firstCornerIndex > 0 && secondCornerIndex > 0 && thirdCornerIndex > 0 && fourthCornerIndex > 0  
        % sort x, y
        corner.firstCorner(1) = firstCorner(2);
        corner.firstCorner(2) = firstCorner(1);
        corner.secondCorner(1) = secondCorner(2);
        corner.secondCorner(2) = secondCorner(1);
        corner.thirdCorner(1) = thirdCorner(2);
        corner.thirdCorner(2) = thirdCorner(1);
        corner.fourthCorner(1) = fourthCorner(2);
        corner.fourthCorner(2) = fourthCorner(1);
        
        % check convex or non-convex
        convexCheck(corner.secondCorner - corner.firstCorner, corner.thirdCorner - corner.secondCorner);
        convexCheck(corner.thirdCorner - corner.secondCorner, corner.fourthCorner - corner.thirdCorner);
        convexCheck(corner.fourthCorner - corner.thirdCorner, corner.firstCorner - corner.fourthCorner);
        convexCheck(corner.firstCorner - corner.fourthCorner, corner.secondCorner - corner.firstCorner);
        
        corner.codeProjectedPosition = zeros(2, 4);
        corner.codeProjectedPosition(:,1) = corner.firstCorner';
        corner.codeProjectedPosition(:,2) = corner.secondCorner';
        corner.codeProjectedPosition(:,3) = corner.thirdCorner';
        corner.codeProjectedPosition(:,4) = corner.fourthCorner';
        
        corner.codeProjectedPosition
        
        corners = [corners corner];
        
        if test_flag
            % for debugging
            testOutoupt(x(firstCornerIndex),y(firstCornerIndex)) = 255;
            testOutoupt(x(secondCornerIndex),y(secondCornerIndex)) = 255;
            testOutoupt(x(thirdCornerIndex),y(thirdCornerIndex)) = 255;
            testOutoupt(x(fourthCornerIndex),y(fourthCornerIndex)) = 255;
        end
    end

end

if (test_flag)
    imshow(testOutoupt);
end

end

function d = cosineDistance(v1, v2)
    d = v1 * v2';
    
    v1_l = sqrt(sum(v1 .* v1));
    v2_l = sqrt(sum(v2 .* v2));

    d = d / v1_l;
    d = d / v2_l;
    
end

function d = convexCheck(v1, v2)
    d = cross( cat(2, v1, 0), cat(2, v2, 0) );
end
