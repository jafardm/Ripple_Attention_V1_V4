function [crossCorr, timeBinsLag, crossCorr_AU, crossCorr_AU_side, crossCorr_shift] = CC_timeSeries(sig, trig, SF, maxTimeLag, cfg, resultSave)
% 
% [crossCorr, timeBinsLag, crossCorr_AU, crossCorr_AU_side, crossCorr_shift] = CC_timeSeries(sig, trig, SF, maxTimeLag, cfg, resultSave)
% 
% perform cross correlation between two time series
%
% Example
% -------
% ::
% 
%     [ccMat, LAGS] = CC_timeSeries(sig, trig, 1000, 0.3, analysisParam, resultSave)
% 
% Parameters
% ----------
% sig : cell
%     cell array of size (numChannel x numTrial) with analog signal
%     relative to event 
% trig : cell
%     cell array of size (1 x numTrial) with analog signal
%     relative to event, used as trigger
% SF : float
%     float indicating sampling frequency
% maxTimeLag : float
%     float to indicate the time lag
% cfg : struct
%     struct with fields
%
%     - performShuffle : perform shuffle predictor, default is 1
%     - normaliseInput : normalise input data (default 'zscore'), options
%     are 'none', 'demean', 'zscore'
%     - scaleOpt : scaling used by function xcorr, default is 'coeff'
%     - plotResult : boolean, plot cross correlation, default is 0
%
% resultSave : struct
%     struct with fields about saving data/figures
% 
% Returns
% -------
% crossCorr : array
%     array of size (numChannel x length(timeLags)) with cross correlations
% timeBinsLag : array
%     array of size (1 x time) with time lags
% crossCorr_AU : array
%     array of size (numChannel x 1) with area under cross correlation
%     curve
% crossCorr_AU_side : array
%     array of size (numChannel x 2) with area under cross correlation
%     curve for times < 0 and times > 0
% crossCorr_shift : array
%     array of size (numChannel x length(timeLags)) with cross correlations
%     from shuffle predictor
% 
%
% **crossCorrelation_analog.mat**
%     file that includes all the variables listed under *Returns*
% 
% 

% set defaults, cfg
if ~isfield(cfg,'performShuffle'), cfg.performShuffle = 1; end
if ~isfield(cfg,'normaliseInput'), cfg.normaliseInput = 'zscore'; end
if ~isfield(cfg,'scaleOpt'), cfg.scaleOpt = 'coeff'; end
if ~isfield(cfg,'plotResult'), cfg.plotResult = 0; end

% set defaults, resultSave
if ~isfield(resultSave,'data'), resultSave.data = 0; end
if ~isfield(resultSave,'dataDirName'), fprintf('dataDirName does not exist, cannot save file\n'), resultSave.data = 0; end

% check input
[numChan, numTrial] = size(sig);

assert( size(sig,2) == size(trig,2), 'unequal trial numbers for sig and trig')
assert( size(trig,1) == 1, 'trigger cannot have multiple channels')

if numChan > 1
    error('Have not yet implemented using multiple channels yet');
end

assert(length(SF)==1,'SF is wrong size')
assert(length(maxTimeLag)==1,'maxTimeLag is wrong size')

if numTrial == 1
    cfg.performShuffle = 0;
end

% get trial indices
trIdx = 1:numTrial;
%trIdx_shuffle  = circshift(trIdx, 1); % trial index + 1
trIdx_shuffle   = randperm(numTrial); % shuffle trials

% determine number of samples in maxTimeLag based on SF
BinCentres = [fliplr(1000/SF:1000/SF:(maxTimeLag*1000)).*(-1) 0 [1000/SF:1000/SF:(maxTimeLag*1000)]];
maxTimeLag = round((length(BinCentres)-1)/2);

% initialise cross correlation variables
crossCorr      = NaN(numChan, length(BinCentres));
crossCorr_AU   = NaN(numChan, 1);% area under CC curve;
crossCorr_AU_side   = NaN(numChan, 2);% area under CC curve, separate for times < and > than 0;
if cfg.performShuffle
    crossCorr_shift    = NaN(numChan, length(BinCentres));
end

