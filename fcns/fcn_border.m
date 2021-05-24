function border = fcn_border(blob_bw,thickness,borderValue)
    %this creates a border around the image for segmentation purposes
    %tuneable variables (experimental default values/could be changed
    
    border = zeros(size(blob_bw));
    for i=1:thickness
        border(:,i) = borderValue;
        border(i,:) = borderValue;
        border(:,end-i+1) = borderValue;
        border(end-i+1,:) = borderValue;
    end

end