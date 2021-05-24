function [ratings,maxIndex,maxImage] = fcn_rate(image,blob_bw,shadow_bw,filter,numSuperpixels,border)
    %this function rates the thresholds of image superpixels compared to
    %the blob_bw
    
    
    %tuneable variables (experimental default values/could be changed)
    std_number = 40; %number of standard deviations in the postive/negative direction
    std_step = 1/20; %how many standard deviations per step
    areaWeight = (sum(sum(blob_bw))+sum(sum(shadow_bw)))/(size(image,1)*size(image,2)); %how much does the area affect the rating (higher value leads to more conservative value)
    borderWeight = sum(sum(border))/sqrt((size(image,1)*size(image,2))); %how much the border affects the segmentation
    shadow2borderRatio = 0.6; %this variable bounds how large the shadows we incorporate into the segmentation
    
    if sum(sum(shadow_bw.*border))/sum(sum(border))<shadow2borderRatio
        blob_bw = shadow_bw+blob_bw;
    end

    
    bw_f = blob_bw.*filter;
    bw_fc = imcomplement(blob_bw).*(ones(size(filter))-filter);
    
    %normalization ratio to make sure the background has equal weight in
    %the difference
    r = sum(sum(bw_f))/sum(sum(bw_fc)); 

    %Create superpixels
    [L,N] = superpixels(image,numSuperpixels);
    idx = label2idx(L);
    imageMean = mean(mean(image));
    imageStd = std2(image);
    meanSPImage = zeros(size(blob_bw));
    for pixel = 1:N
        index = idx{pixel};
        pixelMean = mean(image(index));
        meanSPImage(index) = pixelMean;
    end
    
    %create a list to store all the ratings
    ratings = zeros([2*std_number 1]);
    for j = -std_number:std_number
        binaryImage = false(size(blob_bw));
        binaryImage(meanSPImage>imageMean+j*imageStd*std_step) = 1;
        Area = sum(sum(binaryImage))+1; %segmentation area +1 to prevent dividing by zero
        borderPixels = sum(sum(binaryImage.*border))+1; %number of pixels that lie on the border +1 to prevent dividing by zero
        if borderPixels/sum(sum(border))>0.5 %this checks if we are calculating the area of the rock and not everything surrounding in the box 
             Area = sum(sum(imcomplement(binaryImage)))+1; %segmentation area +1 to prevent dividing by zero
        end
        matchingPixels = sum(sum(binaryImage.*bw_f)); %how many pixels match the rough blob
        nonMatchingPixels = sum(sum(binaryImage.*bw_fc)); %how many pixels do not match the rough blob
        currentRating = (matchingPixels-r*nonMatchingPixels)/((borderPixels^borderWeight)*(Area^areaWeight));
        ratings(j+std_number+1) = currentRating;
    end
    
    %find maximum index
    [maxRating_above,maxIndex_above] = max(ratings);
    [maxRating_below,maxIndex_below] = max(-ratings);

    if maxRating_above > maxRating_below
        maxIndex = maxIndex_above;
        maxIndex = maxIndex-std_number-1;
        maxImage = false(size(blob_bw));
        maxImage(meanSPImage>imageMean+maxIndex*imageStd*std_step) = 1;
        maxIndex = maxIndex+std_number+1;
    else
        maxIndex = maxIndex_below;
        maxIndex = maxIndex-std_number-1;
        maxImage = false(size(blob_bw));
        maxImage(meanSPImage<imageMean+maxIndex*imageStd*std_step) = 1;
        maxIndex = maxIndex+std_number+1;
        ratings = -ratings;
    end

end