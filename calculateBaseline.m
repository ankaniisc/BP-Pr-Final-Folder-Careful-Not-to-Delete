
%% PLOT BASELINE RAW POWER SPECTRUM AND LOG POWERSPECTRUM.

function [rawbldata,rawblpower,mLogBL,blPass,dPower] = calculateBaseline(blPass,handles)

pnet('closeall') % closing all the previously opens pnets connections

%%
disp('R E A D Y...');
[ready.dat, Fready] = audioread('ready.wav');
readyobj = audioplayer(ready.dat, Fready);
playblocking(readyobj);


rawbldata = []; % Initializing the matrix for collecting raw baseline data

% clearing previously run baseline handles
 
 handles.blCount = [];
 handles.rawbldata = [];
 handles.rawblpower = [];
 handles.mLogBL= [];
 handles.dPowerBL=[];

% Deleting graphics objects from the axes or polar axes specified 

cla(handles.rawTraceAlpha);
cla(handles.tfAlpha);
cla(handles.chPowerAlpha);

AlphaChans = handles.AlphaChans; 
AlphaChans=str2num(AlphaChans);

% Assigning value to the blPass

if(~blPass)% number of passes to average for baseline
    blPass = '15';
end
% blPass=str2num(blPass);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% creating the cfg structure in which host and port name is specified

cfg.host=getIPv4Address;
cfg.port=(51244);

% If not specified, creating default cfg structure for the TCPIP connection

if ~isfield(cfg, 'host'),               cfg.host = 'eeg002';                              end
if ~isfield(cfg, 'port'),               cfg.port = 51244;                                 end % 51244 is for 32 bit, 51234 is for 16 bit
if ~isfield(cfg, 'channel'),            cfg.channel = 'all';                              end
if ~isfield(cfg, 'feedback'),           cfg.feedback = 'no';                              end
if ~isfield(cfg, 'target'),             cfg.target = [];                                  end
if ~isfield(cfg.target, 'datafile'),    cfg.target.datafile = 'buffer://localhost:1972';  end
if ~isfield(cfg.target, 'dataformat'),  cfg.target.dataformat = [];                       end % default is to use autodetection of the output format
if ~isfield(cfg.target, 'eventfile'),   cfg.target.eventfile = 'buffer://localhost:1972'; end

% creating the TCPIP connection using the pnet function

sock = pnet('tcpconnect', cfg.host, cfg.port);

% getting the data and header information

hdr = []; % header

    while isempty(hdr)
    % read the message header
        msg       = [];
        msg.uid   = tcpread_new(sock, 16, 'uint8',1);
        msg.nSize = tcpread_new(sock, 1, 'int32',0);
        msg.nType = tcpread_new(sock, 1, 'int32',0);
    
    % read the message body
        switch msg.nType
        case 1
            % this is a message containing header details
            msg.nChannels         = tcpread_new(sock, 1, 'int32',0);
            msg.dSamplingInterval = tcpread_new(sock, 1, 'double',0);
            msg.dResolutions      = tcpread_new(sock, msg.nChannels, 'double',0);
            for i=1:msg.nChannels
                msg.sChannelNames{i} = tcpread_new(sock, char(0), 'char',0);
            end
            
            % convert to a fieldtrip-like header
            
            hdr.nChans  = msg.nChannels;
            hdr.Fs      = 1/(msg.dSamplingInterval/1e6);
            hdr.label   = msg.sChannelNames;
            hdr.resolutions = msg.dResolutions;
            
            % determine the selection of channels to be transmitted
            
            cfg.channel = ft_channelselection(cfg.channel, hdr.label);
            chanindx = match_str(hdr.label, cfg.channel);
            
            % remember the original header details for the next iteration
            
            hdr.orig = msg;
            
           otherwise
            % skip unknown message types
            % error('unexpected message type from RDA (%d)', msg.nType);
        end
    end

blCount = blPass;
chanindx   = 1:hdr.nChans;      % all channels

%% setting parameters for the chronux toolbox function mtspectrumc for analysing power spectrum of the signal

Fs = hdr.Fs;
params.tapers = [1 1];          % tapers
params.pad = -1;                % no padding
params.Fs = Fs;                 % sampling frequency
params.trialave = 0;            % average over trials
params.fpass = [0 Fs/10];       % frequencies  


%% create the plots-color range

colorLimsRawTF = [-3 3];
colorLimsChangeTF = [-50 50];
count = 0;
X=[];
rawTraceAlpha = [];

%% Reading the data block

