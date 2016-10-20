
cd C:\Users\RayLabCNS\Documents\MATLAB;
warning('off','all'); rmpath(genpath(pwd)); warning('on','all');
cd C:\Users\RayLabCNS\Documents\MATLAB\Ankan_M;
% addpath(genpath(fullfile(pwd,'toolboxes','sigstar')),'-begin');
addpath(genpath(fullfile(pwd,'Aa TCP IP Online Analysis','Codes','Toolboxes and Common Programs')));
rmpath(genpath(fullfile(pwd,'Aa TCP IP Online Analysis','Codes','Toolboxes and Common Programs','eeglab12_0_2_5b','functions','octavefunc')));
warning('off','MATLAB:hg:willberemoved');

% Select the folder of the analysis
addpath(genpath(fullfile(pwd,'Aa TCP IP Online Analysis','Codes','BP-Pr-Final-Folder-Careful-Not-to-Delete')));