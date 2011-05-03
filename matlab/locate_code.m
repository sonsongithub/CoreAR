function corners = locate_code(img)

corners = [];

test_flag = false;

if (nargout == 1)
    % function mode
else
    % test mode
    test_flag = true;
    img = imread('4.png');
end

threshold = 120;

grayImg = rgb2gray(img);
binImg = (grayImg < threshold);

binImg = imfill(binImg,'holes');


[labelImage, numberOfLabel] = bwlabeln(binImg);

labelEdgeImage = labelImage .* bwperim(labelImage,8); 

testOutoupt = zeros(size(labelEdgeImage));

for label=1:numberOfLabel
    
    [x y v] = find(labelEdgeImage == label);
    
    numberOfPoints = size(x,1);
    
    minimum = 1000000000000;
    maximum = 0;
    
    firstCorner = [x(1) y(1)];
    firstCornerIndex = 1;
    
    secondCorner = [0 0];
    secondCornerIndex = 0;
    
    thirdCorner = [0 0];
    thirdCornerIndex = 0;
    
    fourthCorner = [0 0];
    fourthCornerIndex = 0;
    
    for pointIndex=1:numberOfPoints
        distanceFromOrigin = (x(pointIndex) - firstCorner(1)) ^ 2 + (y(pointIndex) - firstCorner(2)) ^ 2;
        
        if maximum < distanceFromOrigin
            maximum = distanceFromOrigin;
            thirdCorner = [x(pointIndex) y(pointIndex)];
            thirdCornerIndex = pointIndex;
        end
        
        testOutoupt(x(pointIndex), y(pointIndex)) = 0.1;
        
    end
    
    diagonalLine = cross([firstCorner(1), firstCorner(2), 1], [thirdCorner(1), thirdCorner(2), 1]);
    
    maximum = 0;
    for pointIndex=firstCornerIndex+1:thirdCornerIndex
        
        distanceFromDiagonalLine = diagonalLine * [x(pointIndex) y(pointIndex) 1]';
        
        if maximum < distanceFromDiagonalLine
            maximum = distanceFromDiagonalLine;
            secondCorner = [x(pointIndex) y(pointIndex)];
            secondCornerIndex = pointIndex;
        end
        
    end
    
    maximum = 0;
    for pointIndex=1:numberOfPoints
        distanceFromOrigin = (x(pointIndex) - secondCorner(1)) ^ 2 + (y(pointIndex) - secondCorner(2)) ^ 2;
        
        if maximum < distanceFromOrigin
            maximum = distanceFromOrigin;
            fourthCorner = [x(pointIndex) y(pointIndex)];
            fourthCornerIndex = pointIndex;
        end
        
    end
    
    if firstCornerIndex > 0 && secondCornerIndex > 0 && thirdCornerIndex > 0 && fourthCornerIndex > 0  
        
        corner.firstCorner = firstCorner;
        corner.secondCorner = secondCorner;
        corner.thirdCorner = thirdCorner;
        corner.fourthCorner = fourthCorner;
        
        corners = [corners corner];
        
        testOutoupt(x(firstCornerIndex),y(firstCornerIndex)) = 1;
        testOutoupt(x(secondCornerIndex),y(secondCornerIndex)) = 1;
        testOutoupt(x(thirdCornerIndex),y(thirdCornerIndex)) = 1;
        testOutoupt(x(fourthCornerIndex),y(fourthCornerIndex)) = 1;
    end

end

if (test_flag)
    imshow(testOutoupt);
end

end