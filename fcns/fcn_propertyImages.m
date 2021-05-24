function propertyImages = fcn_propertyImages(image)
    %This functions creates different versions of the image for
    %segementation and stores them in a cell
    
    if size(image,3) < 3
        image = cat(3, image, image, image);
    end
    
    
    
    grayImage = im2gray(image);
    entropy = entropyfilt(grayImage);
    rangeImage = rangefilt(grayImage);
    stdImage = stdfilt(grayImage);
    YCbCrImage = rgb2ycbcr(image);
    hsvImage = rgb2hsv(image);

    
    propertyImages = [];
    propertyImages{1} = hsvImage(:,:,1); %hue
    propertyImages{2} = hsvImage(:,:,2); %saturation
    propertyImages{3} = YCbCrImage(:,:,3); %Cr
    propertyImages{4} = YCbCrImage(:,:,2); %Cb
    propertyImages{5} = YCbCrImage(:,:,1); %luminance
    propertyImages{6} = entropy; %entropy filter image
    propertyImages{7} = rangeImage; %range filter image
    propertyImages{8} = stdImage; %std filter image


end