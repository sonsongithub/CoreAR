function hough

clear();


for i=3:3
    file = sprintf('%d.png', i)
    cimg = imread(file);
    
    img = binarize(rgb2gray(cimg), 120);

    [B,L,N] = bwboundaries(img);

    for j=1:N
        points = B{j};
        houghMat = houghTransform(img, points);
        binHough = binarize(houghMat, 40);
        
        [hb,hl,hn] = bwboundaries(binHough);
        
        centers = zeros(4,2);
        
        if hn == 4
            for k=1:hn
               peaksPoints = hb{k};
               size(peaksPoints)
               x=0;
               y=0;
               for l=1:size(peaksPoints,1)
                   x = x + peaksPoints(l,1);
                   y = y + peaksPoints(l,2);
               end
               x = x / size(peaksPoints,1);
               y = y / size(peaksPoints,1);
               centers(k,1) = x;
               centers(k,2) = y;
            end
        end
        hn
        centers
        
        precision = 200;
        
        for i=1:4
            center = centers(i,:);
            for t=-100:100
                d = center(1);
                theta = pi / precision * center(2);
                x = d * cos(theta) + t * sin(theta);
                y = d * sin(theta) - t * cos(theta);
                x = floor(x-1);
                y = floor(y-1);
                if x > 0 && y > 0
                img(x,y) = 120;
                end
            end
        end
    end
    
    
    subplot(2,2,1);
    imshow(uint8(binHough));
    
    subplot(2,2,2);
    imshow(uint8(img));

end
end

function img = binarize(img, threshold)
for x=1:size(img,1)
    for y=1:size(img,2)
        if (img(x,y) > threshold)
            img(x,y) = 255;
        else
            img(x,y) = 0;
        end
    end
end
end

function houghMat = houghTransform(img, points)

if size(img, 1) > size(img, 2)
    distance = size(img, 1) * sqrt(2);
else
    distance = size(img, 2) * sqrt(2);
end

distance = floor(distance);

precision = 200;

houghMat = zeros(distance, precision);

for i=1:size(points,1)
    x = points(i,1);
    y = points(i,2);
    for i=1:precision
        theta = pi / precision * i;
        t = x * cos(theta) + y * sin(theta) + 1;
        if t > 0
            t = uint32(t)+1;
            houghMat(t, i) = houghMat(t, i) + 1;
        end
    end
end
end

function detectCode(cimg)

subplot(2,2,1);
imshow(img);



return;

[B,L,N] = bwboundaries(img);

subplot(2,2,2);
label = 3;
newimage = zeros(size(img));

points = B{label};

for i=1:size(points,1)
    x = points(i,1);
    y = points(i,2);
    newimage(x,y)=255;
end
imshow(uint8(newimage));


subplot(1,2,1);

imshow(uint8(houghMat));

binHoughMat = zeros(size(houghMat));

threshold = 40;

for x=1:size(houghMat,1)
    for y=1:size(houghMat,2)
        if (houghMat(x,y) > threshold)
            binHoughMat(x,y) = 255;
        else
            binHoughMat(x,y) = 0;
        end
    end
end

[B,L,N] = bwboundaries(binHoughMat)

subplot(1,2,2);

imshow(uint8(binHoughMat));

end
