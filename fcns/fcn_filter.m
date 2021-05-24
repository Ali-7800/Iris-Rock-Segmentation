function filter = fcn_filter(blob_bw)
    %gradient filter to make the segmentation rounder
    regions = regionprops(blob_bw,"Centroid","Area");
    Centroids =  cat(1,regions.Centroid);
    Areas = cat(1,regions.Area);
    filter = zeros([size(blob_bw) size(Centroids,1)]);

    for n=1:size(filter,3)
        M = sqrt(Areas(n)/pi);
        xc = Centroids(n,1);
        yc = Centroids(n,2);
        for i=1:size(filter,1)
            for j = 1:size(filter,2)
                filter(i,j,n) = M/(((xc-j))^2+((yc-i))^2+M);
            end
        end 
    end
    
    filter = sum(filter,3);
   
end