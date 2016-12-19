% Data conversion script:
% conversion of the data and plotting teh relevant graphs

%% Plot 2: Alphapower with trialtypes

% clearing all the variable exept the data;
clearvars -except data bl1Trialtype

% load the data file; (imp : change this if the path changes);

load('C:\Users\RayLabCNS\Documents\MATLAB\Ankan_M\Recorded Data\ButterflyProjectRawData\BiofeedbackData_Sayantan_161016\biofeedback_161016SayantanFinal1.mat');

% %% We would define a matix setfreqdata 
% We would define a matix alphapowerdata

% powerdata    = []; dont need it right now

% Creating separate matrix for the constant, alpha and alpha 
% indpendent data
% keeping it same

consData       = [];
alpahDepData   = [];
alphaIndData   = [];

%% Getting specified indices which meets a trial condion.

constant = find(bl1Trialtype==0);
alpahdep = find(bl1Trialtype==1);
alphaind = find(bl1Trialtype==2);

% Next we would in for loop bring the data in it:
% have to change here to bring alphapowerdata from data
% $ for that I have to knwo where alpha power is getting stored?
starttime = 8;
endtime = 57;

for i=1:16
%     rawalphapow = [];
    rawAlphaPow = data{1,1}{2,i};
    rawAlphaPow = rawAlphaPow*10;
    alphaPower = mean(rawAlphaPow(:,8:15),2)';
    alphaPowerAllTrial(i,:) = alphaPower(starttime:endtime);    
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
    consData(i,:) = alphaPowerAllTrial(rowval,:);   
end

% Similarly for other matrices

for i = 1:size(alpahdep,2)
    rowval = alpahdep(i);
    alpahDepData (i,:) = alphaPowerAllTrial(rowval,:);   
end

for i = 1:size(alphaind,2)
    rowval = alphaind(i);
    alphaIndData(i,:) = alphaPowerAllTrial(rowval,:);   
end

% average across trials
% avgacr_trials_consData     = mean(consData,1);
% avgacr_trials_alpaDepData = mean(alpahDepData,1);
% avgacr_trials_alphaIndData = mean(alphaIndData,1);
% average across timeperiods
avgtime_consData = mean(consData(:));         std_ConsData     = (std(consData(:)))/sqrt(200);
avgtime_alpaDepData = mean(alpahDepData(:));   std_alpaDepData  = (std(alpahDepData(:)))/sqrt(400);
avgtime_alphaIndData = mean(alphaIndData(:)); std_alphaIndData = (std(alphaIndData(:)))/sqrt(200);

% acculmulating the datas in one single array;
% in the order : constand dependent independent

trialtypes = [1:3];  % x axis
avgsetfreq = [avgtime_consData,avgtime_alpaDepData,avgtime_alphaIndData];
error_upper      = [0,std_alpaDepData,std_alphaIndData];
error_lower      = [std_ConsData,0,0];
% plotting
bar(trialtypes,avgsetfreq); hold on
hc = errorbar(trialtypes,avgsetfreq,error_lower,error_upper,'.','MarkerSize',20,...
    'MarkerEdgeColor','cyan','MarkerFaceColor','cyan');
set(hc,'color','r')
% grid on
ax = gca;
ax.YMinorGrid = 'on';
set(gca,'YLim',[-4 4],'XTickLabel',{'Constant','Independent','Dependent'})
% ax.XTickLabel={'ankan'} % this would work also, % the hing to remember
% here is to put this string in a cell array not in a matrix.
xlabel('Trialtype','FontSize',12,'FontWeight','bold','Color','k'); ylabel('Change in Alphapower(db)','FontSize',12,'FontWeight','bold','Color','k');
title('Average change in alphapower vs. different trialtypes','FontSize',14,'FontWeight','bold','Color','k');

% save the figure in the pwd;
saveas(gca,'average alpha power vs. different trialtypes.png','png');

