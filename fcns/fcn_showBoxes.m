function fcn_showBoxes(image,boxes)
    figure
    imshow(image)
    %create an image with bounding boxes
    hold on
    for n = 1:size(boxes,1)
        rectangle('Position', [boxes(n,1), boxes(n,2), boxes(n,3), boxes(n,4)],'EdgeColor','r', 'LineWidth', 2)
        roi = images.roi.Rectangle('Position', [boxes(n,1), boxes(n,2), boxes(n,3), boxes(n,4)]);
    end
    hold off
end