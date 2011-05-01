function p = getRTMatrix(deg_v, t)

    degx = deg_v(1);
    degy = deg_v(2);
    degz = deg_v(3);
    tx = t(1);
    ty = t(2);
    tz = t(3);

    rx = [1 0 0; 0 cos(degx) -sin(degx);0 sin(degx) cos(degx)];
    ry = [cos(degy) 0 sin(degy); 0 1 0;-sin(degy) 0 cos(degy)];
    rz = [cos(degz) -sin(degz) 0;sin(degz) cos(degz) 0;0 0 1];
    rotation = rx * ry * rz;
    t = [tx ty tz]';
    p = cat(1, cat(2, rotation, t), [0 0 0 1]);

end