% Data conversion script:
% conversion of the data and plotting the relevant graphs

%% Plot 3: To check that the alphapower is changing as time or not?

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

% consData       = [];
% alpahDepData   = [];
% alphaIndData   = [];

%% Getting specified indices which meets a trial condion.

constant = find(bl1Trialtype==0);
alpahdep = find(bl1Trialtype==1);
alphaind = find(bl1Trialtype==2);

% Next we would in for loop bring the data in it:
% have to change here to bring alphapowerdata from data
% $ for that I have to knwo where alpha power is getting stored?
starttime = 8;
endtime = 57;

%% Extracting alphapower from the recorded data:

for i=1:16
%     rawalphapow = [];
    rawAlphaPow = data{1,1}{2,i};
    rawAlphaPow = rawAlphaPow*10;
    alphaPower = mean(rawAlphaPow(:,8:15),2)';
    alphaPowerAllTrial(i,:) = alphaPower(starttime:endtime);    
end

average_alphaPowerAllTrials = mean(alphaPowerAllTrial,1);
% average_alphaPowerAllTrials = average_alphaPowerAllTrials';

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
% 
% % Similarly for other matrices
% 
for i = 1:size(alpahdep,2)
    rowval = alpahdep(i);
    alpahDepData (i,:) = alphaPowerAllTrial(rowval,:);   
end
% 
for i = 1:size(alphaind,2)
    rowval = alphaind(i);
    alphaIndData(i,:) = alphaPowerAllTrial(rowval,:);   
end

% average across trials
% avgacr_trials_consData     = mean(consData,1);
% avgacr_trials_alpaDepData = mean(alpahDepData,1);
% avgacr_trials_alphaIndData = mean(alphaIndData,1);

% average across timeperiods 
avgtime_consData = mean(consData,1)';         % std_ConsData     = std(avgacr_trials_consData);    
avgtime_alpaDepData = mean(alpahDepData,1)';  % std_alpaDepData  = std(avgacr_trials_alpaDepData);
avgtime_alphaIndData = mean(alphaIndData,1)'; % std_alphaIndData = std(avgacr_trials_alphaIndData);


% acculmulating the datas in one single array;
% in the order : constand dependent independent

timepoint = [1:50];  % x axis
% constrailno = [1,2,3,4];
% deptrailano = [1,2,3,4,5,6,7,8];
% indtraialno = [1,2,3,4];

% avgsetfreq = [avgtime_consData,avgtime_alpaDepData,avgtime_alphaIndData];
% error_upper      = [0,std_alpaDepData,std_alphaIndData];
% error_lower      = [std_ConsData,0,0];
% plotting
% bar(trialtypes,avgsetfreq); hold on
% hc = errorbar(trialtypes,avgsetfreq,error_lower,error_upper,'.','MarkerSize',20,...
%     'MarkerEdgeColor','cyan','MarkerFaceColor','cyan');

subplot(2,3,1);
plot(timepoint,avgtime_consData,'b-');
% set(gca,'XTickLabel',{'1','2','3','4'});
title('Contant feedback','FontSize',10,'FontWeight','bold','Color','k');
xlabel('Time(sec)','FontSize',8,'FontWeight','bold','Color','k'); ylabel('Change in Alphapower(db)','FontSize',8,'FontWeight','bold','Color','k');
subplot(2,3,2);
plot(timepoint,avgtime_alpaDepData,'b-');
% set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8'});
title('AlphaDep Feedback','FontSize',10,'FontWeight','bold','Color','k');
xlabel('Time(sec)','FontSize',8,'FontWeight','bold','Color','k'); ylabel('Change in Alphapower(db)','FontSize',8,'FontWeight','bold','Color','k');
subplot(2,3,3);
plot(timepoint,avgtime_alphaIndData,'b-');
% set(gca,'XTickLabel',{'1','2','3','4'});
title('AlphaInDep Feedback','FontSize',10,'FontWeight','bold','Color','k');
xlabel('Time(sec)','FontSize',8,'FontWeight','bold','Color','k'); ylabel('Change in Alphapower(db)','FontSize',8,'FontWeight','bold','Color','k');
subplot(2,3,[4,5,6]);
plot(timepoint,average_alphaPowerAllTrials,'b-');
% set(hc,'color','r')
% grid on
ax = gca;
ax.YMinorGrid = 'on';
% set(gca,'XTickLabel',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16'})
% ax.XTickLabel={'ankan'} % this would work also, % the hing to remember
% here is to put this string in a cell array not in a matrix.
xlabel('Time(sec)','FontSize',12,'FontWeight','bold','Color','k'); ylabel('Change in Alphapower(db)','FontSize',12,'FontWeight','bold','Color','k');
title('Change in AlphaPower  vs. time (average across all trials)','FontSize',14,'FontWeight','bold','Color','k');

% save the figure in the pwd;
saveas(gca,'Average alpha power vs. time.png','png');

