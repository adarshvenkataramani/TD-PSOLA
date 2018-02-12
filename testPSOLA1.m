function [IN] = testPSOLA1()
    %% Create input and output objects
    Fs = 48000;
    nFrame= 1024;
    %% Recording audio
     recObj = audiorecorder(Fs,16,1);
     disp('Recording ...')
     recordblocking(recObj, 2);
     disp('Done')
     
     myData = getaudiodata(recObj);
%     sound(myData,Fs)
    %% Parameter Setup
%    [myData,Fs] = audioread('ana.wav');
    config.filterBand = [1000];
    config.Fs = Fs;
    config.nFrame = nFrame;
    config.slices = floor(length(myData)/nFrame);
    %% Calculate butterworth-order
    config.bOrder = buttord(config.filterBand/(config.Fs/2),0.5,1.0,60);
    [config.bFilter,config.aFilter] = butter(config.bOrder,config.filterBand/(config.Fs/2),'low');
    %% Fix RMS threshold
    config.rmsThr = .02; % RMS Threshold in magnitude
    config.minF0 = 50; % Minimum F0 for lower band
    config.maxF0 = 400; % Maximum F0 for higher band
    %% Fixing center clips for truncating signals
    config.centerClip = .3;
    config.devF0 = 0.2;
    %% PSOLA - parameters
    config.pitchScale           = 2.0;	%pitch scale ratio
    config.timeScale            = 1.0;	%time scale ratio
    config.resamplingScale      = 1;
    config.reconstruct          = 0;
    %% Input Filter parameters
    filtOrder = 100;
    CentFreq = 600;
    attnStop = 90;
    %% Filter Handles
    filtHandle = dsp.FIRFilter;
    filtHandle.Numerator = fir1(128,CentFreq/(Fs/2),'low');
    %%
    foOut = [];
    IN = [];
    Mark = [];
    streamInpSig_In = zeros(nFrame,2);
    lowF0 = config.minF0;
    highF0 = config.maxF0;
    Out = [];
    Mark = nFrame*ones(2,1);
    %%
    for kkk = 1: config.slices
        %% Chunk the signal 
        mySignal = myData((kkk-1)*nFrame+1:kkk*nFrame);
        %% Filter the signal
        inpSig = mySignal(:);
        inpSigFilt =  filtfilt(filtHandle.Numerator,1,inpSig(:));
        %% Signal concantenation
        streamInpSig_In = [streamInpSig_In;inpSig(:) inpSigFilt(:)];
        %% RMS check
        frmF0 = 0;
        %% Pre-emphasis filter
        b = [1, -0.97];
        inSigFilt1 = filtfilt(b,1,inpSigFilt);
        %% Pitch peak Estimation
        if rms(inpSigFilt) > config.rmsThr
             
            % Pitch detection
            MinLag = round(config.Fs / config.maxF0);
            MaxLag = round(config.Fs / config.minF0);
            
            % nonlinear center clipping
            cc = CenterClipping(inpSig, config.centerClip);
            
            % crosscorrelation
            maxLag = min([config.nFrame, MaxLag]);
            [xCor,lags] = xcorr(cc,maxLag,'coeff');
            [pks,locs] = findpeaks(xCor,lags,'MinPeakDistance',MinLag,'MinPeakHeight',.1,'SortStr','descend');
            %% 
            if ~isempty(pks) && length(pks)>1
                if abs(locs(2)) < MaxLag
                    frmF0 = config.Fs/abs(locs(2));
                end
            end
        end
        foOut = [foOut frmF0];   
        for i = 1:length(locs)-1
            Mark = [Mark;Mark(end)+abs(locs(2))];
            Mark(Mark>95000) = [];
            sortedF0 = [abs(locs(2)) 2*abs(locs(2))];
        end
        %% Saving data       
        IN = [IN;inpSig(:)];
    end
    streamInpSig_In(1:nFrame,:) = [];
    pso = PSOLA(myData, Fs, Mark, 1.0, 2.0);
    %%
    plot(foOut,'b-o','LineWidth',2);
    
    figure;
    ax(1) = subplot(211);
    plot(streamInpSig_In(:,1),'b');
    hold on;
    plot(streamInpSig_In(:,2),'r');
    plot(Mark,IN(Mark),'go','MArkerSize',10,'MArkerFaceColor',[0 1 0],'MArkerEdgeColor',[0 1 0])
    ax(2) = subplot(212);
    plot(diff(streamInpSig_In(:,2)))
    linkaxes(ax,'xy')
    
    figure;
    plot(IN(:),'b');
    hold on;
    plot(pso,'r');
end

%%
function [cc, ClipLevel] = CenterClipping(x, Percentage)
    ClipLevel = max(abs(x)) * Percentage;
    PositiveSet = find( x > ClipLevel);
    NegativeSet = find (x < -ClipLevel);
    cc = zeros( size(x) );
    cc(PositiveSet) = x(PositiveSet) - ClipLevel;
    cc(NegativeSet) = x(NegativeSet) + ClipLevel;
end