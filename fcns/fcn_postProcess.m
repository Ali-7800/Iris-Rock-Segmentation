function [rocksBW,oddBW] = fcn_postProcess(rocksBW,sort)
    %posting processing to make the reduce the number of objects below a
    %certain threshold
    
    %tuneable variables (experimental default values/could be changed)
    minArea = 100; %minimum rock area
    maxNumRocks = 40; %maximum number of rocks in an image 
    derivativeTY = 8; %threshold to classify the object as odd
    derivativeTX = 10; %threshold to classify the object as odd
    orientationT = 20;
    momentT = 0.4;
    %averaging filter variables 
    windowSize = 5; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    
    oddBW = zeros(size(rocksBW));
    
    
    rocksBW = bwareaopen(rocksBW,minArea);
    %remove smaller rocks until the number of rocks is below maxNumRocks
    rock_size = minArea;
    while (size(regionprops(rocksBW),1)>maxNumRocks)
        rock_size = rock_size+10;
        rocksBW = bwareaopen(rocksBW,rock_size+1);
    end    
    
    
    %fill holes
    se = strel('disk', 8);
    rocksBW = imdilate(rocksBW,se);
    rocksBW = imfill(rocksBW, "holes");
    rocksBW = imerode(rocksBW,se);
    se_open = strel('disk', 4);
    rocksBW  = imopen(rocksBW,se_open);
    
    L = bwlabel(rocksBW,4);
    regions = regionprops(L,"Area","Centroid",'BoundingBox','Orientation');
    boxes = cat(1,regions.BoundingBox);
    Areas = cat(1,regions.Area);
    Centroids = cat(1,regions.Centroid);
    Orientations = cat(1,regions.Orientation);

    if sort == 1
        for n = 1:max(L,[],"all")
            blobs_bw = (L==n);
            box = boxes(n,:);
            blob_bw = imcrop(blobs_bw,box);
            Area= Areas(n);
            Orientation = Orientations(n);
            c = Centroids(n,:)-[box(1),box(2)];
            y = 1:size(blob_bw, 1);
            x = 1:size(blob_bw, 2);
            D = (y.' - c(1)).^ 2 + (x - c(2)).^ 2;
            I = sum(sum(D.*blob_bw))/Area^2;
            heights = filter(b,a,sum(blob_bw));
            widths = filter(b,a,sum(blob_bw,2));

            %take the heights derivative
            heights_current = [heights,0];
            heights_pre = [0,heights];
            height_dot = heights_current-heights_pre;
            height_dot(1) = [];
            height_dot(1:5) = 0;
            height_dot(max(size(heights,2)-5,1):size(heights,2)) = 0;

            %take the widths derivative
            widths_current = [widths;0];
            widths_pre = [0;widths];
            width_dot = widths_current-widths_pre;
            width_dot(1) = [];
            width_dot(1:5) = 0;
            width_dot(max(size(widths,1)-5,1):size(widths,1)) = 0;

            if (max(abs(height_dot))> derivativeTY || max(abs(width_dot))> derivativeTX || abs(Orientation)>orientationT) && I>momentT
                rocksBW = rocksBW-blobs_bw;
                oddBW = oddBW +blobs_bw;
            end
        end
    end
end