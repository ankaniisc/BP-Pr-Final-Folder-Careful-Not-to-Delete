
%% Continuously aquiring data and plotting RAW POWER SPECTRUM AND LOG POWERSPECTRUM during the eyes open and close task.
%% 

%% Has been updated on 11th october to include the following changes:
        % (1) To include the beta frequency for the aloha independent tone 
        % (2) 
        % (3)

function [rawdata ,powerdata,incrFact,setfreqdata,relqut,susqut] = calculateChangeInSpectrum_ver2(handles,alphaLowerLimit,alphaUpperLimit,t_type)%,betaLowerLimit,betaUpperLimit)

pnet('closeall')   % Closing all the previously opended pnet connections
pauseseconds = 10;  % pause after each trial

betaLowerLimit = 17;
betaUpperLimit = 23;

rawbldata = handles.rawbldata; 
rawdata = rawbldata;
powerdata = [];
incrFact = [];
incrFactBeta = [];
setfreqdata = [];

%% getting the trialtype from the handle

trialType = t_type;

%%  Reading  audio files  and playing the files

[relax.dat, Frelax] = audioread('close_your_eyes.wav');
[conc.dat, Fconc] = audioread('concentrate.wav');

% Initialising the variables

Fsound = 44100; % need a high enough value so that alpha power below baseline can be played
Fc = 900;      % Base frequency (changed from original value i.e. 500 Hz)
Fi = 500;       % Decrement frequency
smoothKernel = repmat(1/10,1,5);
epochsToAvg = length(smoothKernel); 

fprintf('R E L A X...\n');

% Relax now and close your eyes
relaxobj = audioplayer(relax.dat,Frelax);
playblocking(relaxobj);

%%

mLogBL=handles.mLogBL;
AlphaChans=str2num(handles.AlphaChans);
BLPeriod = str2num(handles.BLPeriod);
totPass=handles.totPass;

%% create the plots-color range

colorLimsRawTF = [-3 3];
colorLimsChangeTF = [-10 10];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If not specified, creating default cfg structure for the TCPIP connection

cfg.host=getIPv4Address;
cfg.port=(51244);
if ~isfield(cfg, 'host'),               cfg.host = 'eeg002';                              end
if ~isfield(cfg, 'port'),               cfg.port = 51244;                                 end % 51244 is for 32 bit, 51234 is for 16 bit
if ~isfield(cfg, 'channel'),            cfg.channel = 'all';                              end
if ~isfield(cfg, 'feedback'),           cfg.feedback = 'no';                              end
if ~isfield(cfg, 'target'),             cfg.target = [];                                  end
if ~isfield(cfg.target, 'datafile'),    cfg.target.datafile = 'buffer://localhost:1972';  end
if ~isfield(cfg.target, 'dataformat'),  cfg.target.dataformat = [];                       end % default is to use autodetection of the output format
if ~isfield(cfg.target, 'eventfile'),   cfg.target.eventfile = 'buffer://localhost:1972'; end
if ~isfield(cfg.target, 'eventformat'), cfg.target.eventformat = [];                      end % default is to use autodetection of the output format

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


%% setting parameters for the chronux toolbox function mtspectrumc for analysing power spectrum of the signal
Fs = hdr.Fs;
params.tapers = [1 1]; % tapers [TW,K], K=<2TW-1
params.pad = -1; % no padding
params.Fs = Fs; % sampling frequency
params.trialave = 0; % average over trials
params.fpass = [0 Fs/10];

% Initializing the variables
count = 0; 
X=[];
rawTrace = [];

