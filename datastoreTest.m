clc; clearvars; close all;

% Testing how to create and use datastores
% Augmented datastore does not seem to work with transform function, not
% sure if it will be a problem

% The transform function lets us to use custom cropping function for the
% images. If it works well, it would be nice to use since then we don't
% need to save copies of the pre-processed images to hard drive.

dataPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021";

trainDataPath = dataPath + "\CS_train\";
testDataPath = dataPath + "\CS_test\";

% creating imagedatastores for training and testing
imdsTrain = getImds(trainDataPath);
imdsTest = getImds(testDataPath);

% auImdsTrain = getAugmentedImds(imdsTrain);
% auImdsTest = getAugmentedImds(imdsTest);

imdsTrainCrop = transform(imdsTrain,@(x) grayThreshCrop(x));
imdsTestCrop = transform(imdsTest,@(x) grayThreshCrop(x));








%%
figure(1)

im1 = read(imdsTrain);
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
    
    fprintf("%d images with %d classes loaded from %s.\n", ...
        length(imds.Labels), ...
        length(unique(imds.Labels)), ...
        inputname(1) ...
        );

end

function auimds = getAugmentedImds(imds)
    imageSize = [227 227 3];
    %imageSize = [1080 720 3];

    scale = 1;

    %originalImageSize = [3264 2448];
    %translateYX_ifNoRotation = scale*originalImageSize/2 - originalImageSize/2;

    % It seems that the translation is done before rotation, so the correct
    % translation amount is difficult to determine so that we stay inside the
    % picture borders. If we want variable scaling values, the translation task
    % is even more complex.
    translateYX = [0 0]; % has to be smaller than [1400 1000] when scale = 3
    
    augmenter = imageDataAugmenter( ...
        'RandScale',        [scale, scale], ...
        'RandRotation',     [45 45], ...
        'RandXTranslation', [1, 1]*translateYX(1), ...
        'RandYTranslation', [1, 1]*translateYX(2) ...
    );

    %subImds = subset(imdsFull, (1:6)+500);
    auimds = augmentedImageDatastore(imageSize,...
        imds, ...
        'DispatchInBackground', true);

end
