function [success,horizon_line,ground_mask] = fcn_horizonDetect2(image)
    %Horizon Detection method #2
    %Uses succussive gaussian filtering to remove all of the edges in the
    %image except the most stark one which is between the sky and the
    %ground
    

    
    grayImage = imadjust(im2gray(image));
    sigma = 1; % intial gaussian filter sigma value
    numCols = size(image,2);
    two_regions = 0; % variable used to determine if there two regions in the image (sky and ground)
        
        no_sky = 0;
        % loop over sigmas until the image is segmented into two regions, if not
        % assume there is no sky in the image
        while (sigma < 5 && two_regions == 0)
            grayImage_filtered = imgaussfilt(grayImage,sigma);
            bw = edge(grayImage_filtered,'Prewitt');
            bw = bwareaopen(bw,300);
            bw = imgaussfilt(double(bw),1);
            bw = imbinarize(bw);
            bw = imcomplement(bw);
            C = regionprops(bw,'Area');
            if size(C,1) == 2
                two_regions = 1;
            end
            areas = cat(1,C.Area);
            if max(areas) < 10*numCols
                two_regions = 0;
            end
            sigma = sigma + 0.1; %increase sigma for next iteration
        end

        CC = bwconncomp(bw);
        L = labelmatrix(CC);
        

        %create the a mask for the ground and for the horizon line
        success = 0;
        if two_regions == 1
            horizon_line = imcomplement(bw);
            L(L==1) = 0;
            L(L==2) = 1;
            ground_mask = imbinarize(L);
            se = strel("disk",2);
            ground_mask = imdilate(ground_mask,se);
            ground_mask = imfill(ground_mask,"holes");
            ground_mask = imerode(ground_mask,se);
            if  mean(ground_mask(:,end))>0 && mean(ground_mask(:,1))>0 && mean(sum(horizon_line)>=ones([1 size(horizon_line,2)]))>0.9
                success = 1;
            end
        else
            horizon_line = logical(zeros(size(image)));
            ground_mask = logical(ones(size(image)));
            success = 0;
        end
end