while (count < blPass)
    % while (true)
    % read the message header
    msg       = [];
    msg.uid   = tcpread_new(sock, 16, 'uint8',0);
    msg.nSize = tcpread_new(sock, 1, 'int32',0);
    msg.nType = tcpread_new(sock, 1, 'int32',0);
    
    % read the message body
    switch msg.nType
        case 2
            % this is a 16 bit integer data block
            msg.nChannels     = hdr.orig.nChannels;
            msg.nBlocks       = tcpread_new(sock, 1, 'int32',0);
            msg.nPoints       = tcpread_new(sock, 1, 'int32',0);
            % msg.nPoints  = hdr.Fs;
            msg.nMarkers      = tcpread_new(sock, 1, 'int32',0);
            msg.nData         = tcpread_new(sock, [msg.nChannels msg.nPoints], 'int16',0);
            for i=1:msg.nMarkers
                msg.Markers(i).nSize      = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPosition  = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPoints    = tcpread_new(sock, 1, 'int32',0);
                % msg.Markers(i).nPoints   =hdr.Fs;
                msg.Markers(i).nChannel   = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).sTypeDesc  = tcpread_new(sock, char(0), 'char',0);
            end
            
        case 4
            % this is a 32 bit floating point data block
            msg.nChannels     = hdr.orig.nChannels;
            msg.nBlocks       = tcpread_new(sock, 1, 'int32',0);
            msg.nPoints       = tcpread_new(sock, 1, 'int32',0);
            % msg.nPoints=hdr.Fs;
            msg.nMarkers      = tcpread_new(sock, 1, 'int32',0);
            msg.fData         = tcpread_new(sock, [msg.nChannels msg.nPoints], 'single',0);
            
            for i=1:msg.nMarkers
                msg.Markers(i).nSize      = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPosition  = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPoints    = tcpread_new(sock, 1, 'int32',0);
                % msg.Markers(i).nPoints   =hdr.Fs;
                msg.Markers(i).nChannel   = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).sTypeDesc  = tcpread_new(sock, char(0), 'char',0);
            end
            
        case 3
            % acquisition has stopped
            break
            
        otherwise
            % ignore all other message types
    end
        
    
    %% converting the RDA message into data and/or events
    
    dat   = [];
    event = [];
    
    if msg.nType==2 && msg.nPoints>0
        % FIXME should I apply the calibration here?
        dat = msg.nData(chanindx,:);
    end
    
    if msg.nType==4 && msg.nPoints>0
        % FIXME should I apply the calibration here?
        dat = msg.fData(chanindx,:);
    end
    
    if (msg.nType==2 || msg.nType==4) && msg.nMarkers>0
        % FIXME convert the message to events
    end    
    
    % Inside the X variable the converted data from dat is being stored
    
    if ~isempty(dat)
        X=[X dat];
        [~,colum]=size(X);
        
        %% Setting condition so that
        %% Only if the data size reaches the Fs size proceeding for the analysis
        
        if((colum==Fs))
            count       = count + 1;
            blCount     = blCount - 1;
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%                         Inside X; the data is being stored. --> Nextdat               %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            
            
            %% Plotting the raw trace of the signal of the selected channels
            
            rawTraceAlpha = [rawTraceAlpha X(AlphaChans,:)];
            if count>1; rawTraceAlpha(:,1:size(X,2)) = []; end;
            subplot(handles.rawTraceAlpha); plot(1:Fs,rawTraceAlpha); 
            set(handles.rawTraceAlpha,'xticklabels',[],'yticklabels',[]);
            drawnow;
            
            % Converting the data stored in X to single precision and
            % storing in nextdat
            
            nextdat = single(X);
            gain = single(hdr.resolutions'); % getting scaling information from the message header
            gain = repmat(gain,1,size(nextdat,2));
            nextdat = nextdat.*gain;         % scaling the data according to the gain 
            % Now, inside the nextdat the X data is being stored.
            
            X=[];                           % reinitialising the X for the second iteration
            nextdat=nextdat(AlphaChans,:);  % taking the datas corrsponding to the channels 
            
            rawbldata = [rawbldata,nextdat];
            [power(count,:,:),freq] = mtspectrumc(nextdat',params);    % using the chronux toolbar command mtspectrumc the power is being calculated
            
            
            %% if true
            % plot the log BL power continuously(thin line) 
            
            if (blCount >= 0)            
                cla(handles.chPowerAlpha)
                hBaseline=handles.chPowerAlpha;
                sz=size(power);
                if length(sz)>2; meanPower = squeeze(mean(power,3)); else meanPower = power; end;
                powcol=meanPower(count,:);
                plot(hBaseline,freq, conv2Log(powcol), 'color',[0.7 0.7 0.7]);
                xlabel(hBaseline, 'Frequency (Hz)'); ylabel(hBaseline, 'Log(Baseline Power(dB))');
                xlim(hBaseline,[0 50]);
                drawnow;
                
                %% if true
                % plot the baseline power in thick line
                
                if (blCount == 0)
                    
                    rawblpower = meanPower;
                    mLogBL = conv2Log(mean(meanPower,1));
                    % dpower is the substracted final bl power
                    dPower = (conv2Log(meanPower) - repmat(mLogBL,size(meanPower,1),1));                    
                    cla(handles.chPowerAlpha);
                    axes(hBaseline);
                    plot(freq, mLogBL, 'k','linewidth',3);
                    xlabel(hBaseline, 'Frequency (Hz)'); ylabel(hBaseline, 'Log(Baseline Power(dB))');
                    title(hBaseline, 'Log(Baseline power)');
                    xlim(hBaseline, [0 50]);
                    % ylim(hBaseline,[0 10]);
                    drawnow;
                    
                    % cue user's attention
                    fprintf('R E L A X...\n');
                    
                end                
                continue;
                
            end
        end
    end    
end
pnet(sock,'close'); % Closing the port after the analysis is done
end % while true % while true
