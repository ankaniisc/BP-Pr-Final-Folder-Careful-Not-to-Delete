% Data conversion script:


% clearing all the variable exept the data;
clearvars -except data bl1Trialtype

% load the data file; (imp : change this if the path changes);

load('C:\Users\Last Effort\Documents\Matlab\Biofeedback\ButterflyProjectRawData\BiofeedbackData_Sayantan_161016\biofeedback_161016SayantanFinal1.mat');

%% We would define a matix setfreqdata 

setfreqdata    = [];

% Creating separate matrix for the constant, alpha and alpha 
% indpendent data

consData       = [];
alpahDepData   = [];
alphaIndData   = [];

%% Getting specified indices which meets a trial condion.

constant = find(bl1Trialtype==0);
alpahdep = find(bl1Trialtype==1);
alphaind = find(bl1Trialtype==2);

% Next we would in for loop bring the data in it:

for i=1:16
    setfreqdata(i,:) = data{1,1}{4,i};    
end

%% Note: set freq data is a matrix which have the setfredata in 
%  The x axis and in y axis(coloum no) denotes the trail no)
%  Now from this I have to pull out the trials which I need.
%  Now I would make three matix out of this original matrix
%  each one would be for a separate trial type

%% Creating final data matrix

% Creating consdata matrix

for i = 1:size(constant,2)
    rowval = constant(i);
    consData(i,:) = setfreqdata(rowval,:);   
end

for i = 1:size(alpahdep,2)
    rowval = alpahdep(i);
    alpahDepData (i,:) = setfreqdata(rowval,:);   
end

for i = 1:size(alphaind,2)
    rowval = alphaind(i);
    alphaIndData(i,:) = setfreqdata(rowval,:);   
end

% average across trials
avgacr_trials_consData     = mean(consData,1);
avgacr_trials_alpaDepData = mean(alpahDepData,1);
avgacr_trials_alphaIndData = mean(alphaIndData,1);
% average across timeperiods
avgtime_consData = mean(avgacr_trials_consData,2);         std_ConsData     = std(avgacr_trials_consData);
avgtime_alpaDepData = mean(avgacr_trials_alpaDepData,2);   std_alpaDepData  = std(avgacr_trials_alpaDepData);
avgtime_alphaIndData = mean(avgacr_trials_alphaIndData,2); std_alphaIndData = std(avgacr_trials_alphaIndData);

% acculmulating the datas in one single array;
% in the order : constand dependent independent

trialtypes = [1:3];  % x axis
avgsetfreq = [avgtime_consData,avgtime_alpaDepData,avgtime_alphaIndData];
error      = [std_ConsData,std_alpaDepData,std_alphaIndData];

% plotting
bar(trialtypes,avgsetfreq); hold on
hc = errorbar(trialtypes,avgsetfreq,error,'.','MarkerSize',20,...
    'MarkerEdgeColor','cyan','MarkerFaceColor','cyan');
set(hc,'color','r')
% grid on
ax = gca;
ax.YMinorGrid = 'on';
set(gca,'YLim',[0 1000],'XTickLabel',{'Constant','Independent','Dependent'})
% ax.XTickLabel={'ankan'} % this would work also, % the hing to remember
% here is to put this string in a cell array not in a matrix.
xlabel('Trialtype','FontSize',12,'FontWeight','bold','Color','k'); ylabel('Average feedback frequency of the tone','FontSize',12,'FontWeight','bold','Color','k');
title('Average set frequency of the feedback tone vs. different trialtypes','FontSize',14,'FontWeight','bold','Color','k');

% save the figure in the pwd;
saveas(gca,'Average set frequency of the feedback tone vs. different trialtypes.jpeg','jpeg');
