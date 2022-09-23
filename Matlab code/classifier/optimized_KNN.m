function [output] = optimized_KNN(train_file_path,test_file_path,fast_svm)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
load(train_file_path);
train_x = feature_norm.data;
train_y = feature_norm.label;
load(test_file_path);
test_x = feature_norm.data;
test_y = feature_norm.label;
%rng(1);
if fast_knn
    [trainedClassifier, validationAccuracy] = knn_weighted(train_x, train_y);
    yfit = trainedClassifier.predictFcn(test_x);
    yfit = string(yfit);
    idx = find(test_y==yfit);
    acc1 = length(idx)/length(test_y);
else
    c = cvpartition(length(label),'KFold',5);
    opts = struct('CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus','ShowPlots',false,'Verbose',0);
    Mdl = fitcsvm(feature,label,'KernelFunction','rbf', ...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts,'KKTTolerance',0.9);
    [x,CriterionValue,iteration] = bestPoint(Mdl.HyperparameterOptimizationResults);
    L_MinEstimated = kfoldLoss(fitcsvm(feature,label,'CVPartition',c,'KernelFunction','rbf', ...
        'BoxConstraint',x.BoxConstraint,'KernelScale',x.KernelScale))
    acc1 = 1 - L_MinEstimated;
end

if fast_svm
    [trainedClassifier, validationAccuracy] = knn_cubic(train_x, train_y);
    yfit = trainedClassifier.predictFcn(test_x);
    yfit = string(yfit);
    idx = find(test_y==yfit);
    acc2 = length(idx)/length(test_y);
else
    c = cvpartition(length(label),'KFold',5);
    opts = struct('CVPartition',c,'AcquisitionFunctionName','expected-improvement-plus','ShowPlots',false,'Verbose',0);
    Mdl = fitcsvm(feature,label,'KernelFunction','rbf', ...
        'OptimizeHyperparameters','auto','HyperparameterOptimizationOptions',opts,'KKTTolerance',0.9);
    [x,CriterionValue,iteration] = bestPoint(Mdl.HyperparameterOptimizationResults);
    L_MinEstimated = kfoldLoss(fitcsvm(feature,label,'CVPartition',c,'KernelFunction','polynomial','PolynomialOrder', 2,  ...
        'BoxConstraint',x.BoxConstraint,'KernelScale',x.KernelScale))
    acc2 = 1 - L_MinEstimated;
end

output = [acc1,acc2];

end