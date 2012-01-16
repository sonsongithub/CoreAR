function cc = chaincode(img)

% test or functon mode
if (nargout == 1)
    % function mode
    cc = chaincode_(img);
else
    % test mode
    img = imread('./test.png');
    disp('test mode');
    
    %% prepare
    threshold = 150;
    gry_img = rgb2gray(img);
    bin_img = (gry_img < threshold);
    cc = chaincode_(bin_img);
end
end

function cc_ = chaincode_(bin_img)

% extract region
[labelImage, numberOfLabel] = bwlabeln(bin_img);
labelEdgeImage = labelImage .* bwperim(labelImage,8);

chaincodes = {};
s = size(labelImage);

l = 1;

for l=1:numberOfLabel
    f = false;
    for row=1:s(1)
        for col=2:s(2)
            if labelEdgeImage(row, col-1) == 0 && labelEdgeImage(row, col) == l
                c = bwtraceboundary(labelEdgeImage, [row col], 'W', 8);
                f = true;
                chaincodes{l} = c;
            end
            if f
                break;
            end
        end
        if f
            break;
        end
    end
end

cc_ = chaincodes;

end