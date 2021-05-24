function  [blobs_bw,noise_level] = fcn_blobDetect1(image,horizon_line,ground_mask,shadows_bw,no_sky)
    %This uses range + std filters to create a rough/blob image for comparison
    %later
    %this method is very experimental nothing is concrete
    
    %tuneable variables (experimental default values/could be changed)
    sigma_range = 5; %sigma value for gaussian filtered image for range filter
    sigma_std = 5;  %sigma value for gaussian filtered image for std filter
    std_minArea = 5000; % minimum area for std filtered image
    if no_sky == 1
        sigma_range = 6; %sigma value for gaussian filtered image for range filter when there is no sky
        sigma_std = 6;  %sigma value for gaussian filtered image for std filter when there is no sky
        std_minArea = 500;
    end
    free_space = 0.65*size(image,1)*size(image,2); %minimum free ground space to use std blob image
    
    grayImage = im2gray(image);
    
    
    %blobs from range filter
    range_filt = rangefilt(imgaussfilt(grayImage,sigma_range));
    blob_level = graythresh(range_filt(ground_mask));
    blobs_range = imbinarize(range_filt,blob_level);


    %blobs from std filter
    std_filt= stdfilt(imgaussfilt(grayImage,sigma_std));
    blobs_std = imbinarize(std_filt,1);
    blobs_std = bwareaopen(blobs_std,std_minArea);
    blobs_std = imclearborder(blobs_std,4);
    
    
    if sum(sum(ground_mask))-sum(sum(shadows_bw))>free_space %check if the ground mask is large enough
        blobs_bw = blobs_range +blobs_std; %add blobs from both filters
    else
        blobs_bw = blobs_range;
    end
    
    %this removes the blobs close to the horizon by adding the horizon, filling holes and
    %removing a dilated horizon horizon
    blobs_bw = blobs_bw + horizon_line;
    se_holes = strel('disk',1);
    blobs_bw = imdilate(blobs_bw,se_holes);
    blobs_bw = imfill(blobs_bw,"holes");
    blobs_bw = imerode(blobs_bw,se_holes);
    se_horizon = strel('disk',10);
    blobs_bw = double(blobs_bw) - double(imdilate(horizon_line,se_horizon))-double(horizon_line);
    blobs_bw(blobs_bw == -1) = 0;
    blobs_bw = logical(blobs_bw);
    se_sharpen = strel('diamond',3);
    blobs_bw = imerode(blobs_bw,se_sharpen);

    
    %This estimates the how much of the ground is covered by blobs
    noise_level = sum(sum(ground_mask.*blobs_bw))/sum(sum(ground_mask));
end