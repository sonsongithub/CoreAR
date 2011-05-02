function corners = code_detect(img)

test_flag = 0;

if (nargout ~= 1)
    img = imread('./2.png');
    test_flag = 1;
end

threshold = 120;
grayImg = rgb2gray(img);
binImg = (grayImg > threshold);
binImg = 1 - binImg;

[L, NUM] = bwlabeln(binImg);

BW2 = bwperim(binImg);
edges = L.*BW2;

hoge = zeros(size(binImg));

for k=1:NUM

    [i j v] = find(edges == k);
    if (size(i,1) > 200) && (size(i,1) < 800)
        
        max = 0;
        min = 100000000;
        leftTop = [0 0];
        leftTopIndex = 0;
        rightBottom = [0 0];
        rightBottomIndex = 0;
        
        findCorner = 0;
    
        for l=1:size(i,1)
            if (i(l) + j(l)) < min
                min = i(l) + j(l);
                leftTop = [i(l) j(l)];
                leftTopIndex = l;
                findCorner = findCorner + 1;
            end
            if (i(l) + j(l)) > max
                max = i(l) + j(l);
                rightBottom = [i(l) j(l)];
                rightBottomIndex = l;
                findCorner = findCorner + 1;
            end
        end
        
        line = cross([leftTop(1), leftTop(2), 1], [rightBottom(1), rightBottom(2), 1]);
        
        distance = 0;
        leftBottom = [0 0];
        m = 0;
        for l=1:size(i,1)
            d = abs(line * [i(l) j(l) 1]');
            if d > distance
                leftBottom = [i(l) j(l)];
                distance = d;
                m = l;
                findCorner = findCorner + 1;
            end
            if l == rightBottomIndex
                break;
            end
        end
        
        distance = 0;
        rightTop = [0 0];
        m = 0;
        for l=rightBottomIndex:size(i,1)
            d = abs(line * [i(l) j(l) 1]');
            if d > distance
                rightTop = [i(l) j(l)];
                distance = d;
                m = l;
                findCorner = findCorner + 1;
            end
        end
        
        for l=1:size(i,1)
            hoge(i(l), j(l)) = 0.25;
        end
        
        if (findCorner == 4)
            hoge(leftTop(1), leftTop(2)) = 1;
            hoge(rightBottom(1), rightBottom(2)) = 1;
            hoge(leftBottom(1), leftBottom(2)) = 1;
            hoge(rightTop(1), rightTop(2)) = 1;
            
            code.leftTop = leftTop;
            code.rightBottom = rightBottom;
            code.leftBottom = leftBottom;
            code.rightTop = rightTop;
            
            corners = [corners code];
            
        end
    end
end

if test_flag
    imshow(hoge);
end

end