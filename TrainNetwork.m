% unzip('E:\TBBT Training Set Data\Set\Ml_Data.zip');
% imds = imageDatastore('Ml_data', 'IncludeSubfolders',true, 'LabelSource','foldernames'); 


digitDatasetPath = fullfile('E:\TBBT Training Set Data\Set\','Ml_Data\data');
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');

figure;
perm = randperm(10000,20);
for i = 1:20
    subplot(4,5,i);
    imshow(imds.Files{i});
end

imds.ReadFcn = @customreader2;

labelCount = countEachLabel(imds);

img = readimage(imds,1);
size(img);
reset(imds);

numTrainFiles = 46;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');


layers = [
    imageInputLayer([150 150 3])

    
    convolution2dLayer(3,8,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(3)
    softmaxLayer
    classificationLayer];


options = trainingOptions('sgdm', ...
    'MaxEpochs',4, ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');



net = trainNetwork(imdsTrain,layers,options);


YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation);


inputSize = net.Layers(1).InputSize(1:2);

figure
im = imread('E:\TBBT Training Set Data\Set\validationL\l26.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationL\l38.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationL\l12.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationL\l31.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationP\p3.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationP\p49.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationP\p22.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationP\p19.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});


figure
im = imread('E:\TBBT Training Set Data\Set\validationR\r73.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationR\r3.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationR\r38.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationR\r54.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});

figure
im = imread('E:\TBBT Training Set Data\Set\validationR\r40.png');
image(im)
im = imresize(im,[150 150]);
[label,score] = classify(net,im);
title({char(label),num2str(max(score),2)});


function data = customreader2(filename)
onState = warning('off', 'backtrace');
c = onCleanup(@() warning(onState));
data = imread(filename);
data = data(:,:,min(1:3, end)); 
data = imresize(data, [150 150]);
end


