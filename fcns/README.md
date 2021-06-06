# Sub Functions

## fcn_propertyImages

This functions creates different versions of the image for segementation and stores them in a cell

![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_propertyImages/property_image.jpg "Property Images")

## fcn_horizonDetect1

Takes in an image and attempts to find the horizon line by using Otsu's thresholding and removing smaller objects. It works well for the most part but it has it's failure cases

### Successful Case

#### Otsu's Thresholding
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/binary_image.jpg "Otsu's Thresholding")

#### Remove Smaller Objects
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/bw2.jpg "Remove Smaller Objects")

#### Find Ground Edge (horizon)
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/horizon_line.jpg "Horizon Line")

### Failure Case

#### Otsu's Thresholding
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/binary_image.jpg "Otsu's Thresholding")

#### Remove Smaller Objects
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/bw2.jpg "Remove Smaller Objects")

#### Find Ground Edge (horizon)
![alt text](https://github.com/Ali-7800/Iris-Rock-Segmentation/blob/main/viz/fcn_horizonDetect1/fail/horizon_line.jpg "Horizon Line")
