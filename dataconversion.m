% data conversion script:

%% we would define a matix setfreqdata 

setfreqdata =[];

%%getting specified indices which meets a trial condion.
constant = find(bl1Trialtype==0);
alpahdep = find(bl1Trialtype==1);
alphaind = find(bl1Trialtype==2);

%next we would in for loop bring the data in it:

for i=1:16
    setfreqdata(i,:) = data{1,1}{4,i};    
end

%% set freq data is a matrix which have the setfredata in 
% the x axis and in y axis(coloum no) denotes the trail no)

%% Now from this I have to pull out the trials which I need.

%% Now I would make three matix out of this original matrix
% each one would be for a separate trial type

consdata = 

