# Iris Rock Segmentation
Iris Rock Segmentation is a MATLAB implementation of the rock detection method outlined in "" the uses a combination of edge detection/range filtering and superpixels to detect rocks/objects in images and accurately localize their boundaries.

![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/diagram.PNG "Block Diagram")

## Related Publications
[1] 

## Main Functions

### rock_segment
Used to detect rocks in a single image from the input folder to the output folder. To use this function just give it the name of an image in the input folder as a string and it would return two binary images **rocksBW** with the rocks detected and **oddBW** (WIP) with the non-rock objects detected. It will also output the **rocksBW** binary image to the output folder and (optionally) the original image with the rock boundaries highlighted.

### process_input
Used to process all the png and jpg images from the input folder to the output folder.


## Sub Functions

### fcn_propertyImages

This functions creates different versions of the image for segementation and stores them in a cell

![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_propertyImages/property_image.jpg "Property Images")

### fcn_horizonDetect1

Takes in an image and attempts to find the horizon line using thresholding








