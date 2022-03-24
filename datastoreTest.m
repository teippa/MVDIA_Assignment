clc; clearvars; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS SCRIPT IS NOT USED
% Replaced by getImageDatastores.m & main.m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Testing how to create and use datastores
% Augmented datastore does not seem to work with transform function, not
% sure if it will be a problem

% The transform function lets us to use custom cropping function for the
% images. If it works well, it would be nice to use since then we don't
% need to save copies of the pre-processed images to hard drive.

dataPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021";

% trainDataPath = dataPath + "\CS_train\";
% testDataPath = dataPath + "\CS_test\";
trainDataPath = dataPath + "\processed_train\";
testDataPath = dataPath + "\processed_test\";

% creating imagedatastores for training and testing
imdsTrain = getImds(trainDataPath);
imdsTest = getImds(testDataPath);

auImdsTrain = getAugmentedImds(imdsTrain);
auImdsTest = getAugmentedImds(imdsTest);

%% Testing the transform function, 
% but the transferdatastore object can't be used for NN training so this is
% not really a useful section


imdsTrainCrop = transform(imdsTrain,@(x) grayThreshCrop(x));
imdsTestCrop = transform(imdsTest,@(x) grayThreshCrop(x));

figure(1)

im1 = read(auImdsTrain);
im2 = read(imdsTest);

subplot(221); imshow(im1); axis on; title('Original');
subplot(222); imshow(im2); axis on; title('Original');

im1 = read(imdsTrainCrop);
im2 = read(imdsTestCrop);

subplot(223); imshow(im1); axis on; title('Cropped');
subplot(224); imshow(im2); axis on; title('Cropped');



%% Functions

function imds = getImds(path)
    % Get imagedatastore

    imds = imageDatastore(path,...
        'IncludeSubfolders',true,...
        'LabelSource', 'foldernames' ...
        );

    % Downsampling to make the classes balanced
    labelCount = countEachLabel(imds);
%     imds = splitEachLabel(imds, min(labelCount{:,2}));
    
    fprintf("%d images with %d classes loaded from %s. (Average of %d samples per class)\n", ...
        length(imds.Labels), ...
        length(unique(imds.Labels)), ...
        inputname(1), ...
        round(mean(labelCount{:,2}))...
        );

end

function auimds = getAugmentedImds(imds)
    imageSize = [224 224 3];
    

    augmenter = imageDataAugmenter( ...
        'RandRotation',     @() 90*randi([0 3]), ...
        'RandXReflection',    true, ...
        'RandYReflection',    true ...
    );

    %subImds = subset(imdsFull, (1:6)+500);
    auimds = augmentedImageDatastore(imageSize,...
        imds, ...
        'DataAugmentation',     augmenter, ...
        'DispatchInBackground', true ...
    );

end
