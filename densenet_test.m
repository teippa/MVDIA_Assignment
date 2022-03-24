% This script is for testing the accuracy of the trained network.
% It can be run independently, or from the main.m after training a new
% model. When run independently, the pestProcessedPath needs to be changed.

%% Loading variables if they have not been defined yet

if (0 == exist("imdsTest", "var") || 0 == exist("auImdsTest", "var"))
    testProcessedPath = "D:\Users\Teijo\Documents\MVDIA\MVDIA_CS_2021\processed_test\";
    [imdsTest, auImdsTest] = getImageDatastores(testProcessedPath);
end

if (0 == exist("net", "var"))
    load("densenet_pretrained.mat") % Load trained model
end

%% Testing (Following MATLAB GoogLeNet example)

[YPred,probs] = classify(net,auImdsTest, ...
    'ExecutionEnvironment','cpu');
accuracy = mean(YPred == imdsTest.Labels)

% Plot a sample of test predictions
idx = randperm(numel(imdsTest.Files),4);
figure(4350)
for i = 1:4
    subplot(2,2,i)
    I = readimage(imdsTest,idx(i));
    imshow(I)
    label = string(YPred(idx(i)));
    title(sprintf("Predicted class:\n %s\n Confidence: %.3f%%", ...
        label, 100*max(probs(idx(i),:)) ...
        ), 'Interpreter','none')
end

% Confusion matrix plot
figure(4351)
confusionchart(imdsTest.Labels, YPred)
