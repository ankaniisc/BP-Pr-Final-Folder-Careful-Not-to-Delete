function tcpip_gui_ver_1_2

%% fonts

fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;

% Make Panels

% Defining Basic positions

capHeight = 0.3; capStartHeight = 0.68; capWidth = 0.22; capStartPos = 0.03; 
controlPanelHeight = 0.58; controlPanelStartHeight = 0.03;
controlPanelWidth = capWidth; controlPanelPos = capStartPos;
timingPanelWidth = 0.18; timingStartPos = controlPanelPos+controlPanelWidth;
tfPanelWidth = 0.18; tfStartPos = timingStartPos+timingPanelWidth;
plotOptionsPanelWidth = 0.18; plotOptionsStartPos = tfStartPos+tfPanelWidth;
backgroundColor = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Topoplot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% loading the channel location file
chanFile = 'realTimeAnalysisActicap32';%'biofeedback_5ch.mat';
locpath=fullfile(pwd,chanFile);
chanLocFile = load(locpath);
chanlocs = chanLocFile.chanlocs;

% Position for the scalpmap on the GUI
electrodeCapPos = [capStartPos capStartHeight capWidth capHeight];
capHandle = subplot('Position',electrodeCapPos);
subplot(capHandle); topoplot([],chanlocs,'electrodes','numbers','style','blank','drawaxis','off'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Control Panel %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Making The Panel

dynamicHeight = 0.09; dynamicGap=0.015; dynamicTextWidth = 0.5;
hDynamicPanel = uipanel('Title','Control Panel','fontSize', fontSizeLarge, ...
    'Unit','Normalized','Position',[controlPanelPos controlPanelStartHeight controlPanelWidth controlPanelHeight]);

% Baseline

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-1*(dynamicHeight+dynamicGap) dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','text','String','Baseline Period (s)','FontSize',fontSizeSmall);
hBLPeriod = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-1*(dynamicHeight+dynamicGap) 1-dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','edit','String','10','FontSize',fontSizeSmall);  % Creating the Handle for the Baseline period 

% Run-time

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','text','String','Run time (s)','FontSize',fontSizeSmall);
hRunTime = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','edit','String','20','FontSize',fontSizeSmall); % Handle for the experiment runtime
 
% Frequency Range for analysis 

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-3*(dynamicHeight+dynamicGap) dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','text','String','Frequency Range','FontSize',fontSizeSmall);
hAlphaRangeMin = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-3*(dynamicHeight+dynamicGap) (1-dynamicTextWidth-dynamicGap)/2 dynamicHeight], ...
        'Style','edit','String','7','FontSize',fontSizeSmall);
hAlphaRangeMax = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth+(1-dynamicTextWidth-dynamicGap)/2 1-3*(dynamicHeight+dynamicGap) (1-dynamicTextWidth-dynamicGap)/2 dynamicHeight], ...
        'Style','edit','String','13','FontSize',fontSizeSmall);
    
% Electrodes to pool

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-5*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight], ...
        'Style','text','String','Elecs to pool','FontSize',fontSizeSmall);
hPoolElecAlpha = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [(dynamicTextWidth*2-dynamicGap)/2 1-5*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight], ...
        'Style','edit','String','1 2 3 4 5','FontSize',fontSizeSmall);

% Buttons associated with specific function callbacks

% Callback baseline function for analysis
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight],...
    'Style','pushbutton','String','Calibrate','FontSize',fontSizeSmall,'Callback',{@calcBL_Callback});

% Callback stimulus function for analysis
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[(dynamicTextWidth*2-dynamicGap)/2 1-7*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight],...
    'Style','pushbutton','String','Run','FontSize',fontSizeSmall,'Callback',{@run_Callback});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Getting handles for the plots 

plotsStartPos = capStartPos*2+controlPanelWidth; plotsStartHeight = controlPanelStartHeight; plotsWidth = 1-(plotsStartPos+capStartPos); plotsHeight = 1-plotsStartHeight*2;
plotsPos = [plotsStartPos plotsStartHeight plotsWidth plotsHeight];
plotHandles = getPlotHandles(3,1,plotsPos,0.05,0.05,0);

rawTraceAlpha = plotHandles(1,1);
tfAlpha = plotHandles(2,1);
chPowerAlpha = plotHandles(3,1);

handles = [];
handles.rawTraceAlpha = rawTraceAlpha;
handles.tfAlpha = tfAlpha;
handles.chPowerAlpha = chPowerAlpha;
handles.chanlocs = chanlocs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Callback functions

% Baseline callback

    function rawbldata = calcBL_Callback(~,~)
        BLPeriod = get(hBLPeriod,'String');
        AlphaChans = get(hPoolElecAlpha,'String');

        handles.AlphaChans = AlphaChans;
        handles.BLPeriod = BLPeriod;
        
        [rawbldata,mLogBL,~,dPowerBL] = calculateBaseline(BLPeriod,handles);
        savefile = 'rawbldata.mat';
        handles.mLogBL=mLogBL;
        handles.dPowerBL=dPowerBL;
        save(savefile,'rawbldata');
    end

% Runtime callback

    function [data,trialtype,tag]= run_Callback(~,~)   
        warning('off','MATLAB:hg:willberemoved');
        
        BLPeriod = get(hBLPeriod,'String');
        AlphaChans = get(hPoolElecAlpha,'String');
        handles.AlphaChans = AlphaChans;
        handles.BLPeriod = BLPeriod;
        
        handles.totPass= str2num(get(hRunTime,'String'));
        alphaRangeMin =  str2num(get(hAlphaRangeMin,'string'));
        alphaRangeMax =  str2num(get(hAlphaRangeMax,'string'));

        [data,trialtype,tag] = runprotocol_biofeedback(handles,alphaRangeMin,alphaRangeMax);
%         save(['biofeedback_' tag],'data','trialtype');
    end



end