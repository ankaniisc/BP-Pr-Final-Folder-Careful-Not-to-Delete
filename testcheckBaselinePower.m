
function response = checkBaselinePower

% Construct a questdlg with three options
choice = questdlg('Was baseline calculation done alright?', ...
	'Baseline Calculation', ...
	'Yes','No','Yes');

% Handle response

switch choice
    case 'Yes'
        disp([choice ' : Starting the eyes close task'])
        response = 1;       
        
    case 'No'
        disp([choice ' : Calculating the baseline once again'])
        response = 0;      
        
  end