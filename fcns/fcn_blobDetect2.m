function  blobs_bw = fcn_blobDetect2(image,ground_mask,noise_level,no_sky)
    %edge based binary filter in case range+std filter is too noisy

    grayImage = im2gray(image);

    %tuneable variables (experimental default values/could be changed)
    sigma_edge = 5+7*(noise_level-0.1); %sigma value for gaussian filter to smooth rock edges
    if no_sky == 1
       sigma_edge = 6+7*(noise_level-0.1); %sigma value for gaussian filter to smooth rock edges
    end
    sigma_blob = 4; %sigma value for gaussian filter to smooth blob image
    edge_method = 'prewitt'; %method used for edge detection

    blobs_bw = imgaussfilt(grayImage,sigma_edge);
    blobs_bw = edge(blobs_bw,edge_method); 
    blobs_bw = blobs_bw.*ground_mask;
    blobs_bw = double(blobs_bw);
    blobs_bw = imgaussfilt(blobs_bw,sigma_blob);
    blobs_bw = imbinarize(blobs_bw);
    se = strel('disk',10);
    blobs_bw = imdilate(blobs_bw,se);
    blobs_bw = imfill(blobs_bw,"holes");
    blobs_bw = imerode(blobs_bw,se);
    blobs_bw = blobs_bw.*ground_mask;

end