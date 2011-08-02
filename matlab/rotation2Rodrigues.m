function r = rotation2Rodrigues(rotationMatrix)
if (nargin == 1)
    % function mode
    r = rotation2Rodrigues_(rotationMatrix); 
else
    % test mode
    theta = rand(1,1);
    psi = rand(1,1);
    phi = rand(1,1);
    
    rotationMatrix1 = zeros(3,3);
    rotationMatrix2 = zeros(3,3);
    rotationMatrix3 = zeros(3,3);
    
    rotationMatrix1(1,1:3) = [ cos(theta) -sin(theta)          0];
    rotationMatrix1(2,1:3) = [ sin(theta)  cos(theta)          0];
    rotationMatrix1(3,1:3) = [         0           0           1];
    
    rotationMatrix2(1,1:3) = [ cos(psi  )          0   sin(psi )];
    rotationMatrix2(2,1:3) = [         0           1           0];
    rotationMatrix2(3,1:3) = [-sin(psi  )          0   cos(psi )];
    
    rotationMatrix3(1,1:3) = [         1           0           0];
    rotationMatrix3(2,1:3) = [         0   cos(phi  ) -sin(phi )];
    rotationMatrix3(3,1:3) = [         0   sin(phi  )  cos(phi )];
    
    rot = rotationMatrix1 * rotationMatrix2 * rotationMatrix3;
    r = rotation2Rodrigues_(rot);
    rot;
    rotationMatrix_again = rodrigues2Rotation(r);
    
    disp('This is test mode for rotation2Rodrigues');
    disp('Input rotation matrix');
    rot
    disp('Output Rodrigues vector');
    r
    disp('Again, this vector 2 rotation matrix(using rodrigues2Rotation)');
    rotationMatrix_again
end
end

function r = rotation2Rodrigues_(rotationMatrix)
    theta = acos((rotationMatrix(1,1) + rotationMatrix(2,2) + rotationMatrix(3,3) - 1) * 0.5);
    e1 = (rotationMatrix(3,2) - rotationMatrix(2,3)) / (2 * sin(theta));
    e2 = (rotationMatrix(1,3) - rotationMatrix(3,1)) / (2 * sin(theta));
    e3 = (rotationMatrix(2,1) - rotationMatrix(1,2)) / (2 * sin(theta));
    r = [theta*e1 theta*e2 theta*e3]';
end