for ichan = 1:numChan
    
    tmp_crossCorr       = NaN(numTrial, length(BinCentres));
    tmp_crossCorr_shift = NaN(numTrial, length(BinCentres));
    
    for itrial = 1:numTrial
        
        % select data for this trial
        tSig = sig{ichan, trIdx(itrial)};
        tTrig = trig{1, trIdx(itrial)};
        if cfg.performShuffle
            tSigShuffle = sig{ichan, trIdx_shuffle(itrial)};
        end
        
        % normalise
        switch cfg.normaliseInput
            case 'none'
                
            case 'demean'
                tSig = (tSig-mean(tSig));
                tTrig = (tTrig-mean(tTrig));
                
                if cfg.performShuffle
                    tSigShuffle = (tSigShuffle-mean(tSigShuffle));
                end
            case 'zscore'
                % Normalise the data before performing cross correlation
                tSig = (tSig-mean(tSig)) / std(tSig);
                tTrig = (tTrig-mean(tTrig)) / std(tTrig);
                
                if cfg.performShuffle
                    tSigShuffle = (tSigShuffle-mean(tSigShuffle)) / std(tSigShuffle);
                end
            otherwise
                error('cfg.normaliseInput set incorrectly')
        end
        
        % equate the length of the vectors for the shuffling
        % analysis, add NaN values to shorter vectors
        if cfg.performShuffle
            if length(tSigShuffle) ~= length(tSig)
                maxLength = max(length(tSigShuffle), length(tSig));
                
                tmp1 = nan(1, maxLength);
                tmp2 = tmp1;
                tmp3 = tmp1;
                
                tmp1(1:length(tSigShuffle)) = tSigShuffle;
                tSigShuffle = tmp1;
                
                tmp2(1:length(tSig)) = tSig;
                tSig = tmp2;
                
                tmp3(1:length(tTrig)) = tTrig;
                tTrig = tmp3;
            end
        end
        
        % get indices of timepoints to use
        isOK = isfinite(tSig) & isfinite(tTrig);   % both rows finite (neither NaN)
        if cfg.performShuffle
            isOK_shuffle = isfinite(tSig) & isfinite(tTrig) & isfinite(tSigShuffle);   % both rows finite (neither NaN)
        end
        
        % perform cross correlation
        [tmp_crossCorr(itrial,:), timeBinsLag]    = xcorr(tSig(isOK), tTrig(isOK), maxTimeLag, cfg.scaleOpt);
        
        if cfg.performShuffle
            [tmp_crossCorr_shift(itrial,:)]    = xcorr(tSigShuffle(isOK_shuffle), tTrig(isOK_shuffle), maxTimeLag, cfg.scaleOpt);
        end
    end
    
    % average result per channel
    if numTrial<=2
        crossCorr(ichan, :) = nanmean(tmp_crossCorr,1);
    else
        jackCrossCorr = jackknife(@nanmean, tmp_crossCorr, 1);
        crossCorr(ichan, :) = nanmean(jackCrossCorr,1);
    end
    
    if cfg.performShuffle
        if numTrial<=2
            crossCorr_shift(ichan, :) = nanmean(tmp_crossCorr_shift,1);
        else
            jackCrossCorr = jackknife(@nanmean, tmp_crossCorr_shift, 1);
            crossCorr_shift(ichan, :) = nanmean(jackCrossCorr,1);
        end
        crossCorr(ichan, :) = crossCorr(ichan, :) - crossCorr_shift(ichan, :);
    end
    
    % get area under cross correlation curve
    crossCorr_AU(ichan,1) = trapz(crossCorr(ichan, :));
    crossCorr_AU_side(ichan,1) = trapz(crossCorr(ichan, timeBinsLag<0));
    crossCorr_AU_side(ichan,2) = trapz(crossCorr(ichan, timeBinsLag>0));
    
end

if (resultSave.data)
    if ~(isfolder(resultSave.dataDirName))
        mkdir(resultSave.dataDirName)
    end
    filename = fullfile(resultSave.dataDirName, sprintf('crossCorrelation_analog.mat'));
    save(filename, 'crossCorr*', 'timeBinsLag');
end
%%% plotting
if cfg.plotResult
    figure, clf
    hold on
    
    colors = [...
        0       0.4470    0.7410; ...
        0.8500  0.3250    0.0980; ...
        0.9290  0.6940    0.1250; ...
        0.4940  0.1840    0.5560; ...
        0.4660  0.6740    0.1880; ...
        0.3010  0.7450    0.9330; ...
        0.6350  0.0780    0.1840; ...
        ];
    
    plot(timeBinsLag, crossCorr, 'LineWidth', 2)
    
    if cfg.performShuffle
        hshuffle = plot(timeBinsLag, crossCorr_shift, 'color', colors(2, :));
    end
        
    plot([0 0], ylim, 'k', 'linewidth', 1)
    plot(xlim, [0 0], 'k', 'linewidth', 1)
    
    axis square
    xlabel('time (s)')
    
end