%% while loop
while (count < totPass)
    %while (true)
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
            %msg.nPoints       =hdr.Fs;
            msg.nMarkers      = tcpread_new(sock, 1, 'int32',0);
            msg.nData         = tcpread_new(sock, [msg.nChannels msg.nPoints], 'int16',0);
            for i=1:msg.nMarkers
                msg.Markers(i).nSize      = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPosition  = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPoints    = tcpread_new(sock, 1, 'int32',0);
                % msg.Markers(i).nPoints    =hdr.Fs;
                msg.Markers(i).nChannel   = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).sTypeDesc  = tcpread_new(sock, char(0), 'char',0);
            end
            
        case 4
            % this is a 32 bit floating point data block
            msg.nChannels     = hdr.orig.nChannels;
            msg.nBlocks       = tcpread_new(sock, 1, 'int32',0);
            msg.nPoints       = tcpread_new(sock, 1, 'int32',0);
            % msg.nPoints       =hdr.Fs;
            msg.nMarkers      = tcpread_new(sock, 1, 'int32',0);
            msg.fData         = tcpread_new(sock, [msg.nChannels msg.nPoints], 'single',0);
            for i=1:msg.nMarkers
                msg.Markers(i).nSize      = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPosition  = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).nPoints    = tcpread_new(sock, 1, 'int32',0);
                %msg.Markers(i).nPoints   =hdr.Fs;
                msg.Markers(i).nChannel   = tcpread_new(sock, 1, 'int32',0);
                msg.Markers(i).sTypeDesc  = tcpread_new(sock, char(0), 'char',0);
            end
            
        case 3
            % acquisition has stopped
            break
            
        otherwise
            % ignore all other message types
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% data story this function:
    
    % inside the dat new data in being stored
    % and this is being concatenated in the X
    % the X is being converted to single and
    % is stored in nextdat
    % changing the resolution to get original rawdata by multiplying gain
    % with it and updating the nextdat
    
    
    % convert the RDA message into data and/or events
    dat   = []; 
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

    if ~isempty(dat)
        X = [X dat];
        [~,col]= size(X); % getting information about about the size of the rawdata X

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if((col == Fs))
            
            rawTrace = [rawTrace X(AlphaChans,:)];  % plotting EEG Trace of the channels
            if count>0; rawTrace(:,1:size(X,2)) = []; end;
            subplot(handles.rawTraceAlpha); plot(1:Fs,rawTrace);
            drawnow;
            
            count = count + 1;
            
            nextdat= single(X);
            gain = single(hdr.resolutions');
            gain = repmat(gain,1,size(nextdat,2));
            nextdat = nextdat.*gain;
            nextdat=nextdat(AlphaChans,:);
            rawdata = [rawdata nextdat];
            X=[];
           [power(count,:,:),freq] = mtspectrumc(nextdat',params);
                        
                        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if (count == 1)
                % inserting the dPower of the baseline and the power of the  1st count of
                % the runtime
                
                dPower = handles.dPowerBL;
                dPower=double(dPower);
                alphaPower = mean(dPower(:,alphaLowerLimit:alphaUpperLimit),2);
                dPower=[dPower; double(conv2Log(squeeze(mean(power(count,:,:),3)))) - mLogBL];
                
                              
               %% introducing a new variable 'cap' in which count for the incrFactRaw and incrFact would be kept.
               % calculating the frequency
               
                cap = BLPeriod + count; % starting the count after the baseline epoch
                incrFact(cap) = mean(mean(dPower(end-epochsToAvg+1:end,alphaLowerLimit:alphaUpperLimit),2)'*smoothKernel');
                incrFacUt = [incrFact incrFact(cap)];
                 
                %% make a incrFact to capture the beta power 
                incrFactBeta(cap) = mean(mean(dPower(end-epochsToAvg+1:end,betaLowerLimit:betaUpperLimit),2)'*smoothKernel');
                incrFactBeta = [incrFactBeta incrFactBeta(cap)];
                
               if(trialType == 0)
                    disp('playing constant tone');
                    stFreq = Fc;
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone   
                    setfreqdata = stFreq;
                    disp(stFreq);
               elseif(trialType ==1)
                    disp('playing alpha dependent tone');
                    stFreq = round(Fc - incrFact(cap) * Fi);                           
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone
                    setfreqdata = stFreq;
                    disp(stFreq);
               elseif(trialType ==2)
                    disp('playing alpha independent tone');
% %                     900-(500*(randi([-1,1]*10^n,[1,1])/10^n)/10)
%                     stFreq = round(Fc - (Fi*rand/10));
%                     soundTone = sine_tone(Fsound,1,stFreq); 
%                     sound(soundTone,Fsound); 
%                     setfreqdata = stFreq;
%                     disp(stFreq);
                    stFreq = round(Fc - incrFactBeta(cap) * Fi);                           
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone
                    setfreqdata = stFreq;
                    disp(stFreq);
               end
            
            end
            
            
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            if (count > 1)              
                
                %% change in pow spectrum
                dPower = ([dPower; double(conv2Log(squeeze(mean(power(count,:,:),3))) - mLogBL)]);
                
                powerdata = dPower;
                % get the frequency
                cap = BLPeriod + count;                        
                incrFact(cap) = mean(mean(dPower(end-epochsToAvg+1:end,alphaLowerLimit:alphaUpperLimit),2)'*smoothKernel');
                
                %% make a incrFact to capture the beta power        
                incrFactBeta(cap) = mean(mean(dPower(end-epochsToAvg+1:end,betaLowerLimit:betaUpperLimit),2)'*smoothKernel');
                
                if(trialType == 0) 
                    stFreq = Fc;
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone 
                    setfreqdata = [setfreqdata stFreq];
                    disp(stFreq);
               elseif(trialType == 1)
                    stFreq = round(Fc - incrFact(cap) * Fi);                           
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone  
                    setfreqdata = [setfreqdata stFreq];
                    disp(stFreq);
               elseif(trialType == 2)
%                      stFreq = round(Fc - (Fi*rand/10));
% %                    900-(500*(randi([-1,1]*10^n,[1,1])/10^n)/10)
% %                    stFreq = round(Fc - incrFact(cap) * Fi*rand*8);
% %                    stFreq = stFreq*rand;
%                     sound(soundTone,Fsound); 
%                     setfreqdata = [setfreqdata stFreq];
%                     disp(stFreq);
                    stFreq = round(Fc - incrFactBeta(cap) * Fi);                           
                    soundTone = sine_tone(Fsound,1,stFreq); 
                    sound(soundTone,Fsound); % play the sound tone
                    setfreqdata = stFreq;
                    disp(stFreq);                  
               end

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

                axes(handles.tfAlpha);

                pcolor(1:size(dPower,1), freq, 10*double(dPower(1:size(dPower,1),:)')); hold on;
                colormap jet; shading interp;
                plot(1:size(dPower,1),alphaUpperLimit,'k'); hold on;
                plot(1:size(dPower,1),alphaLowerLimit,'k'); hold off;
                shading interp;
                title('Time Frequency Plot')
                xlabel(handles.tfAlpha, 'Time (s)'); ylabel(handles.tfAlpha, 'Frequency');
                caxis(handles.tfAlpha,[-10 10]);
                xlim(handles.tfAlpha,[1 totPass+BLPeriod]);
                ylim(handles.tfAlpha, [0 Fs/10]); drawnow;

            end
            
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
            cla(handles.chPowerAlpha);
            
            subplot(handles.chPowerAlpha)
            
            if iscolumn(alphaPower); alphaPower = alphaPower'; end;

            alphaPower = [alphaPower incrFact(cap)];

            plot((1:length(alphaPower)),10*alphaPower,'k'); hold on;

            xlim(handles.chPowerAlpha,[2 totPass+BLPeriod]);
            ylim(handles.chPowerAlpha, [-4 4]); drawnow;

            xlabel(handles.chPowerAlpha, 'Frequency (Hz)'); ylabel(handles.chPowerAlpha, 'Change in Power(dB)');
            title(handles.chPowerAlpha, 'Change in baseline power');
            drawnow;
                      
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %% change in POW THICK LINE
            if(count==totPass)
                cla(handles.chPowerAlpha)
                hChange=handles.chPowerAlpha;
                subplot(hChange);
                plot(freq,10*mean(dPower), 'k','linewidth',2);
                xlabel(hChange, 'Frequency (Hz)');
                ylabel(hChange, 'Change in Power(dB)');
                title(hChange, 'Change in baseline power');
                xlim(hChange, [0 50]); drawnow;
                
                
                %% Giving user the feedback about his/her performance
                %% Relaxation and sustenance quotient
                
                analysisRange = 5:totPass;
                rawblpower = handles.rawblpower;
                blCount = handles.blCount;

                blPowerArray = mean(rawblpower(2:blCount,alphaLowerLimit:alphaUpperLimit),2);
                stPowerArray = mean(power(analysisRange,alphaLowerLimit:alphaUpperLimit),2);

                changeArray = stPowerArray/mean(blPowerArray) - 1;

                quot = 100*mean(changeArray);
                relqut = quot;
                fluct = std(stPowerArray)/mean(stPowerArray);
                susqut = (1/fluct)*100;  % Converting the variablily to sustainability index
                fprintf('open your eyes and relax...\n');
                concobj = audioplayer(conc.dat,Fconc);
                playblocking(concobj);
                fprintf('End of the demo\n');
                
                % show a message box
                h = msgbox(['Your relaxation quotient is ' num2str(relqut) ' % and your sustenance quotient is ' num2str(susqut)], 'EEG Demo', 'help');
                pause(pauseseconds);
                close(h);
            end
            
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



pnet(sock,'close');


end

