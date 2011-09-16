function estimatedP = pose_estimation(ar, normalizedCodeProjectedPosition)


if (nargin == 2)
    % function mode
    codePositionWorld = cat(1, [0 0 0;1 0 0;1 1 0;0 1 0]' * ar.codeSize, [1 1 1 1]);
else
    % test mode
    disp('this is test mode');
    ar.fx = 649.590771179639773;
    ar.fy = 653.240978126455161;
    ar.codeSize = 1;
    
    imageSize = [640 480];
   
    % 2d code
    p = getRTMatrix([pi/6, 0, pi/10], [0 0 20]);
    
    codePositionWorld = cat(1, [0 0 0;1 0 0;1 1 0;0 1 0]' * ar.codeSize, [1 1 1 1]);
    
    codeProjectedPosition = project(ar.fx, ar.fy, p * codePositionWorld);
    
    codeProjectedPosition + repmat(imageSize'*0.5, 1, 4)

    normalizedCodeProjectedPosition = codeProjectedPosition ./ repmat([ar.fx ar.fy]', 1, 4);
end

codePositionWorld = cat(1, [0 0 0;1 0 0;1 1 0;0 1 0]', [1 1 1 1]);
homography = getHomographyMatrix(codePositionWorld, normalizedCodeProjectedPosition);

estimatedP = getPMatrix(homography, normalizedCodeProjectedPosition, ar.codeSize);

if (nargin ~= 2)
    disp('pose_estimation ---------> test mode');
    disp('Setting');
    disp(sprintf('focal length x = %f', ar.fx));
    disp(sprintf('focal length y = %f', ar.fy));
    disp(sprintf('code size      = %f', ar.codeSize));
    disp('pose matrix');
    p
    disp('code positon in image');
    codeProjectedPosition
    
    disp('result');
    
    disp('homogrpahy matrix');
    homography
    
    disp('estimated pose matrix');
    estimatedP
end

end

function p = getPMatrix(homography, normalizedCodeProjectedCodePositions, codeSize)
    p = zeros(4, 4);
    
    length_ex1 = sqrt(sum(homography(:,1) .* homography(:,1)));
    length_ex2 = sqrt(sum(homography(:,2) .* homography(:,2)));
    length = (length_ex1 + length_ex2) * 0.5;
    
    p(1:3,1) = homography(:,1) / length_ex1;
    p(1:3,2) = homography(:,2) / length_ex2;
    p(1:3,3) = cross(p(1:3,1), p(1:3,2));
    p(1:3,4) = homography(:,3) / length * codeSize;
    p(4,4) = 1;
end

function h = getHomographyMatrix(codePositions, normalizedCodeProjectedCodePositions)
    % estimation p matrix using correspoding points
    homography = zeros(3, 4);

    datamatrix = zeros(8, 8);
    datavector = zeros(8, 1);
    % get homography matrix
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

    h = inv(datamatrix) * datavector;

    h = cat(1, h, 1);

    h = reshape(h, 3, 3)';

end
