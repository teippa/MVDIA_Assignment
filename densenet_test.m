
% load("denseNet_1.mat") % Load trained model

% Testing (Following MATLAB GoogLeNet example)

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
    label = YPred(idx(i));
    title(["Predicted class: " + string(label) , "Confidence: " + num2str(100*max(probs(idx(i),:)),3) + "%"]);
end

% Confusion matrix plot
figure(4351)
confusionchart(imdsTest.Labels, YPred)
