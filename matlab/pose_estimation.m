function estimatedP = pose_estimation(ar, normalizedCodeProjectedPosition)


if (nargin == 2)
    % function mode
    codePositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);
else
    % test mode
    disp('this is test mode');
    ar.fx = 649.590771179639773;
    ar.fy = 653.240978126455161;
    ar.codeSize = 2;
   
    % 2d code
    p = getRTMatrix([pi/6, pi, 0], [0 0 10]);
    
    codePositionWorld = cat(1, [-1 1 0;1 1 0;1 -1 0;-1 -1 0]' * ar.codeSize * 0.5, [1 1 1 1]);
    
    codeProjectedPosition = project(ar.fx, ar.fy, p * codePositionWorld);

    normalizedCodeProjectedPosition = codeProjectedPosition ./ repmat([ar.fx ar.fy]', 1, 4);
end

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
    p(1,:) = [homography(1,1) homography(1,2) 0 homography(1,3)];
    p(2,:) = [homography(2,1) homography(2,2) 0 homography(2,3)];
    p(3,:) = [homography(3,1) homography(3,2) 0 1];
    p(4,:) = [0 0 0 1];
    p(1:3,3) = cross(p(1:3,1), p(1:3,2));

    % normalize rotation vectors
    p(:,1:3) = p(:,1:3) ./ repmat(sqrt(sum(p(:,1:3).*p(:,1:3), 1)), 4, 1);

    % estimate real distance between code and camera
    x1 = cat(1, normalizedCodeProjectedCodePositions(1:2,1), [1]);
    x3 = cat(1, normalizedCodeProjectedCodePositions(1:2,3), [1]);
    ez = p(1:3,3);

    v = (x3' * ez )/ (x1' * ez) * x1 - x3;
    length = sqrt(sum(v .* v, 1));

    s3 = codeSize * sqrt(2) / length;
    s1 = (x3' * ez )/ (x1' * ez) * s3;

    p(1:3,4) = s1 * 0.5 * x1 + s3 * 0.5 * x3;

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
