# Lane Marking Segmentation using Image Processing (MATLAB)

This project implements a classical computer vision pipeline to detect road lane markings from driving scene images using MATLAB.

## Overview

The goal of this project is to segment lane markings (white and yellow) from road images and produce:

- Binary segmentation masks
- Overlay visualizations highlighting detected lanes
- Comparison images (original vs overlay vs mask)

## Methods

The solution is based on classical image processing techniques:

- HSV color segmentation (yellow & white detection)
- Canny edge detection
- Morphological filtering (noise removal, region reconstruction)
- Region of interest (ROI) masking

## Pipeline 

1. Convert image from RGB to HSV
2. Detect yellow and white lane pixels using thresholding
3. Remove noise using morphological operations
4. Apply ROI to focus on road area
5. Refine segmentation using edge detection
6. Reconstruct lane regions and generate final mask
7. Create overlay visualization

## Project Structure
images/          # Input images
results/         # Output images (generated)
lanesegmentation.m

## Example results

<img width="3840" height="720" alt="comparison_3" src="https://github.com/user-attachments/assets/7952af48-74ce-48d0-b0cc-a7796d8a2396" />

<img width="3840" height="720" alt="comparison_20" src="https://github.com/user-attachments/assets/3f3216f5-b27a-4e95-b08d-1cc49d7d8d3e" />

<img width="3840" height="720" alt="comparison_14" src="https://github.com/user-attachments/assets/58a27997-3775-48cc-a6e8-9bab9265b349" />

## Limitations

- Sensitive to lighting conditions
- May detect road cracks or textures as lane markings
- Distant lane markings may be missed

## Technologies
- MATLAB
- Image Processing Toolbox

# References / Inspiration
- MATLAB documentation https://www.mathworks.com/help/matlab/index.html
- MATLAB Image Processing Toolbox Documentation https://www.mathworks.com/help/images/index.html
- Classical lane detection approaches (for example Hough Transform methods)
