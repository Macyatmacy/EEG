function [output,yfit1,yfit2] = optimized_classifier(train_file_path,test_file_path,fast,label_order,N)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
load(train_file_path);
train_x = feature_norm.data;
train_y = feature_norm.label;
load(test_file_path);
test_x = feature_norm.data;
test_y = feature_norm.label;
[train_x,feats_idx] = fea_sel(train_x,train_y,N);
test_x = test_x(:,feats_idx);

%rng(1);
if fast
    [trainedClassifier, validationAccuracy1] = svm_qua_pca(train_x, train_y);
    yfit1 = trainedClassifier.predictFcn(test_x);
    yfit1 = string(yfit1);
    idx = find(test_y==yfit1);
    acc1 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit1);
    stats = statsOfMeasure(C, 0);
    f1_1 = table2array(stats(end,["macroAVG"]));
else
    c = cvpartition(length(label),'KFold',5);
    opts = struct('CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus','ShowPlots',false,'Verbose',0);
    Mdl = fitcsvm(feature,label,'KernelFunction','rbf', ...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts,'KKTTolerance',0.9);
    [x,CriterionValue,iteration] = bestPoint(Mdl.HyperparameterOptimizationResults);
    L_MinEstimated = kfoldLoss(fitcsvm(feature,label,'CVPartition',c,'KernelFunction','rbf', ...
        'BoxConstraint',x.BoxConstraint,'KernelScale',x.KernelScale));
    validationAccuracy1 = 1 - L_MinEstimated;
    yfit1 = Mdl.predictFcn(test_x);
    yfit1 = string(yfit1);
    idx = find(test_y==yfit1);
    acc1 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit1);
    stats = statsOfMeasure(C, 0);
    f1_1 = table2array(stats(end,["macroAVG"]));
end

if fast
    [trainedClassifier, validationAccuracy2] = knn_weighted_pca(train_x, train_y);
    yfit2 = trainedClassifier.predictFcn(test_x);
    yfit2 = string(yfit2);
    idx = find(test_y==yfit2);
    acc2 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit2);
    stats = statsOfMeasure(C, 0);
    f1_2 = table2array(stats(end,["macroAVG"]));
else
    c = cvpartition(length(label),'KFold',5);
    opts = struct('CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus','ShowPlots',false,'Verbose',0);
    Mdl = fitcsvm(feature,label,'KernelFunction','gaussian', ...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts,'KKTTolerance',0.9);
    [x,CriterionValue,iteration] = bestPoint(Mdl.HyperparameterOptimizationResults);
    L_MinEstimated = kfoldLoss(fitcsvm(feature,label,'CVPartition',c,'KernelFunction','polynomial','PolynomialOrder', 2,  ...
        'BoxConstraint',x.BoxConstraint,'KernelScale',x.KernelScale));
    validationAccuracy2 = 1 - L_MinEstimated;
    yfit2 = Mdl.predictFcn(test_x);
    yfit2 = string(yfit2);
    idx = find(test_y==yfit2);
    acc2 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit2);
    stats = statsOfMeasure(C, 0);
    f1_2 = table2array(stats(end,["macroAVG"]));
end

output = [validationAccuracy1,acc1,f1_1,validationAccuracy2,acc2,f1_2];

end