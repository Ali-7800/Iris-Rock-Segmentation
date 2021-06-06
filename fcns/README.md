# fcn_propertyImages

This functions creates different versions of the image for segementation and stores them in a cell

![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_propertyImages/property_image.jpg "Property Images")

# fcn_horizonDetect1

Takes in an image and attempts to find the horizon line by using Otsu's thresholding and removing smaller objects. It works well for the most part but it has it's failure cases

## Successful Case

### Otsu's Thresholding
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/binary_image.jpg "Otsu's Thresholding")

### Remove Smaller Objects In Image Complement
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/bw2.jpg "Remove Smaller Objects")

### Find Ground Edge (horizon)
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/horizon_line.jpg "Horizon Line")

## Failure Case

### Otsu's Thresholding
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/binary_image.jpg "Otsu's Thresholding")

### Remove Smaller Objects In Image Complement
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/bw2.jpg "Remove Smaller Objects")

### Find Ground Edge (Not the horizon)
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/horizon_line.jpg "Horizon Line")

# fcn_horizonDetect2
Uses succussive gaussian filtering to remove all of the edges in the image except the most stark one which is between the sky and the ground (theoretically). This works well too but also has some failure cases.

## Successful Case

### Apply a Gaussian Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect2/10_g.jpg "Gaussian Filter")

### Use Edge Detection
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect2/10_edge.jpg "Edge Detection")

### Remove Smaller Objects
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect2/10_rem.jpg "Horizon Line")

## Failure Case
This method would increase the degree of Gaussian filtering if the horizon line is not found after removing the smaller objects and repeat the process again until the horizon is found or the Gaussian filter reaches 5 standard deviations (failure case)

# fcn_horizonDetect3
This method assume that the horizon is a straight horizontal line and finds it by going through all the possible horizontal lines in the image and calculating a rating which measures the total pixel values below the line and subtracts from the pixel values above the line and divides it by the total area below the line. The maximum rating should be the line that maximizes the pixel values below it (the ground where most stuff should be) and minimizes the pixel values above it (the sky where almost nothing should be there) and minimizes the area because otherwise the horizontal line at the very top of the image will always have the maximum rating since everything is below it and nothing is above it. after that we use ```fcn_horizonDetect1``` and ```fcn_horizonDetect2``` to improve the horizon shape. This is the default method used by the main function ```rock_segment``` because it would always about a somewhat accurate horizon line.

![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect3/horizon_line3.gif "Horizon Line Finding")

# fcn_shadowDetect
This function detects the shadows in an image using Otsu's thresholding and the horizon line found from ```fcn_horizonDetect3```.

## Otsu's Thresholding
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_shadowDetect/otsu.jpg "Otsu's Thresholding")

## Take The Complement And Remove The Sky (Anything Above The Horizon)
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_shadowDetect/shadows.jpg "Remove Smaller Objects")

# fcn_blobDetect1
This uses range + std filters to create a rough/blob image for comparison later this method is very experimental nothing is concrete. Can sometimes produce very noisy results.

## Successful Case
### Range Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/range_filter.jpg "Range Filter")
### Range Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/range_blobs.jpg "Range Filter Blobs")
### Std Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/std_filter.jpg "Std Filter")
### Std Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/blobs_std.jpg "Std Filter Blobs")
### Range + Std Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/blobs.jpg "Blobs")

## Failure Case
### Range Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/noise/range_filter.jpg "Range Filter")
### Range Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/noise/range_blobs.jpg "Range Filter Blobs")
### Std Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/noise/std_filter.jpg "Std Filter")
### Std Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/noise/blobs_std.jpg "Std Filter Blobs")
### Range + Std Filter Blobs
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect1/noise/blobs.jpg "Blobs")

# fcn_blobDetect2
Edge based binary filter in case ```fcn_blobDetect1``` result is too noisy. Uses Gaussian Filtering proportional to the noise in the image to reduce it.

## Gaussian Filter
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect2/filter.jpg "Gaussian Filter")
## Edge Detection
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect2/edge.jpg "Edge Detection")
## Close Loops and Fill Holes
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobDetect2/final.jpg "Blobs")

# fcn_blobsExtra
Additional smaller to medium blobs found using thresholding. Works better than the other two methods in finding blobs in synthetic or simulated images.
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_blobsExtra/75.jpg "Blobs")

# fcn_boundingBoxes
This function creates non-overlaping bounding boxes for the blobs in a binary image, this ends the detection part of the algorithm what comes after is related to boundary localization.
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_boundingBoxes/boxes.jpg "Boxes")


# fcn_showBoxes
This function is commented by default, you can uncomment it to show the boxes similar to the ones above, used for debugging purposes in order to know if something went wrong with the blob detection.

# fcn_filter
Gradient filter to make the segmentation rounder, creates a gradient around each blob centroid in a bounding box.

## Single Rock
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_filter/2.jpg "Single Rock")

## Multiple Rocks
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_filter/1.jpg "Multiple Rocks")



