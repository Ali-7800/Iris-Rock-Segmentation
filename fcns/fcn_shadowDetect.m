function shadows_bw = fcn_shadowDetect(image,ground_mask,horizon_line,no_sky)
    %This function detects the shadows in an image using Otsu's method
    
    %tuneable variables (experimental default values/could be changed)
    maxShadows = 400; %number of shadow objects in the image
    level_no_sky = 0.05; %thresholding value when sky is not present
    smallestShadow = 10; %size of the smallest shadow in the image
    
    grayImage = im2gray(image);
    
    %threshold using Otsu's method
    level = graythresh(grayImage);
    bw1 = imbinarize(grayImage,level);

    
    %restrict shadows to ground
    se_horizon = strel('disk',1);
    bw2 = double(bw1) - double(imdilate(horizon_line,se_horizon))-double(horizon_line);
    bw2(bw2 <= -1) = 1;
    bw2 = logical(bw2);
    shadows_bw = logical(imcomplement(bw2).*ground_mask).*ground_mask;

    
    %remove smallest shadow
    shadows_bw = bwareaopen(shadows_bw,smallestShadow);
    
    %if there is no sky
    if no_sky == 1
        shadows_bw = imcomplement(imbinarize(grayImage,level_no_sky));
    end
    
    %remove smaller shadows until the number of shadows is below maxShadows
    shadow_size = smallestShadow;
    while (size(regionprops(shadows_bw),1)>maxShadows)
        shadows_bw = bwareaopen(shadows_bw,shadow_size+1);
        shadow_size = shadow_size+10;
    end
    
%     %fill holes in the shadow
     se = strel("diamond",2);
     shadows_bw = imdilate(shadows_bw,se);
     shadows_bw = imfill(shadows_bw, "holes");
     se = strel("diamond",1);
     shadows_bw = imerode(shadows_bw,se);
%     shadows_bw = shadows_bw.*ground_mask;

end