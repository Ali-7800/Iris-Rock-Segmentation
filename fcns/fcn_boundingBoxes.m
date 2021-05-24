function box_rects = fcn_boundingBoxes(blobs_bw,ground_mask,no_sky)
    %this function creates non-overlaping bounding boxes for the blobs in a
    %binary image
    
    numCols = size(ground_mask,2);
    numRows = sum(sum(ground_mask))/numCols;


    %tuneable variables (experimental default values/could be changed)
    minArea = 400; %minimum blob area
    maxArea = numRows*numCols/2; %maximum blob area
    minLength = 10; %minimum blob dimension (height or width)
    maxLengthX = 0.6*numCols; %max blob width
    maxLengthY = 0.6*numRows; %max blob height
    maxRegions = 100; %max number of blobs
    dimension_ratio = 0.2; %smallest acceptable ratio of height to width or width to height
    expansionAmount = 0.02; %how much the box size expands
    expansionArea = 1000; %the area of the largest bounding box that is going to be expanded
    
    if no_sky == 1
       dimension_ratio = 0.2; %lower ratio since rocks look different if the image is not frontal
       minArea = 50; %minimum blob area when there is no sky
       minLength = 10; %minimum blob dimension (height or width) when there is no sky
       maxLengthX = 0.8*numCols; %max blob width
       maxLengthY = 0.8*numRows; %max blob height
    end
    
    
    regions = regionprops(blobs_bw,"Area","BoundingBox","Image");
    
    %reduce number of regions until it's below maxRegions
    smallestArea = minArea;
    while size(regions,1) > maxRegions
        blobs_bw = bwareaopen(blobs_bw,smallestArea);
        regions = regionprops(blobs_bw);
        smallestArea = smallestArea + 15;
    end
    regions = regionprops(blobs_bw,"Area","BoundingBox","Image");
    bboxes = cat(1,regions.BoundingBox);
    

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;

    % Expand the bounding boxes by a small amount.
    for i=1:size(bboxes,2)
        if bboxes(i,3)*bboxes(i,4)<expansionArea
            xmin(i) = (1-expansionAmount) * xmin(i);
            ymin(i) = (1-expansionAmount) * ymin(i);
            xmax(i) = (1+expansionAmount) * xmax(i);
            ymax(i) = (1+expansionAmount) * ymax(i);
        end
    end

    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);
    ymin = max(ymin, 1);
    xmax = min(xmax, size(blobs_bw,2)-1);
    ymax = min(ymax, size(blobs_bw,1)-1);

    % Show the expanded bounding boxes
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1); 
    overlapRatio(1:n+1:n^2) = 0;

    % Create the graph
    g = graph(overlapRatio);

    % Find the connected regions within the graph
    componentIndices = conncomp(g);
    
    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = accumarray(componentIndices', xmin, [], @min);
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);

    % Compose the merged bounding boxes using the [x y width height] format.
    boxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    
    box_rects = [];
    %create an array with bounding box dimesions that satisfy all the
    %criteria
    for n = 1:size(boxes,1)
        if boxes(n,3)*boxes(n,4)> minArea && boxes(n,3)>minLength && boxes(n,4)>minLength && boxes(n,3)/boxes(n,4)>dimension_ratio && boxes(n,4)/boxes(n,3)>dimension_ratio
                box_rects = [box_rects;[boxes(n,1),boxes(n,2), boxes(n,3)-0.5, boxes(n,4)-1.5]];
        end
    end
end