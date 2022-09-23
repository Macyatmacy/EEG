compare1 = rpsd_cn_ct;
compare2 = rpsd_cn_et;
%compare en_et with cn_ct, delta
h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,1,:);
b=compare2(i,1,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Delta')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Delta');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Delta.png');
% sig 5
%% 
h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,2,:);
b=compare2(i,2,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end

topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Theta')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Theta');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Theta.png');
%sig 8 12
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,3,:);
b=compare2(i,3,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Alpha')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Alpha');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Alpha.png');
% 
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,4,:);
b=compare2(i,4,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Beta')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Beta');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_Beta.png');
% 1
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,5,:);
b=compare2(i,5,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Gamma')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_low_Gamma');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_low_Gamma.png');
% sig 5
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,6,:);
b=compare2(i,6,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Gamma')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_median_Gamma');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_median_Gamma.png');
% sig 
%% 

h_list = [];
t_list=[];
for i = 1:14
a =compare1(i,7,:);
b=compare2(i,7,:);
[h,p,ci,stats] = ttest(a,b,'Alpha',0.05);
h_list(i)=h;
t_list(i) = stats.tstat;
end
topo(t_list,0,-2.5,2.5)
camroll(90);
%title('EN/CT vs. CN/CT Gamma')
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_high_Gamma');
saveas(gcf,'D:\Desktop\\0_Group figues\upload\CN_CT_CN_ET_high_Gamma.png');


