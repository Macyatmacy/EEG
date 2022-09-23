function [allFDAFtrs,gnd] = RCSP(EEG)


selCh=6;%number of selected channels/columns
numCls=2;%two classes only


betas=[ 0,1e-2,1e-1,2e-1,4e-1,6e-1];
gammas=[0,1e-3,1e-2,1e-1,2e-1];
numBeta=length(betas);
numGamma=length(gammas);
numRegs=numBeta*numGamma;
regParas=zeros(numRegs,2);
iReg=0;
for ibeta=1:numBeta
    beta=betas(ibeta);
    for igamma=1:numGamma
        gamma=gammas(igamma);
        iReg=iReg+1;
        regParas(iReg,1)=beta;
        regParas(iReg,2)=gamma;
    end
end

[genSs,genMs,gnd]=genericCov(EEG);%implement, please refer to line 65-79 of RegCsp.m
EEG = EEG.data;

[numCh,numT,nTrl] = size(EEG);%suppose data is loaded to variable "EEG"
numTrn=round(nTrl*0.8); %please specify number of training samples
EEG= permute(EEG,[2,1,3]);
trainIdx=1:numTrn;%take the first numTrn samples for training
testIdx=(numTrn+1):length(gnd);%the rest for testing
fea2D_Train = EEG(:,:,trainIdx);gnd_Train = gnd(trainIdx);
fea2D = EEG;

allNewFtrs=zeros(selCh,nTrl,numRegs);%Projected Features for R-CSP
for iReg=1:numRegs
    regPara=regParas(iReg,:);
    %=================RegCSP==========================%     
    %Prototype: W=RegCsp(EEGdata,gnd,genSs,genMs,beta,gamma)
    prjW= RegCsp(fea2D_Train,gnd_Train,genSs,genMs,regPara(1),regPara(2));
    %=================Finished Training==========================
    prjW=prjW(1:selCh,:);%Select columns 
    newfea=zeros(selCh,nTrl);
    for iCh=1:selCh
        for iTr=1:nTrl
            infea=fea2D(:,:,iTr)';
            prjfea=prjW(iCh,:)*infea;
            newfea(iCh,iTr)=log(var(prjfea));
        end
    end
    allNewFtrs(:,:,iReg)=newfea;
end

allFDAFtrs=zeros(nTrl,numRegs);%Features after FDA
for iReg=1:numRegs
    newfea=allNewFtrs(1:selCh,:,iReg);
    FDAU=FDA(newfea(:,trainIdx),gnd_Train);
    newfea=FDAU'*newfea;
    newfea=newfea';
    allFDAFtrs(:,iReg)=newfea;
end

end