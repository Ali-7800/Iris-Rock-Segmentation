function rockBW_refined = fcn_refineSegmentation(rockBW,shadow_bw)
    %This function refines the rock segmentation by (dilation, filling
    %holes, erosion) and taking shadows
    %into account
    border = fcn_border(rockBW,3,1);
    
    %tuneable variables (experimental default values/could be changed)
    shadow2rockRatio = 2; %this variable bounds how large the shadows we incorporate into the segmentation
    shadow2borderRatio = 0.3; %this variable to ensure that the shadow is enclosed by the bounding box
    
    %variables
    shadow2border = sum(sum(shadow_bw.*border))/sum(sum(border));
    rock2border = sum(sum(rockBW.*border))/sum(sum(border));
    shadow2rock = sum(sum(shadow_bw))/(sum(sum(rockBW)));
    
    if rock2border>0.5
        rockBW = imcomplement(rockBW);
    end
    
    %take shadows into account 
    if (shadow2border>shadow2borderRatio || shadow2rock>shadow2rockRatio)
        rockBW = double(rockBW)-double(shadow_bw);
        rockBW(rockBW==-1)=0;
        rockBW = logical(rockBW);
    elseif (shadow2border<=shadow2borderRatio && shadow2rock<shadow2rockRatio)
        rockBW = rockBW + shadow_bw;
    end
    
    %fill holes in segmentation
    se_45 = strel('line', 7, 45);
    se_135 = strel('line', 7, 135);
    se_diamond = strel('diamond', 3);
    rockBW = imdilate(rockBW,se_45);
    rockBW = imdilate(rockBW,se_135);
    rockBW = imfill(rockBW, "holes");
    rockBW = imerode(rockBW,se_diamond);
    
    %remove long thing appendages
    se_open = strel("disk",3);
    rockBW = imopen(rockBW,se_open); 
    
    %remove tiny objects in segmentation
    rockBW_refined = bwareaopen(rockBW,20);

end