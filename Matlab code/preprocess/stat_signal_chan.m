function [feature_matrix] = stat_signal_chan(chan_signal,srate)
%chan_signal: chans*times

feature_matrix = [];
for i = 1:length(chan_signal(:,1))
    w = chan_signal(i,:);
    w_y = (0:1/srate:(1/srate)*(length(w)-1));
    feature = zeros(1,24);
    feature(1) = mean(w);
    feature(2) = mean(abs(w));
    feature(3) = max(w);
    feature(4) = max(abs(w));
    feature(5) = min(w);
    feature(6) = min(abs(w));
    feature(7) = approximateEntropy(w);
    feature(8) = min(w)+max(w);
    feature(9) = max(w)-min(w);
    feature(10) = CurveLength(w,w_y);
    feature(11) = sum(w.^2);
    maxtime=length(w);
    Kmax=floor(maxtime/2);
    feature(12) = Higuchi_FD(w,Kmax);
    feature(13) = simps(w,w_y);
    feature(14) = Katz_FD(w,Kmax);
    feature(15) = kurtosis(w,0);
    pyrun("import antropy as ant");
    feature(16) = pyrun("a = ant.perm_entropy(w, normalize=True)","a",w=w);
    feature(17) = rms(w);
    feature(18) = skewness(w,0);
    feature(19) = pyrun("a = ant.sample_entropy(w)","a",w=w);
    feature(20) = pyrun("a = ant.spectral_entropy(w, sf=100, method='welch', normalize=True)","a",w=w);
    feature(21) = std(w);
    feature(22) = pyrun("a = ant.svd_entropy(w, normalize=True)","a",w=w);
    feature(23) = sum(w);
    feature(24) = var(w);
    feature_matrix(i,:)= feature;
end
end