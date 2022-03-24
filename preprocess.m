function [] = preprocess(dataPath, savePath, maxSamples, excludeFailedCrop)
% This function is used to preprocess the plankton images. Processed images
% are saved to a new directory.
% 
%   dataPath:   [String]
%               Path to the original data. Each class in its own folder
%
%   savePath:   [String]
%               Path to the forder, where the processed images are saved.
% 
%   maxSamples: [Integer]
%               Maximum number of samples that should be in each class. 
%               The dataset is very unbalanced. This balances the dataset,
%               without losing too much datapoints.
% 
%   excludeFailedCrop:  [Boolean]
%                       The preprocessing method does not work every time.
%                       The error rate is aroun 2%. This variable
%                       determines if the failed attempts should be
%                       excluded from the processed images.

failedCrops = 0;
imagesProcessed = 0;

dirs = dir(dataPath);
for currentDir = dirs(3:end)'
    fprintf("Processing %s images...\n", currentDir.name);
    
    processedPath = fullfile(savePath, currentDir.name);
    % Create folders for saving the processed images
    if (~isfolder(processedPath))   
        mkdir(processedPath);
    end
    
    imageFiles = dir(fullfile(currentDir.folder, currentDir.name, '/*.png'));

    
    n = 0;
    for imageFile = imageFiles'
        imagesProcessed = imagesProcessed+1;
        if (mod(n,100) == 0)
            fprintf("%d/%d\n",n, length(imageFiles))
        end

        if (n>=maxSamples) 
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

        [C, cropSuccesful] = grayThreshCrop(I);
        
        if (~cropSuccesful && excludeFailedCrop)
            fprintf("Cropping failed\n");
            n = n-1;
            failedCrops = failedCrops + 1;
            continue
        end

        % Showing the original and cropped images on a grid
        if (n == 1)
            nexttile
            imshowpair(I_square, histeq(C), "montage");
            title(currentDir.name)
            sgtitle("Sample of processed images.")
        end
        
        % Saving the cropped image 
        if (cropSuccesful)
            writePath = fullfile(processedPath, imageFile.name);
            imwrite(histeq(C), writePath)
        end
    end
end

fprintf("%d images processed, %d excluded because of failed preprocess.\n", imagesProcessed, failedCrops)

end