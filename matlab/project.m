function projectedPosition = project(fx, fy, positions) 

    k(1,:) = [fx, 0, 0, 0];
    k(2,:) = [0, fy, 0, 0];
    k(3,:) = [0, 0, 1, 0];

    temp = k * positions;
    projectedPosition = temp(1:2,:) ./ repmat(temp(3,:), 2, 1);

end