function  read_raw_data(raw_paths)


for i = 1:length(raw_paths)
    raw_path = raw_paths{i};
    cd(raw_path)
    csv_files = dir('*.csv');
    a = csv_files(1);
    csv_files(1);
    a_path = append(a.folder,'\',a.name);
    raw = readtable(a_path);
    b = csv_files(2);
    b_path = append(b.folder,'\',b.name);
    MarkerInfo = readtable(b_path);
    bci.raw = raw;
    bci.MarkerInfo = MarkerInfo;
    bci.marker_value = bci.MarkerInfo{:,4};
    bci.marker_id = bci.MarkerInfo{:,7};
    bci.MarkerIndex = table2array(raw(:,22));
    eeglab_input = table2array(raw(:,5:18));
    save("bci.mat","bci");
    save("eeglab_input.mat","eeglab_input");
    
    a  = string(table2array(bci.MarkerInfo(:,4)));
    %a = string(a);
    %idx = find(a =='active_period');
    %{
    str = {'left_rest','left_audio','left_imagine','left_speak',
        'right_rest','right_audio','right_imagine','right_speak',
        'up_rest','up_audio','up_imagine','up_speak',
        'down_rest','down_audio','down_imagine','down_speak',
        'yes_rest','yes_audio','yes_imagine','yes_speak',
        'no_rest','no_audio','no_imagine','no_speak',
        'good_rest','good_audio','good_imagine','good_speak',
        'bad_rest','bad_audio','bad_imagine','bad_speak',
        'zuo_rest','zuo_audio','zuo_imagine','zuo_speak',
        'you_rest','you_audio','you_imagine','you_speak',
        'shang_rest','shang_audio','shang_imagine','shang_speak',
        'xia_rest','xia_audio','xia_imagine','xia_speak',
        'shi_rest','shi_audio','shi_imagine','shi_speak',
        'fou_rest','fou_audio','fou_imagine','fou_speak',
        'hao_rest','hao_audio','hao_imagine','hao_speak',
        'huai_rest','huai_audio','huai_imagine','huai_speak',
    };
    %}
    str = {'left_imagine',
        'right_imagine',
        'up_imagine',
     'down_imagine',
        'yes_imagine',
       'no_imagine',
       'good_imagine',
        'bad_imagine',
        'zuo_imagine',
        'you_imagine',
        'shang_imagine',
        'xia_imagine',
        'shi_imagine',
        'fou_imagine',
        'hao_imagine',
        'huai_imagine',
    };
    idx = find(contains(a,str));

    events = bci.MarkerInfo(idx,[1,2,4]);
    events.Properties.VariableNames{3} = 'type';
    uniques = string(unique(table2array(events(:,3))));
    num_type = zeros(length(idx),1);
    search_vec = table2array(events(:,3));
    for u = 1:length(uniques)
        idx = find(search_vec==string(str{u}));
        num_type(idx)=u;
    end
    events= removevars(events,{'type'});
    events.type = num_type;
    writetable(events,'events.txt');
    %{
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            %[all_trials_flatten, label,padding_ratio] = window_flatten(file_path,window_size);
            [all_trials, label,padding_ratio] = window_flatten1(file_path,window_size);
            flattened_labelled.data =  all_trials;
            flattened_labelled.label = label;
            save([save_folder_name,'\',files(f).name(1:end-4),'_flt_lb.mat'],'flattened_labelled');
        end
    end
    %}
end
end