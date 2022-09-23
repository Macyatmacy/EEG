function [chan_psd,chan_rpsd] = chan_rpsd_rm_base(EEG,baseline_windows)
chan = {EEG.chanlocs.labels};
chan_rpsd = [];
chan_psd = [];
for i=1:length(chan)
    [~,psd,rpsd] = remove_baseline_psd(EEG,chan{i},baseline_windows,0);
    chan_rpsd = [chan_rpsd;rpsd];
    chan_psd = [chan_psd;psd];
end
end