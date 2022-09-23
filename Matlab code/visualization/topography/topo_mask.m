function topo_mask(signal,bar,lo,hi,pmask)
chanlocs = load('e:\document\MATLAB\EEG coding\clean_data\chanlocs.mat');
cmap = load('e:\document\MATLAB\EEG coding\clean_data\RdBu_r.mat');
cmap = load('e:\document\MATLAB\EEG coding\clean_data\coolwarm.mat');
topoplot(signal,chanlocs.chanlocs,'maplimits',[lo,hi],'electrodes','on','colormap',cmap.coolwarm,'whitebk','on','pmask',pmask);
if bar
    colorbar;
    %colorbar.Layout.Tile = 2;
end
end