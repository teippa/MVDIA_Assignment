% This script is for training a densenet201.
% There needs to be some variables in the workspace, so it's recommended to
% be run from the main.m script


%% Net setup (Following MATLAB GoogLeNet example)
% https://se.mathworks.com/help/releases/R2019b/deeplearning/examples/train-deep-learning-network-to-classify-new-images.html

net = densenet201;


inputSize = net.Layers(1).InputSize;

%analyzeNetwork(net)
lgraph = layerGraph(net);

[learnableLayer,classLayer] = findLayersToReplace(lgraph);
%[learnableLayer,classLayer] 

numClasses = numel(categories(imdsTrain.Labels));

% Create new layer
if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end

% Replace layer with new one
lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

% Replace old classification layer
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);

if 1==0 % Plot network?
    figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
    plot(net)
    ylim([0,10])
end

layers = lgraph.Layers;
connections = lgraph.Connections;

% layers(1:10) = freezeWeights(layers(1:10));
lgraph = createLgraphUsingConnections(layers,connections);

fprintf("Network created.\n");

%% Training (Following MATLAB GoogLeNet example)

% How many images are processed on each trainin cycle. Determines how much 
% memory is used while training
miniBatchSize = 20; 

valFrequency = floor(numel(auImdsTrain.Files)/miniBatchSize /2);
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',10, ... % How many times the whole dataset is processed
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',auImdsTest, ...
    'ValidationFrequency',valFrequency, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment','cpu' ...
    );


net = trainNetwork(auImdsTrain,lgraph,options);
