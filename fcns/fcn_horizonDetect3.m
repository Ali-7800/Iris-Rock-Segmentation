function [use_shadows,no_sky,horizon_line,ground_mask] = fcn_horizonDetect3(image)
    %Horizon Detection method #3
    %this method assume that the horizon is a straight horizontal line and
    %finds it by going through all the possible horizontal lines in the
    %image and calculating a rating which measures the total pixel values
    %below the line and subtracts from the pixel values above the line and
    %divides it by the total area below the line. The maximum rating should
    %be the line that maximizes the pixel values below it (the ground where most stuff should be) and
    %minimizes the pixel values above it (the sky where almost nothing
    %should be there) and minimizes the area because otherwise the horizontal line at
    %the very top of the image will always have the maximum rating since everything is below it and nothing is above it.
    %after that we use fcn_horizonDetect1 and fcn_horizonDetect2 to improve
    %the horizon shape
    
    grayImage = rangefilt(imadjust(image));
    numRows = size(image,1);
    numCols = size(image,2);
    bw_0 = zeros(size(image));
    ratings = zeros([floor(numRows/5) 1]);
    use_shadows = 1;
    for i = 1:floor(numRows/5)
        bw = bw_0;
        bw(5*i-4:numRows,:) = 1;
        rating = ((sum(sum(bw.*double(grayImage)))-sum(sum(imcomplement(bw).*double(grayImage)))))/(sum(sum(bw)));
        ratings(i) = rating;
    end
    [maxRating,maxIndex] = max(ratings);

    ground_mask = bw_0;
    horizon_line = bw_0;

    rect = [1,max(5*maxIndex-4-round(numRows/3),1),numCols,min(5*maxIndex-4+round(numRows/3),round(2*numRows/3))];
    crop = imcrop(grayImage,rect);
    if maxIndex > 1
       [success,horizon_line_crop,ground_mask_crop] = fcn_horizonDetect1(crop);
        if success == 1
            ground_mask(rect(1,2):rect(1,2)+rect(1,4),rect(1,1):rect(1,1)+rect(1,3)-1)=ground_mask_crop;
            ground_mask(rect(1,2)+rect(1,4):numRows,1:numCols) = 1;
            horizon_line(rect(1,2):rect(1,2)+rect(1,4),rect(1,1):rect(1,1)+rect(1,3)-1)=horizon_line_crop;
        else
            [success,horizon_line_crop,ground_mask_crop] = fcn_horizonDetect2(crop);
            if success == 1
                ground_mask(rect(1,2):rect(1,2)+rect(1,4),rect(1,1):rect(1,1)+rect(1,3)-1)=ground_mask_crop;
                ground_mask(rect(1,2)+rect(1,4):numRows,1:numCols) = 1;
                horizon_line(rect(1,2):rect(1,2)+rect(1,4),rect(1,1):rect(1,1)+rect(1,3)-1)=horizon_line_crop;
            else
                ground_mask(5*maxIndex-4:numRows,:) = 1;
                horizon_line(5*maxIndex-4,:) = 1;
                use_shadows = 0;
            end
        end
    end

    if maxIndex == 1
        no_sky = 1;
        ground_mask = ones(size(image));
        horizon_line = zeros(size(image));
    else
        no_sky = 0;
    end

    ground_mask = logical(ground_mask);
    horizon_line = logical(horizon_line);
end