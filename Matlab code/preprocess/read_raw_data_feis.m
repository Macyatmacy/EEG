function  read_raw_data_feis(raw_paths)


for i = 1:length(raw_paths)
    raw_path = raw_paths{i};
    cd(raw_path)
    csv_files = dir('*.csv');
    a = csv_files(1);
    a_path = append(a.folder,'\',a.name);
    raw = readtable(a_path);

    bci.raw = raw;

    eeglab_input = table2array(raw(:,3:16));
    %save("bci.mat","bci");
    save("eeglab_input.mat","eeglab_input");

    event_table_names = ["latency","type"];
    event_matrix = [];
    latency = table2array(bci.raw(:,1));
    epoch_idx  = table2array(bci.raw(:,2));
    types = table2array(bci.raw(:,17));
    n_epoch = max(epoch_idx);
    idx_1=[];
    idx_2=[];
    for e = 0:n_epoch
        idx = find(epoch_idx==e);
        idx_1 = [idx_1,idx(1)];
        idx_2 = [idx_2,idx(end)];
    end
    for e = 1:n_epoch
        %event_matrix = [event_matrix;[latency(idx_1(e)),latency(idx_2(e))-latency(idx_1(e)),types(idx_1(e))]];
        event_matrix = [event_matrix;[latency(idx_1(e)+1),types(idx_1(e)+1)]];
    end
    events = array2table(event_matrix,"VariableNames",event_table_names);

    writetable(events,'events.txt');

end
end