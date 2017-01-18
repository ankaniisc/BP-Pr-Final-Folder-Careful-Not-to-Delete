
function [data,trialtype,tag] = runprotocol_biofeedback(handles,alphaLowerLimit,alphaUpperLimit,hc)%,betaLowerLimit,betaUpperLimit)

% Desrciption of the script:
% Once the user hits the run button the scrpt will allow 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% taking user input from the subject
% input the subject name
promt = 'Please enter the experiment date : ';
date = input(promt,'s');
prompt = 'Please enter the subject name : ';
subjectname = input(prompt,'s');
% input the block number
% prompt = 'Please enter the block number : ';
% blocknumber = input(prompt,'s');
tag = [date subjectname]; % blocknumber % horizontally concatening two strings


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tot_sessions = 5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:tot_sessions
    
    tot_trials = 4; % defining total number of trials
    % creating the array of trialtypes
    % defining zero for the constant tone    (25% of the total trials),
    % defining one for the dependent tone   (50% of the total trials),
    % defining two for the independent tone (25% of the total trial)
    % generating ones, twos and zeros accordingly 
    trialtype = [zeros(tot_trials/4,1);ones(tot_trials/2,1);repmat(2,tot_trials/4,1)]';

    % randomizing the trialtype

    trialtype = trialtype(randperm(tot_trials));
    disp(trialtype);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    start_value = 1;
    end_value = tot_trials;


    datbl1 = {};
    % datbl2 ={}; 
    % blocknumber = str2double(blocknumber);
    % 
    % if(blocknumber == 2) % load the collected block one data file for saving the block two data into that
    %    protocol = 'biofeedback_';
    %    prevblock = '1.mat';
    %    prevfile = strcat(protocol,date,subjectname,prevblock);
    %    load(prevfile);
    % end



        for i = start_value : end_value 

        %     block   = blocknumber;
        t_type  = trialtype(i); 
        disp(t_type);
        if(i==1)
            pause
            pause(15)
        end

        %     set(hc,'visible','off');
            % Now with this trialtype the script should call the
            % calculatechangeinspectrum function 20 times which will lead to 20
            % trials and after each trial there will be a pause of 10 seconds

                %% baseline

            %% warning to the subject

        pause(5);    
            %% gettin the baseline data while eyes open task
        BLPeriod = str2double(handles.BLPeriod);
        %     AlphaChans = str2double(handles.AlphaChans);   

          %% Calibration
          %%%%%%%%%%%% we need to send the command back to the master gui

            while 1

                [rawbldata,rawblpower,mLogBL,blCount,dPowerBL] = calculateBaseline(BLPeriod,handles,hc);   
                handles.blCount = blCount;
                handles.rawbldata = rawbldata;
                handles.rawblpower = rawblpower;
                handles.mLogBL=mLogBL;
                handles.dPowerBL=dPowerBL;

                %% Ploting the mean alpha raw baseline power
                meanRawBlPower = mean(rawblpower(:,7:13);
                hCheckBaselinePower = handles.checkBaselinePower;
                axes(hCheckBaselinePower);
                plot(i,meanRawBlPower,'*'); hold on
                xlabel(hCheckBaselinePower, 'Trial No'); ylabel(hCheckBaselinePower, 'mean raw baseline alpha power');
                %                     title(hBaseline, 'Log(Baseline power)');
                %                     xlim(hBaseline, [0 50]);
                %                     % ylim(hBaseline,[0 10]);



                %% Checking the baseline power during the start of the eyes close task
                response = checkBaselinePower;
                if response == 1
                    break          
                end
            end
               %% runtime
            [datbl1{1,1}{1,i},datbl1{1,1}{2,i},datbl1{1,1}{3,i},datbl1{1,1}{4,i},datbl1{1,1}{5,i},datbl1{1,1}{6,i},datbl1{1,1}{7,i}]=calculateChangeInSpectrum_ver2(handles,alphaLowerLimit,alphaUpperLimit,t_type,hc);
        %         elseif(block == 2)
        %             [data{2,1}{1,i},data{2,1}{2,i},data{2,1}{3,i},data{2,1}{4,i},data{2,1}{5,i},data{2,1}{6,i},data{2,1}{7,i}]=calculateChangeInSpectrum_ver2(handles,alphaLowerLimit,alphaUpperLimit,t_type,hc);
        %         end    

            data = datbl1;
             bl1Trialtype = trialtype;
            save(['biofeedback_' tag],'data','bl1Trialtype');

        end
end


    
%         elseif blocknumber ==2
%             bl2Trialtype = trialtype;
%             save(['biofeedback_' tag],'data','bl1Trialtype','bl2Trialtype');    
%         end    
    


