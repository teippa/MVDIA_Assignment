clc; clearvars; close all;

% This script goes through the process of creating a pre-processed dataset
% and training a densenet201 CNN with transfer learning.

%% Initial definitions

% Should be changed to the path where the original data exists.
dataPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021";

trainDataPath = dataPath + "\CS_train\CS_MVDIA\";
testDataPath = dataPath + "\CS_test\CS_MVDIA\";

trainModel = false; % Set to true if you want to train a new model

%% Prepcocessing

% The processed folders are created to the same directory as the original
% data.
processedFolder_train = "\processed_train\";
processedFolder_test  = "\processed_test\";

trainProcessedPath = dataPath+processedFolder_train;
testProcessedPath  = dataPath+processedFolder_test;

% Training data has max 100 samples per class and failed pre-processings
% are exculded. (So that the nework learns nothing about the scale bar)
preprocess(trainDataPath, trainProcessedPath, 100, true);

% Testing data has max 100 samples per class and failed pre-processings are
% included. (Assuming that every sample needs to be classified)
preprocess(testDataPath, testProcessedPath, 20, false);

%% Read the processed images to imagedatastores

[imdsTrain, auImdsTrain] = getImageDatastores(trainProcessedPath);
[imdsTest, auImdsTest] = getImageDatastores(testProcessedPath);

%% Network training
% Not neccessary to run, the training script uses a pre-trained model if no
% network is defined.

if trainModel
    run("densenet_train.m")
end

%% Network testing

run("densenet_test.m")


