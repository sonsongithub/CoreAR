function rotationMatrix = rodrigues2Rotation(r)
if (nargin == 1)
    rotationMatrix = rodrigues2Rotation_(r); 
else
    r = rand(3, 1);
    rotationMatrix = rodrigues2Rotation_(r);
    r_again = rotation2Rodrigues(rotationMatrix);
    
    disp('This is test mode for rodrigues2Rotation');
    disp('Input Rodrigues vector');
    r
    disp('Output rotation matrix');
    rotationMatrix
    disp('Again, this rotation matrix 2 Rodrigues vector(using rotation2Rodrigues)');
    r_again
end
end

function rotationMatrix = rodrigues2Rotation_(r)
    theta = sqrt(sum(r .* r));
    rx = [0 -r(3) r(2);r(3) 0 -r(1);-r(2) r(1) 0];
    rx2 = rx * rx;
    rotationMatrix = eye(3,3) + sin(theta)/theta*rx + (1-cos(theta))/theta/theta*rx2;
    
end