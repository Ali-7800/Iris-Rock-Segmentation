function  blobs_extra = fcn_blobsExtra(image,ground_mask,no_sky)
    %additional smaller to medium blobs found using thresholding
    grayImage = im2gray(image);
    
    %tuneable variables (experimental default values/could be changed)
    level = 0.75; %starting level used for thresholding if there is sky
    level_no_sky = 0.6; %starting level used for thresholding if there is no sky
    max_level = 0.9; %level to terminate the loop
    smallest_blob = 400; %smallest blob size to be detected
    largest_blob = 7000; %largest blob size to be detected

    if no_sky == 1
        level = level_no_sky;
    end
        
    maxA = 10000; %intial max area value to start the loop
    
    %loop until the blobs reach the largest_blob size or until level
    %reaches max level
    while (level<max_level && maxA > largest_blob)
        blobs_extra = imbinarize(grayImage,level);
        blobs_extra = bwareaopen(blobs_extra,smallest_blob);
        blobs_extra = logical(blobs_extra.*ground_mask);
        blobs_extra = imclearborder(blobs_extra,4);
        regions_extra = regionprops(blobs_extra);
        areas_extra = cat(1,regions_extra.Area);
        maxA = max(areas_extra);
        if length(areas_extra)<1
            maxA = largest_blob;
        end
        level = level + 0.01; %increment level
    end
end