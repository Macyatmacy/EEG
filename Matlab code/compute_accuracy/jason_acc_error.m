function jason_acc_error
acc = [];
files = dir('*.json');
for i = 1:length(files)
    a = files(i);
    subj_id = regexp(a.name,'\d*','Match');
    subj_id = str2double(subj_id{1});
    a_path = append(a.folder,'\',a.name);
    fname = a_path; 
    fid = fopen(fname); 
    raw = fread(fid,inf); 
    str = char(raw'); 
    fclose(fid); 
    val = jsondecode(str);
    acc(subj_id) = (1-val.test_misclass)*100;
end
acc = acc';
mean_acc=mean(acc)
end