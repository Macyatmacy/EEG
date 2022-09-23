compare1 = rpsd_en_et;
compare2 = rpsd_cn_et;
%compare en_et with cn_ct, delta
h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,1,:);
b=compare2(i,1,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Delta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Delta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Delta.png');
%% 
h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,2,:);
b=compare2(i,2,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end

topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Theta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Theta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Theta.png');
% 12
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,3,:);
b=compare2(i,3,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Alpha')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Alpha');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Alpha.png');
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,4,:);
b=compare2(i,4,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Beta')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Beta');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_Beta.png');
% 8 13
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,5,:);
b=compare2(i,5,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_low_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_low_Gamma.png');
% 6
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,6,:);
b=compare2(i,6,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_median_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_median_Gamma.png');
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,7,:);
b=compare2(i,7,:);
[h,p,ci,stats] = ttest(a,b(:,:,[1,2,4,5,6,7]),'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/ET vs. CN/ET Gamma')
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_high_Gamma');
saveas(gcf,'D:\Desktop\0_Group figues\upload\EN_ET_CN_ET_high_Gamma.png');

% 14


