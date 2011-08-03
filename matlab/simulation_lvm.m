function simulation()

% ar condition, focal length and code size
ar.fx = 650; %% 649.590771179639773;
ar.fy = 650; %% 653.240978126455161;
ar.codeSize = 0.5;
ar.imageSize = [480 640];
   
% code pose
p = getRTMatrix([pi/10, 0, pi/40], [0.05 0 5]);

% code original coordinates
codeOriginalPositionWorld = cat(1, [0 0 0;1 0 0;1 1 0;0 1 0]' * ar.codeSize * 1, [1 1 1 1]);

% rotate and translate code by pose matrix
codePositionWorld = p * codeOriginalPositionWorld;

% projected code into image plane
codeProjectedPosition = project(ar.fx, ar.fy, codePositionWorld);

% add noise for levenberg-marquardt method
codeProjectedPosition
codeProjectedPositionWithNoise = floor(codeProjectedPosition);%% + rand(2,4) * 0.02;

estimatedP = getP(codeProjectedPosition, codeOriginalPositionWorld, ar)
estimatedPWithNoise = getP(codeProjectedPositionWithNoise, codeOriginalPositionWorld, ar)
estimatedPWithNoise_LM = getPWithLM(codeProjectedPositionWithNoise, codeOriginalPositionWorld, ar)

end

function estimatedP = getP(code, codeWorld, ar)
code = code ./ repmat([ar.fx ar.fy]', 1, 4);

% estimate code pose matrix from normalize a code's position on image
estimatedP = pose_estimation(ar, code);

end

function estimatedP = getPWithLM(code, codeWorld, ar)
code = code ./ repmat([ar.fx ar.fy]', 1, 4);

% estimate code pose matrix from normalize a code's position on image
estimatedP = pose_estimation(ar, code);

estimatedP = leven(estimatedP, code, codeWorld);
end

function subJ = subJacobian(uvw, xyz, r, t)
    subJ = zeros(2, 6);
    m1 = [-1 0;0 -1];
    m2 = [1/uvw(3), 0, -uvw(1)/uvw(3)/uvw(3);0, 1/uvw(3), -uvw(2)/uvw(3)/uvw(3);];
    m3 = rodrigues2Rotation(r);
    m4 = [0 xyz(3) -xyz(2); -xyz(3) 0 xyz(1);xyz(2) -xyz(1) 0];
    
    subJ(:,1:3) = m1 * m2 * m3 * m4;
    subJ(:,4:6) = m1 * m2;
end

function p_lm = leven(estimatedP, normalizedCodeProjectedPosition, codeOriginalPositionWorld)
lambda = 2;
r = rotation2Rodrigues(estimatedP(1:3,1:3));
t = estimatedP(1:3,4);

currentProjectedPointsHomogeneous = estimatedP * codeOriginalPositionWorld;
currentProjectedPointsHomogeneous = currentProjectedPointsHomogeneous(1:3,:);

currentProjectedPoints = currentProjectedPointsHomogeneous(1:2,:) ./ repmat(currentProjectedPointsHomogeneous(3,:), 2, 1);

for j=1:100

error = normalizedCodeProjectedPosition - currentProjectedPoints;

error = reshape(error, 8, 1);

jacobian = zeros(8, 6);

for i=1:4
    uvw = currentProjectedPointsHomogeneous(:,i);
    xyz = codeOriginalPositionWorld(:,i);
    subJ = subJacobian(uvw, xyz, r, t);
    jacobian((i-1)*2+1:(i-1)*2+2, :) = subJ;
end

H = jacobian' * jacobian;
delta = -inv(H + lambda * diag(diag(H))) * jacobian' * error;

r = r + delta(1:3);
t = t + delta(4:6);

currentPMatrix = zeros(4,4);
currentPMatrix(1:3,1:3) = rodrigues2Rotation(r);
currentPMatrix(1:3,4) = t;
currentPMatrix(4,4) = 1;

nextProjectedPointsHomogeneous = currentPMatrix * codeOriginalPositionWorld;
nextProjectedPointsHomogeneous = nextProjectedPointsHomogeneous(1:3,:);
nextProjectedPoints = nextProjectedPointsHomogeneous(1:2,:) ./ repmat(nextProjectedPointsHomogeneous(3,:), 2, 1);


currentProjectedPointsHomogeneous = nextProjectedPointsHomogeneous;
currentProjectedPoints = nextProjectedPoints;

end

p_lm = currentPMatrix;

end
