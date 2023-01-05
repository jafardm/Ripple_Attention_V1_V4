function [ latTimes, lsqCurveTimes, lsqFittedCurve, lsqFittedParam, lsqCurveFitErr] = getLatencies( MuaeData, MuaeTimes, lsqTemporalRes )
%GETLATENCIES Summary of this function goes here
%   Detailed explanation goes here

numContacts=size(MuaeData,1);
latTimes=zeros(1,numContacts);

lsqCurveTimes=[MuaeTimes(1):lsqTemporalRes:MuaeTimes(end)];% MuaeTimes(end)];
lsqFittedCurve=zeros(numContacts,length(lsqCurveTimes));
lsqCurveFitErr=zeros(1,numContacts);
lsqFittedParam=zeros(numContacts,5);

% LsqParam0 = [mu, sigma, alpha, c, d];
% LsqParam0 is the starting point for the fitting routine;

funToFit = @(p,tdata)(p(5)*exp(p(1)*p(3)+0.5*p(2)^2*p(3)^2-p(3)*tdata)...
    .*normcdf(tdata,p(1)+p(2)^2*p(3),p(2))...
    +p(4)*normcdf(tdata,p(1),p(2)));

movMeanResolution = 5;
mu0ValuesOrigVec = 30:1:90;

options = optimoptions('lsqcurvefit','Display','off');

% LOOP OVER CHANNELS
for chIdx=1:numContacts

    MuaeDataMovMean=movmean(MuaeData(chIdx,:),movMeanResolution);
    IntMuaeDataMM=interp1(MuaeTimes,MuaeDataMovMean,mu0ValuesOrigVec);
    DiffMuaeDataMM=diff([IntMuaeDataMM IntMuaeDataMM(end)]);

    % EMPIRICAL SETTING: TAKE ONLY POSITIVE SLOPES TO SPEED UP
    mu0ValuesVec=mu0ValuesOrigVec(DiffMuaeDataMM>=0);%.2*min(DiffMuaeDataMM));    
    
    lsqMuErrMovMean=-1*ones(1,length(mu0ValuesVec));
    lsqFittedParamMovMean=zeros(length(mu0ValuesVec),5);
    lsqParam0=[50 1 1 1 1];
    
    % ATTENTION: FIT THE MOVMEAN THEN USE THE MIN MSE PARAMETERS
    for muIdx=1:length(mu0ValuesVec)
        lsqParam0(1)=mu0ValuesVec(muIdx);
        try
            lsqFittedParamMovMean(muIdx,:)=lsqcurvefit(funToFit,lsqParam0,MuaeTimes,MuaeDataMovMean,[],[],options);
            lsqMuErrMovMean(muIdx)=norm(feval(funToFit,lsqFittedParamMovMean(muIdx,:),MuaeTimes)-MuaeData(chIdx,:));
        catch
            warning('lsqcurvefit does not converge for the parameters chosen!');
        end
    end
    % Remove non-tested mu parameters
    lsqMuErrMovMean(lsqMuErrMovMean==-1)=[];
    lsqFittedParamMovMean(lsqMuErrMovMean==-1)=[];
    
    [~,lsqMinMuErrIdxMovMean]=min(lsqMuErrMovMean);
    
    lsqFittedCurve(chIdx,:)=feval(funToFit,lsqFittedParamMovMean(lsqMinMuErrIdxMovMean,:),lsqCurveTimes);
    lsqCurveFitErr(chIdx)=norm(interp1(lsqCurveTimes,lsqFittedCurve(chIdx,:),MuaeTimes)-MuaeData(chIdx,:));
    lsqFittedParam(chIdx,:)=lsqFittedParamMovMean(lsqMinMuErrIdxMovMean,:);
    
    latIndex=find(lsqFittedCurve(chIdx,:)>=1/3*max(lsqFittedCurve(chIdx,:)),1,'first');
    if ~isempty(latIndex)
        latTimes(chIdx)=lsqCurveTimes(latIndex);
    else
        latTimes(chIdx)=NaN;
    end
    
end
end

