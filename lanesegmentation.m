clear all
close all

img = imread('images/3.jpg');

figure
imshow(img)
title('Original image');

hsvImg = rgb2hsv(img);

H = hsvImg(:,:,1);
S = hsvImg(:,:,2);
V = hsvImg(:,:,3);

yellowMask = (H > 0.05 & H < 0.18) & ...
    (S > 0.35) & ...
    (V > 0.4);

whiteMask = (S < 0.3) & (V > 0.7);

laneMask = yellowMask | whiteMask;

laneMask = bwareaopen(laneMask, 100); % removes small objects
laneMask = imclose(laneMask, strel('disk', 3));
laneMask = imfill(laneMask, 'holes');

[rows, cols] = size(laneMask);

roiMask = false(rows, cols);
roiMask(round(rows*0.5):rows, :) = true;  % keep only bottom half

laneMask = laneMask & roiMask;

figure
imshow(laneMask);
title('Binary Lane Mask');

overlay = img;
overlay(:,:,1) = overlay(:,:,1) + uint8(255 * laneMask);

figure
imshow(overlay);
title('Lane Segmentation Overlay');

for i = 1:20
    filename = sprintf('images/%d.jpg', i);
    img = imread(filename);

    % (repeat pipeline here)

end