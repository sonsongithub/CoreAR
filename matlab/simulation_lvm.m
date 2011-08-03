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

codeProjectedPositionWithNoise = floor(codeProjectedPosition);

estimatedP = getP(codeProjectedPosition, codeOriginalPositionWorld, ar)

estimatedPWithNoise = getP(codeProjectedPositionWithNoise, codeOriginalPositionWorld, ar)

estimatedPWithNoise_LM = getPWithLM(codeProjectedPositionWithNoise, codeOriginalPositionWorld, ar)

end

function estimatedP = getP(code, codeWorld, ar)
    code = code ./ repmat([ar.fx ar.fy]', 1, 4);

    estimatedP = pose_estimation(ar, code);
end

function estimatedP = getPWithLM(code, codeWorld, ar)
    code = code ./ repmat([ar.fx ar.fy]', 1, 4);

    estimatedP = pose_estimation(ar, code);

    estimatedP = levenbergMarquardt(estimatedP, code, codeWorld);
end

function subJ = subJacobian(uvw, xyz, param)
    subJ = zeros(2, 6);
    m1 = [-1 0;0 -1];
    m2 = [1/uvw(3), 0, -uvw(1)/uvw(3)/uvw(3);0, 1/uvw(3), -uvw(2)/uvw(3)/uvw(3);];
    m3 = rodrigues2Rotation(param(1:3,1));
    m4 = [0 xyz(3) -xyz(2); -xyz(3) 0 xyz(1);xyz(2) -xyz(1) 0];
    
    subJ(:,1:3) = m1 * m2 * m3 * m4;
    subJ(:,4:6) = m1 * m2;
end

function jacobian = getJacobian(projectedPointsHomogeneous, codeOriginalPositionWorld, param)

    jacobian = zeros(8, 6);

    for i=1:4
        uvw = projectedPointsHomogeneous(:,i);
        xyz = codeOriginalPositionWorld(:,i);
        subJ = subJacobian(uvw, xyz, param);
        jacobian((i-1)*2+1:(i-1)*2+2, :) = subJ;
    end

end

function [homoVec Vec] = project_codePosition(vec, mat)
    homoVec = mat * vec;
    homoVec = homoVec(1:3,:);
    Vec = homoVec(1:2,:) ./ repmat(homoVec(3,:), 2, 1);
end

function mat = RTMatrixFromParam(param)
    mat = zeros(4,4);
    mat(1:3,1:3) = rodrigues2Rotation(param(1:3,1));
    mat(1:3,4) = param(4:6,1);
    mat(4,4) = 1;
end

function [r J] = getErrorJacobian(p, codePos, codeWorldPos)

    RTMatrix = RTMatrixFromParam(p);
    [homoVec Vec] = project_codePosition(codeWorldPos, RTMatrix);

    error = codePos - Vec;
    r = reshape(error, 8, 1);
    J = getJacobian(homoVec, codeWorldPos, p);

end

function result = levenbergMarquardt(RTMatrixInit, codePos, codeWorldPos)
    threshold = 0.0001;
    lambda = 0.0001;

    p = zeros(6, 1);
    p(1:3,1) = rotation2Rodrigues(RTMatrixInit(1:3,1:3));
    p(4:6,1) = RTMatrixInit(1:3,4);

    [r, J] = getErrorJacobian(p, codePos, codeWorldPos);
    c      = r' * r;
    H      = J' * J;

    jacobian_counter = 1;

    while(true)
        D = lambda * diag(diag(H));
        delta_p = (H + D) \ (-J' * r);
        p_dash  = p + delta_p;

        RTMatrix = RTMatrixFromParam(p);
        [homoVec Vec] = project_codePosition(codeWorldPos, RTMatrix);
        error = codePos - Vec;
        r_dash = reshape(error, 8, 1);

        c_dash  = r_dash' * r_dash;

        if(c_dash > c)
            lambda = lambda * 10;
        else
            lambda = lambda / 10;
            c      = c_dash;
            p      = p_dash;

            if((delta_p' * delta_p) < threshold)
                break;
            end
            jacobian_counter = jacobian_counter + 1;
            [r, J] = getErrorJacobian(p, codePos, codeWorldPos);
            H = J' * J;
        end

    end

    jacobian_counter
    result = RTMatrixFromParam(p);
end
