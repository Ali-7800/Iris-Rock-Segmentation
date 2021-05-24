function fcn_overlay(image,rocksBW,oddBW,imageName)
    %this function overlays the segementation overtop the original image to
    %make it easier to visualize the output
    outputName = pwd + "/output/" + strcat("overlay_",imageName);

    if size(image,3) < 3
        image = cat(3, image, image, image);
    end
    
    rockImage = image(:,:,1);
    rockOutlines = bwperim(rocksBW);
    rockOutlines = imdilate(rockOutlines, true(3));
    rockImage(rockOutlines) = 255;
    image(:,:,1) = rockImage;
    
    oddImage = image(:,:,3);
    oddOutlines = bwperim(oddBW);
    oddOutlines = imdilate(oddOutlines, true(5));
    oddImage(oddOutlines) = 255;
    image(:,:,3) = oddImage;
    
    figure
    imshow(image)
    imwrite(image,outputName);
end