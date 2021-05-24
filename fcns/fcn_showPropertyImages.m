function fcn_showPropertyImages(propertyImages,image)
    for property = 1:size(propertyImages,2)
        propertyImage = propertyImages{property};
        subplot(3,3,property)
        imshowpair(image,propertyImage,"montage")
        sgtitle("Image Under Different Filters/Color Spaces")
    end
end