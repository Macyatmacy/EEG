data = mean(rpsd_en_et,3);
%compare EN_ET with cn_ct, delta


a=data(:,1);

topo(a,0,0,0.3)
camroll(90);
%title('Delta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Delta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Delta.png');
%% 
a=data(:,2);
topo(a,0,0,0.3)
camroll(90);
%title('EN/ET vs. CN/CT Theta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Theta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Theta.png');
% sig 13
%% 


a=data(:,3);

topo(a,0,0,0.3)
camroll(90);
%title('EN/ET vs. CN/CT Alpha')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Alpha');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Alpha.png');
%sig 13
%% 

a=data(:,4);

topo(a,0,0,0.3)
camroll(90);
%title('EN/ET vs. CN/CT Beta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Beta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_Beta.png');
%% 

a=data(:,5);

topo(a,0,0,0.3)
camroll(90);
%title('EN/ET vs. CN/CT low Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_low_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_low_Gamma.png');

%% 

a=data(:,6);

topo(a,0,0,0.3)
camroll(90);
%title('EN/ET vs. CN/CT median Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_median_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_median_Gamma.png');

%% 



a=data(:,7);

topo(a,0,0,0.3)
camroll(90);
%title('CN/CT vs. EN/ET high Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_high_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_high_Gamma.png');