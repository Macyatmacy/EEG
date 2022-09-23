function [genSs,genMs,gnd] = genericCov(EEG)
EEGdata= permute(EEG.data,[2,1,3]);
%EEGdata = EEG.data;
[numT,numCh,numTrl] = size(EEGdata);
%Ns=zeros(2,1);
%Sigma2=cell(2,1);
%{
for i=1:numTrl
event = EEG.event(i);
str(i) = string(event.type);
end
%}
label_list = EEG.label;

str_unique = unique(label_list);
str_unique = sort(str_unique);


gnd = zeros(numTrl,1);
idx1 = find(label_list==str_unique(1));
gnd(idx1)=1;
idx2 = find(label_list==str_unique(2));
gnd(idx2)=2;


s1 = zeros(numCh,numCh);
s2 = zeros(numCh,numCh);
for i = 1:length(idx1)
    a = EEGdata(:,:,idx1(i))';
    s1 = s1 + a*a'/sum(diag(a*a'));
end
for j = 1:length(idx2)
    a = EEGdata(:,:,idx2(j))';
    s2 = s2 + a*a'/sum(diag(a*a'));
end

genSs = cat(3,s1,s2);
genMs = [length(idx1),length(idx2)];
end