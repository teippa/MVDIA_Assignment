clc; clearvars; close all;

% This is for testing the grayThreshCrop.m function. Might be a bit messy
% code, but I can clean it up later. This script can also be used to save
% copies of the cropper/pre-processed images if needed. It can be set to
% loop through all the images in train or test folder.

saveProcessedImages = false;

dataPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021";

trainDataPath = dataPath + "\CS_train\CS_MVDIA\";
% testDataPath = dataPath + "\CS_test\CS_MVDIA\";

figure; tiledlayout("flow")

dirs = dir(trainDataPath);
for currentDir = dirs(3:end)'
    fprintf("Processing %s images...\n", currentDir.name);
    
    processedPath = fullfile(dataPath, "processed", currentDir.name);
    % Create folders for saving the processed images
    if (saveProcessedImages && ~ isfolder(processedPath))   
        mkdir(processedPath);
    end
    
    imageFiles = dir(fullfile(currentDir.folder, currentDir.name, '/*.png'));
    
    n = 0;
    for imageFile = imageFiles(3)'
        if (mod(n,100) == 0)
            fprintf("%d/%d\n",n, length(imageFiles))
        end
        n = n+1;
        
        imPath = fullfile(imageFile.folder, imageFile.name);
        I = imread(imPath);

        I_square = imresize(I, [227, 227]);
%         
%         mask = createMask(I);
%         
%         C = cropToMask(I, mask);
%         C = imresize(C, [227, 227]);
%         
        C = grayThreshCrop(I);
        
        % Showing the original and cropped images on a grid
        if (n == 1)
            nexttile
            imshowpair(I_square, C, "montage");
            title(currentDir.name)
        end
        

        % Saving the cropped image 
        if (saveProcessedImages)
            writePath = fullfile(processedPath, imageFile.name);
            imwrite(C, writePath)
        end
    end
end
% 
% 
% 
% %%% Functions
% 
% function mask = createMask(I)
% 
%     % Detect the thresholding value. 100px removed from the top to exclude
%     % the white scale text from the thresholding calculations
%     level = graythresh(I(100:end, :));
%     
%     % Binarizing the image according to the threshold value
%     mask = ~imbinarize(I,level);
% 
%     % Removing stray pixels from the binarized mask image
%     mask = imerode(mask, ones(2));
%     
% end
% 
% function C = cropToMask(I, mask)
% 
% % Calculating "side profiles" of the mask
% a = sum(mask,1);
% b = sum(mask,2);
% 
% padding = 20; % add some space around the detected plankton mask
% 
% % Finding the corners of the crop area
% edges = [
%     find(a, 1, "first") - padding % left
%     find(a, 1, "last") + padding  % right
%     find(b, 1, "first") - padding % top
%     find(b, 1, "last") + padding  % bottom
%     ];
% 
% % The added padding may make cropping to exceed image borders, this
% % prevents that
% for i = 1:4
%     if (edges(i) > size(I, 1))
%         edges(i) = size(I, 1);
%     elseif (edges(i) < 1)
%         edges(i) = 1;
%     end
% end
% 
% C = I( ...
%     edges(3) : edges(4), ...
%     edges(1) : edges(2) ...
%     );
% 
% end