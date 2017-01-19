function hc = tcpip_gui_ver_1_4

%% The new version of the TCP ip code adds a fourth plot which would check the baseline power.

%% fonts

hc = figure(1123);
fontSizeSmall = 10; fontSizeMedium = 12; fontSizeLarge = 16; fontSizeTiny = 8;
% baselineperiod = num2str(7); exp_runtime = 50;
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
chanFile = 'biofeedback_5Ch';%'biofeedback_5ch.mat';
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
        'Style','edit','String','7','FontSize',fontSizeSmall);  % Creating the Handle for the Baseline period 

% Run-time

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'Position',[0 1-2*(dynamicHeight+dynamicGap) dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','text','String','Run time (s)','FontSize',fontSizeSmall);
hRunTime = uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
        'BackgroundColor', backgroundColor, 'Position', ...
        [dynamicTextWidth 1-2*(dynamicHeight+dynamicGap) 1-dynamicTextWidth-dynamicGap dynamicHeight], ...
        'Style','edit','String','50','FontSize',fontSizeSmall); % Handle for the experiment runtime
 
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

%% Buttons associated with specific function callbacks

% Callback baseline function for analysis
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[0 1-7*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight],...
    'Style','pushbutton','String','Calibrate','FontSize',fontSizeSmall);

% Callback stimulus function for analysis
uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[(dynamicTextWidth*2-dynamicGap)/2 1-7*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight],...
    'Style','pushbutton','String','Run','FontSize',fontSizeSmall);

uicontrol('Parent',hDynamicPanel,'Unit','Normalized', ...
    'Position',[(dynamicTextWidth*1-dynamicGap)/2 1-8*(dynamicHeight+dynamicGap) (dynamicTextWidth*2-dynamicGap)/2 dynamicHeight],...
    'Style','pushbutton','String','START','FontSize',fontSizeSmall,'Callback',{@run_Callback});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Getting handles for the plots 

plotsStartPos = capStartPos*2+controlPanelWidth; plotsStartHeight = controlPanelStartHeight; plotsWidth = 1-(plotsStartPos+capStartPos); plotsHeight = 1-plotsStartHeight*2;
plotsPos = [plotsStartPos plotsStartHeight*2 plotsWidth plotsHeight];
plotHandles = getPlotHandles(6,1,plotsPos,0.05,0.05,0);

%% Creating plots and geeting the handles 

% plotHandles = getPlotHandles(1,1,[],0.05,0.05,0);
% plotHandles = getPlotHandles(1,2,[plotsStartPos plotsStartHeight plotsWidth/2 0.3],0.05,0.05,0);
% plotHandles = getPlotHandles(1,3,[plotsStartPos plotsStartHeight plotsWidth 0.3],0.05,0.05,0);

% 
% rawTraceAlpha = plotHandles(1,1);
% tfAlpha = plotHandles(2,1);
% chPowerAlpha = plotHandles(3,1);
% checkBaselinePower = plotHandles(4,1);

%%%%
%% plot handles of the three experimental plots
rawTraceAlpha   = plotHandles(1,1);
tfAlpha         = plotHandles(2,1);
chPowerAlpha    = plotHandles(3,1);

%%%%
%% plot handles for the three result plot
alphapowerttime  = plotHandles(4,1);
alpahpowerttno   = plotHandles(5,1);
alphapowerblttno = plotHandles(6,1);



%% creating handles for passing on
handles                     = [];
handles.rawTraceAlpha       = rawTraceAlpha;
handles.tfAlpha             = tfAlpha;
handles.chPowerAlpha        = chPowerAlpha;
handles.chanlocs            = chanlocs;

handles.alphapowerttime     = alphapowerttime;
handles.alpahpowerttno      = alpahpowerttno;
handles.alphapowerblttno    = alphapowerblttno;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Callback functions

% Baseline callback
%% Commenting the baseline code

%     function rawbldata = calcBL_Callback(~,~)
%         BLPeriod = get(hBLPeriod,'String');
%         AlphaChans = get(hPoolElecAlpha,'String');
% 
%         handles.AlphaChans = AlphaChans;
%         handles.BLPeriod = BLPeriod;
%         
%         [rawbldata,~,mLogBL,~,dPowerBL] = calculateBaseline(BLPeriod,handles);
%         savefile = 'rawbldata.mat';
%         handles.mLogBL=mLogBL;
%         handles.dPowerBL=dPowerBL;
%         save(savefile,'rawbldata');
%     end

% Runtime callback

    function [data,trialtype,tag]= run_Callback(~,~)   
        warning('off','MATLAB:hg:willberemoved');        
        
        %% Including more necessary handles
        
        BLPeriod = get(hBLPeriod,'String');
        AlphaChans = get(hPoolElecAlpha,'String');
        handles.AlphaChans = AlphaChans;
        handles.BLPeriod = BLPeriod;
        
        handles.totPass= str2num(get(hRunTime,'String'));
        alphaRangeMin =  str2num(get(hAlphaRangeMin,'string'));
        alphaRangeMax =  str2num(get(hAlphaRangeMax,'string'));

        [data,trialtype,tag] = runprotocol_biofeedback(handles,alphaRangeMin,alphaRangeMax,hc);
%         save(['biofeedback_' tag],'data','trialtype');
    end



end