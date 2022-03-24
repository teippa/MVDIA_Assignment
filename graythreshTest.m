clc; clearvars; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS SCRIPT IS NOT USED
% Replaced by preprocess.m & main.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is for testing the grayThreshCrop.m function. Might be a bit messy
% code, but I can clean it up later. This script can also be used to save
% copies of the cropper/pre-processed images if needed. It can be set to
% loop through all the images in train or test folder.

saveProcessedImages = true;

dataPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021";

trainDataPath = dataPath + "\CS_train\CS_MVDIA\";
testDataPath = dataPath + "\CS_test\CS_MVDIA\";

resultsFolder = "processed_train";
% resultsFolder = "processed_test";

figure; tiledlayout("flow");

dirs = dir(trainDataPath);
for currentDir = dirs(3:end)'
    fprintf("Processing %s images...\n", currentDir.name);
    
    processedPath = fullfile(dataPath, resultsFolder, currentDir.name);
    % Create folders for saving the processed images
    if (saveProcessedImages && ~ isfolder(processedPath))   
        mkdir(processedPath);
    end
    
    imageFiles = dir(fullfile(currentDir.folder, currentDir.name, '/*.png'));

    
    n = 0;
    for imageFile = imageFiles'
        if (mod(n,100) == 0)
            fprintf("%d/%d\n",n, length(imageFiles))
            
        end
        if (n>=200) 
            % Setting a limit on how many images are processed. This
            % prevents some of the classes having too many datapoints in
            % relation to other classes.
            % I used 100 for training and 20 for testing
            break;
        end

        n = n+1;
        
        imPath = fullfile(imageFile.folder, imageFile.name);
        I = imread(imPath);

        I_square = imresize(I, [227, 227]);
%         max(I_square, 'all')
%         
%         mask = createMask(I);
%         
%         C = cropToMask(I, mask);
%         C = imresize(C, [227, 227]);
%         
%         I_square = unit8(255* I_square./max(I_square, [], 'all'));

        [C, cropSuccesful] = grayThreshCrop(I);
        
        if ~cropSuccesful
            fprintf("Cropping failed\n");
            n = n-1;
            continue
        end

        % Showing the original and cropped images on a grid
        if (n == 1)
            nexttile
            imshowpair(I_square, C, "montage");
            title(currentDir.name)
        end
        
        % Saving the cropped image 
        if (saveProcessedImages && cropSuccesful)
            writePath = fullfile(processedPath, imageFile.name);
            imwrite(histeq(C), writePath)
        end
    end
end
