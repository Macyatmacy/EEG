function [output,acc] = json_acc(start_idx,name,name_is_error)
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
    if name_is_error
        acc(subj_id+start_idx) = (1-val.(name))*100;
    else
        acc(subj_id+start_idx) = val.(name)*100;
    end
end
acc = acc';
output = mean(acc);
end