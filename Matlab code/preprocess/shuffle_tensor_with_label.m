function [EEG] = shuffle_tensor_with_label(EEG)
vec = 1:1:length(EEG.data(1,1,:));
vec=vec(randperm(length(vec)));
EEG.data = EEG.data(:,:,vec);
EEG.label = EEG.label(vec);
end