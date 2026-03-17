clear all
close all

% Lane Marking Segmentation Script
% processes all images and saves:
% 1) binary masks
% 2) overlay images
% 3) comparison images

% creates results folder if it doesn't exist
if ~exist('results','dir')
    mkdir('results');
end

for i = 1:20
    
    % reads input image
    img = imread(sprintf('images/%d.jpg', i));

    % COLOR-BASED SEGMENTATION (HSV)
    % detects yellow and white lane markings using thresholds
    hsvImg = rgb2hsv(img);

    H = hsvImg(:,:,1);
    S = hsvImg(:,:,2);
    V = hsvImg(:,:,3);

    % yellow lane detection (based on hue, saturation & brightness)
    yellowMask = (H > 0.04 & H < 0.20) & ...
                 (S > 0.25) & ...
                 (V > 0.35);

    % white lane detection (low saturation, high brightness)
    whiteMask = (S < 0.30) & (V > 0.7);

    % combines both masks
    laneMask = yellowMask | whiteMask;

    % MORPHOLOGICAL PROCESSING
    % removes noise and improves connectivity of lane regions

    % removes small noisy regions (for example road textures)
    laneMask = bwareaopen(laneMask,100);

    % connects nearby lane segments
    laneMask = imclose(laneMask, strel('disk',3));

    % fills gaps (holes) inside detected regions
    laneMask = imfill(laneMask,'holes');

    % REGION OF INTEREST (ROI)
    % focuses only on road area (lower part of image)
    [rows, cols] = size(laneMask);

    roiMask = false(rows, cols);
    roiMask(round(rows*0.45):rows,:) = true;

    laneMask = laneMask & roiMask;

    % EDGE FILTERING
    % keeps only regions corresponding to strong edges
    % helps remove flat road regions incorrectly detected as lanes

    % enhances contrast to improve edge detection
    gray = adapthisteq(rgb2gray(img));

    % detects edges (lower threshold helps detect distant lane markings)
    edges = edge(gray,'Canny',0.04);

    % thickens edges slightly to improve overlap with lane regions
    edges = imdilate(edges, strel('disk',2));

    % keeps only pixels that are both color-based and edge-based
    laneMask = laneMask & edges;

    % RECONSTRUCTION OF LANE REGIONS
    % expands edges back into full lane markings

    % expands detected regions
    laneMask = imdilate(laneMask, strel('disk',2));

    % smooths and connects regions
    laneMask = imclose(laneMask, strel('disk',4));

    % fills interior gaps
    laneMask = imfill(laneMask,'holes');

    % FINAL ADJUSTMENTS
    % removes most thin artifacts like cracks and small false positives

    % slight thickening to strengthen lane structures
    laneMask = bwmorph(laneMask,'thicken',1);
    
    % removes remaining small regions
    laneMask = bwareaopen(laneMask,80);

    % VISUALIZATION: OVERLAY
    % highlights detected lanes in red on original image
    overlay = img;
    overlay(:,:,1) = uint8(double(overlay(:,:,1)) + 255*double(laneMask));

    % SAVES RESULTS

    % saves binary mask
    imwrite(laneMask, sprintf('results/mask_%d.png', i));

    % saves overlay image
    imwrite(overlay, sprintf('results/overlay_%d.png', i));

    % converts binary mask to RGB so it can be concatenated
    maskRGB = uint8(repmat(laneMask, [1 1 3])) * 255;

    % creates comparison image (Original | Overlay | Mask)
    comparison = [img overlay maskRGB];

    % saves comparison image
    imwrite(comparison, sprintf('results/comparison_%d.png', i));

    % DISPLAYS RESULTS (for debugging/visual inspection)
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
