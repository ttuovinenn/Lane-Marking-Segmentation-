clear all
close all

for i = 1:20
    img = imread(sprintf('images/%d.jpg', i));
    % run segmentation

figure
imshow(img)
title('Original image')

% converts to HSV
hsvImg = rgb2hsv(img);

H = hsvImg(:,:,1);
S = hsvImg(:,:,2);
V = hsvImg(:,:,3);

% yellow lanes
yellowMask = (H > 0.04 & H < 0.20) & ...
             (S > 0.25) & ...
             (V > 0.35);

% white lanes
whiteMask = (S < 0.30) & (V > 0.7);

% combine
laneMask = yellowMask | whiteMask;

% removes small noise
laneMask = bwareaopen(laneMask,100);

% connects segments
laneMask = imclose(laneMask, strel('disk',3));

% fills holes
laneMask = imfill(laneMask,'holes');

% ROI (bottom half)
[rows, cols] = size(laneMask);

roiMask = false(rows, cols);
roiMask(round(rows*0.5):rows,:) = true;

laneMask = laneMask & roiMask;

% edge filtering
gray = adapthisteq(rgb2gray(img));
edges = edge(gray,'Canny',0.07);

edges = imdilate(edges, strel('disk',2));

laneMask = laneMask & edges;

% rebuilds full lane regions
laneMask = imdilate(laneMask, strel('disk',2));
laneMask = imclose(laneMask, strel('disk',4));
laneMask = imfill(laneMask,'holes');

% removes very thin structures (like road cracks)
laneMask = bwmorph(laneMask,'thicken',1);

laneMask = bwareaopen(laneMask,80);

figure
imshow(laneMask)
title('Binary Lane Mask')

% overlay
overlay = img;
overlay(:,:,1) = uint8(double(overlay(:,:,1)) + 255*double(laneMask));

figure
imshow(overlay)
title('Lane Segmentation Overlay')

end
