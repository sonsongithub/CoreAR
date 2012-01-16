function corner_detection()

if 1
    
addpath('../../../code/QTMATLABCameraCapture/');

width = 320;
height = 240;
frames = 400;
threshold = 60;

%% test Y(WhiteIsZero) mode
mode = 3;
camera = qtcamera_create(width, height, mode);
for i=1:frames
    image = qtcamera_capture(camera);
    extract(image);
    pause(0.01);
end
qtcamera_release(camera);

else
    
    img = imread('./test03.png');
    img = rgb2gray(img);
    extract(img);
    
end

end

function extract(gry_img) 
threshold = 100;
bin_img = (gry_img < threshold);
cc = chaincode(bin_img);

step = 2;

minimum_cc_length = 50;

error_rate_threshold = 300;

imshow(bin_img);

hold on;

[w h] = size(bin_img);

for i=1:size(cc, 2)
    points = cc{i};
    diff = zeros(size(points, 1) - step, 3);
    samplingPoints = zeros(size(points, 1) - step, 6);
    for j=1:size(points, 1) - step;
        xyw1 = [points(j,:) 1];
        xyw2 = [points(j + step, :) 1];
        diff(j,:) = xyw1 - xyw2;
        samplingPoints(j,:) = [xyw1 xyw2];
    end
    
    if size(diff,1) > minimum_cc_length
        try
            samplingWidth = floor(size(diff, 1) / 4);
            offset = floor(size(diff, 1) / 8);
            
            seed = zeros(4,3);
            seed(1,:) = diff(offset,:);
            seed(2,:) = diff(offset + samplingWidth,:);
            seed(3,:) = diff(offset + 2 * samplingWidth,:);
            seed(4,:) = diff(offset + 3 * samplingWidth,:);
            
            [idx centers] = kmeans(diff, 4, 'start', seed);
            
            params = zeros(4, 3);
            
            denoise_threshold = 0.2;
            
            sum_error = 0;
            
            for k=1:4
                A = [samplingPoints(find(idx == k),1) samplingPoints(find(idx == k),3)];
                y = samplingPoints(find(idx == k),2);
                p = pinv(A) * y;
                
                error = (A * p - y) .* (A * p - y);
                
                A_denoise = A(find(error < denoise_threshold), :);
                y_denoise = y(find(error < denoise_threshold), :);
                p_denoise = pinv(A_denoise) * y_denoise;
                
                error = (A * p_denoise - y) .* (A * p_denoise - y);
                
                sum_error = sum_error + sum(error);
                
                params(k,1) = p_denoise(1);
                params(k,2) = -1;
                params(k,3) = p_denoise(2);
            end
            
            i
            size(diff,1)
            error_rate = sum_error / size(diff,1)
            
            p = zeros(4, 3);
            p(1,:) = cross(params(1,:), params(2,:));
            p(2,:) = cross(params(2,:), params(3,:));
            p(3,:) = cross(params(3,:), params(4,:));
            p(4,:) = cross(params(4,:), params(1,:));
            p = p ./ repmat(p(:,3), 1 ,3);
            
            fontSize = 10;
            
            
            if (p(1,1) < 0 || p(1,1) > w)
                continue;
            end
            if (p(1,2) < 0 || p(1,2) > h)
                continue;
            end
            
            if (p(2,1) < 0 || p(2,1) > w)
                continue;
            end
            if (p(2,2) < 0 || p(2,2) > h)
                continue;
            end
            
            if (p(3,1) < 0 || p(3,1) > w)
                continue;
            end
            if (p(3,2) < 0 || p(3,2) > h)
                continue;
            end
            
            if (p(4,1) < 0 || p(4,1) > w)
                continue;
            end
            if (p(4,2) < 0 || p(4,2) > h)
                continue;
            end
%             text(   'Interpreter','latex',...
%             'String', sprintf('E=%f L=%d', error_rate, size(diff,1)),...
%             'Position',[p(1,2),p(1,1)],...
%             'FontSize', fontSize,...
%             'Color', 'r')
            
            if error_rate < error_rate_threshold
                plot(p(:,2), p(:,1), 'rx');
                line([p(:,2);p(1,2)], [p(:,1);p(1,1)]);
            end
        catch exception
%             size(diff,1)
%             i
%             cc
%             exception
        end   
    end
end
hold off;

end