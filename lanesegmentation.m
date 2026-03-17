clear all
close all

% this script processes all images and saves results
% (mask, overlay, comparison)

% creates results folder if it doesn't exist
if ~exist('results','dir')
    mkdir('results');
end

for i = 1:20

    img = imread(sprintf('images/%d.jpg', i));

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
    roiMask(round(rows*0.45):rows,:) = true;

    laneMask = laneMask & roiMask;

    % edge filtering
    gray = adapthisteq(rgb2gray(img));
    edges = edge(gray,'Canny',0.04);

    edges = imdilate(edges, strel('disk',2));

    laneMask = laneMask & edges;

    % rebuilds full lane regions
    laneMask = imdilate(laneMask, strel('disk',2));
    laneMask = imclose(laneMask, strel('disk',4));
    laneMask = imfill(laneMask,'holes');

    % removes very thin structures
    laneMask = bwmorph(laneMask,'thicken',1);

    laneMask = bwareaopen(laneMask,80);

    % --- creates overlay ---
    overlay = img;
    overlay(:,:,1) = uint8(double(overlay(:,:,1)) + 255*double(laneMask));

    % --- saves results ---

    % saves binary mask
    imwrite(laneMask, sprintf('results/mask_%d.png', i));

    % saves overlay
    imwrite(overlay, sprintf('results/overlay_%d.png', i));

    % converts binary mask to RGB so it can be concatenated
    maskRGB = uint8(repmat(laneMask, [1 1 3])) * 255;

    % creates comparison image (Original | Overlay | Mask)
    comparison = [img overlay maskRGB];

    % saves comparison image
    imwrite(comparison, sprintf('results/comparison_%d.png', i));

    % displays results
    figure
    imshow(img)
    title(sprintf('Original image %d', i))

    figure
    imshow(laneMask)
    title(sprintf('Binary Lane Mask %d', i))

    figure
    imshow(overlay)
    title(sprintf('Lane Segmentation Overlay %d', i))

end
