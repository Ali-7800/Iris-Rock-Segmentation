function [success,horizon_line,ground_mask] = fcn_horizonDetect1(image)
    %Horizon Detection method #1
    %Uses thresholding to detect the horizon
    
    grayImage = im2gray(image);
    level = graythresh(grayImage); %Global image threshold using Otsu's method
    bw1 = imbinarize(grayImage,level); %Create binary image using the level
    %this usually separates the sky and some shadows from the images
    
    %dialte to get smoother objects
    se = strel("disk",15);
    bw1_dil = imdilate(bw1,se);
    
    %find the objects in the binary images (shadows and sky) and their areas
    A = regionprops(imcomplement(bw1_dil), 'Area');
    areas = cat(1,A.Area);
    
    %sort the objects by area (we are assuming the sky will have the
    %largest area of all the objects)
    areas_sorted = sort(areas,"descend");
    
    
    if size(areas_sorted,1)>1
        %if there is multiple objects in the image remove the smaller
        %objects (presumably shadows)
        biggestShadow = areas_sorted(2); %area of biggest shadow
        %remove all the objects smaller than the biggestShadow +1
        bw2 = imcomplement(bwareaopen(imcomplement(bw1_dil),biggestShadow+1));
        bw2 = bwareaopen(bw2,biggestShadow+1);
    else
        bw2 = imcomplement(imcomplement(bw1_dil));
    end
    
    ground_mask = imerode(bw2,se);
    ground_mask = bwareaopen(ground_mask,10);
    B = regionprops(ground_mask, 'Area');
    
    %we find the edge of the largest objects (the sky) which is the horizon
    %line
    horizon_line = edge(double(ground_mask));
 
    %if there is still multiple objects in the image (for any reason) set
    %the success variable to zero otherwise it is successful
    if size(B,1) > 1 || mean(ground_mask(:,end))==0 || mean(ground_mask(:,1))==0 || mean(sum(horizon_line)>=ones([1 size(horizon_line,2)]))<0.9
        success = 0;
    else
        success = 1;
    end

end