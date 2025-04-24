% This function converts Sampsamp 2.1 data to something compatible with the labview
% pipeline used by the hoverfly lab
% MBS 02042025

% The only data it needs is:
% 'data_block'     - continuous 2xn matrix (double)
% 'info'
%  ticktimes_block - only the first occurance.

function samp2labview()
current_dir = pwd; 
disp('Raw data please')
[filename_rawdata,dir_rawdata] = uigetfile();
disp('Location to save output please')
dir_save = uigetdir();

cd(dir_rawdata)
load(filename_rawdata)

disp('Curating Data')
ticktimes_block = Ticktime_Block_1; % pipeline only uses the firt instance


% Define the variable name prefix
prefix = 'Data_Block_';

% 1) Get the list of variables in the workspace
allVars = who;

% 2) Filter only those whose names start with the prefix
dataBlockVars = allVars(startsWith(allVars, prefix));

% 3) Extract the numeric part from each variable name and sort them
nums = zeros(length(dataBlockVars), 1);
for k = 1:length(dataBlockVars)
    % Extract the numeric part after the prefix and convert to number
    numStr = extractAfter(dataBlockVars{k}, prefix);
    nums(k) = str2double(numStr);
end

% Sort the variable names based on the extracted numeric values
[~, sortIdx] = sort(nums);
dataBlockVarsSorted = dataBlockVars(sortIdx);

% 4) Initialize newdatablock
data_block_temp = [];

% 5) Loop over each sorted variable, process, and concatenate:
% After this loop:
% newdatablock(1,:) contains all of the first-column data (in numerical order)
% newdatablock(2,:) contains all of the second-column data

for k = 1:numel(dataBlockVarsSorted)
    % Retrieve the data from the workspace variable
    thisData = eval(dataBlockVarsSorted{k});

    % Keep only columns 1 and 2 (discard column 3)
    thisData = thisData(:, 1:2);

    % Transpose so that row 1 is the first column and row 2 is the second column,
    % then horizontally concatenate the data
    data_block_temp = [data_block_temp, thisData'];

    % Display a progress indicator:
    % For the 1st iteration: '.', 2nd iteration: '..', 3rd iteration: '...', etc.
    progressIndicator = repmat('.', 1, k);
    disp(progressIndicator);
end

data_block = data_block_temp([2 1],:); % make same as sarah/Yuri output

disp('Hold on, saving data.')
cd(dir_save)
save(filename_rawdata,'data_block','ticktimes_block','info')
disp('DONE!')
cd(current_dir)
end
