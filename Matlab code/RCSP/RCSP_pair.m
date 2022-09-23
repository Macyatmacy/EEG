acc_list = [];
f1_list = [];
for i = 1:13
    cd(epoched_paths{i})
    load('EEG_epoch_imagine_eng.mat');
    [allFDAFtrs,gnd] = RCSP(EEG);
    len = length(gnd);
    gnd = string(gnd);
    len_train = round(len*0.8);
    len_test = len-len_train;
    train_x = allFDAFtrs(1:len_train,:);
    train_y = gnd(1:len_train);
    test_x = allFDAFtrs(len_train:end,:);
    test_y = gnd(len_train:end);
    [trainedClassifier, validationAccuracy1] = trainClassifier_0915(train_x, train_y);
    yfit1 = trainedClassifier.predictFcn(test_x);
    yfit1 = string(yfit1);
    idx = find(test_y==yfit1);
    acc1 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit1);
    stats = statsOfMeasure(C, 0);
    f1_1 = table2array(stats(end,["macroAVG"]));
    acc_list = [acc_list;acc1];
    f1_list = [f1_list;f1_1];
end

acc_eng_matrix = [acc_eng_matrix,acc_list];

acc_list = [];
f1_list = [];
for i = 1:13
    cd(epoched_paths{i})
    load('EEG_epoch_imagine_chi.mat');
    [allFDAFtrs,gnd] = RCSP(EEG);
    len = length(gnd);
    gnd = string(gnd);
    len_train = round(len*0.8);
    len_test = len-len_train;
    train_x = allFDAFtrs(1:len_train,:);
    train_y = gnd(1:len_train);
    test_x = allFDAFtrs(len_train:end,:);
    test_y = gnd(len_train:end);
    [trainedClassifier, validationAccuracy1] = trainClassifier_0915(train_x, train_y);
    yfit1 = trainedClassifier.predictFcn(test_x);
    yfit1 = string(yfit1);
    idx = find(test_y==yfit1);
    acc1 = length(idx)/length(test_y);
    [C,order] = confusionmat(test_y,yfit1);
    stats = statsOfMeasure(C, 0);
    f1_1 = table2array(stats(end,["macroAVG"]));
    acc_list = [acc_list;acc1];
    f1_list = [f1_list;f1_1];
end
acc_chi_matrix = [acc_chi_matrix,acc_list];