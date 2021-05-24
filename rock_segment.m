function [rocksBW,oddBW] = rock_segment(imageName)
    %Author: Ali Albazroun
    tic
    addpath fcns
    addpath input
    
    %read image and get its property images
    originalImage = imread(imageName);
    originalImage = imresize(originalImage,2);
    propertyImages = fcn_propertyImages(originalImage);
    numRows = size(originalImage,1);
    numCols = size(originalImage,2);     
    
    %detect horizon and ground
    [use_shadows,no_sky,horizon_line,ground_mask] = fcn_horizonDetect3(propertyImages{5});
    
    %detect shadows
    shadows_bw = fcn_shadowDetect(originalImage,ground_mask,horizon_line,no_sky);
    
    %detect blobs
    [blobs_bw,noise_level] = fcn_blobDetect1(originalImage,horizon_line,ground_mask,shadows_bw,no_sky);
    
    if noise_level>0.1
       blobs_bw = fcn_blobDetect2(originalImage,ground_mask,noise_level,no_sky                                                                                                                                                                                                                           ); 
    end
    
    blobs_extra = fcn_blobsExtra(originalImage,ground_mask,no_sky);
    
    if no_sky == 0
        blobs_bw = blobs_bw + blobs_extra;
    end
    blobs_bw  = imgaussfilt(double(blobs_bw),2);
    blobs_bw  = logical(double(blobs_bw));
    
    %create bounding boxes for blobs
    box_rects = fcn_boundingBoxes(blobs_bw,ground_mask,no_sky);

    %uncomment this if you want to show bounding boxes
    %fcn_showBoxes(originalImage,box_rects)
    
    
    rocksBW = zeros([numRows numCols]);
    rock_bws = {};
    
    for n = 1:size(box_rects,1) %loop over all the bounding boxes
        box_rect = box_rects(n,:);
        %create rough rock blob to compare for segmentation
        blob_bw = imcrop(blobs_bw,box_rect);
        shadow_bw = imcrop(shadows_bw,box_rect)*use_shadows;
        rockBW =  (zeros(size(blob_bw)));
        
        numSuperpixels = 2*floor(sqrt(size(blob_bw,1)*size(blob_bw,2))); %Number of superpixels determines how segemented the image is going to be
        filter = fcn_filter(blob_bw);            
        border = fcn_border(blob_bw,2,1);
        
        binaryImageSum = (zeros(size(blob_bw)));
        maxImages = {};
        maxRatings = [];
        for property = 1:size(propertyImages,2)
            %crop image to compare to blob
            image = double(propertyImages{property});
            image = imcrop(image,box_rect);
            
            [ratings,maxIndex,maxImage] = fcn_rate(image,blob_bw,shadow_bw,filter,numSuperpixels,border);
            white_rect = ones(size(maxImage));
            maxRating = ratings(maxIndex);
            if sum(sum(white_rect.*maxImage))/sum(sum(white_rect))<0.95 && maxRating>-1
                binaryImageSum =  binaryImageSum + double(maxImage);
            else
                maxImage = zeros(size(maxImage));
                maxRating = 0;
            end
            
            maxImages{property} = maxImage;
            maxRatings = [maxRatings,maxRating];
            
        end

        
        method_1 = rockBW;
        
        %final image method 1 (mean of all property images)
        meanAppearence = mean2(binaryImageSum);
        method_1(binaryImageSum>meanAppearence) = 1;
        method_1 = logical(method_1);

        %final image method 2 (max of all property images)
        [max_maxRating,maxImage_index] = max(maxRatings);
        method_2 = maxImages{maxImage_index};

        bw_f = blob_bw.*filter;
        bw_fc = imcomplement(blob_bw).*(ones(size(filter))-filter);
        %normalization ratio to make sure the background has equal weight in
        %the difference
        r = sum(sum(bw_f))/sum(sum(bw_fc)); 
        
        %finalize based on rating
        rating_1 = sum(sum(method_1.*bw_f))-r*sum(sum(method_1.*bw_fc))/sum(sum(method_1));
        rating_2 = sum(sum(method_2.*bw_f))-r*sum(sum(method_2.*bw_fc))/sum(sum(method_2));  

        if rating_1>rating_2
            bestRating = rating_1;
            rockBW = method_1;
        else
            bestRating = rating_2;
            rockBW = method_2;
        end

        if bestRating <= 0 %fall back to rough blob if best rating is less than or equal to zero
           rockBW = blob_bw;
        end
        rockBW = fcn_refineSegmentation(rockBW,shadow_bw);
        rock_bws{n} = rockBW;
    end
    
    
    %this combines all the single segmented rocks into a single image
    for n = 1:size(box_rects,1)
        rockBW = rock_bws{n};
        box_rect = box_rects(n,:);
        rocksBW(round(box_rect(2)):round(box_rect(2)+box_rect(4)),round(box_rect(1)):round(box_rect(1)+box_rect(3))) = rockBW|rocksBW(round(box_rect(2)):round(box_rect(2)+box_rect(4)),round(box_rect(1)):round(box_rect(1)+box_rect(3)));
    end
    
    %post process the image to identify odd objects, reduce the number of rocks and make the segmentation smoother
    [rocksBW,oddBW] = fcn_postProcess(rocksBW,0);

    outputName = pwd + "/output/" + strcat("output_",imageName);
    imwrite(rocksBW,outputName);
    
    %uncomment this if you want to show the rock segmentation over the image
    fcn_overlay(originalImage,rocksBW,oddBW,imageName)
    toc
end