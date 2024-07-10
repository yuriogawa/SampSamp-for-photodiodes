function sampsamp()

% _____                       _____                       
%/  ___|                     /  ___|                      
%\ `--.  __ _ _ __ ___  _ __ \ `--.  __ _ _ __ ___  _ __  
% `--. \/ _` | '_ ` _ \| '_ \ `--. \/ _` | '_ ` _ \| '_ \ 
%/\__/ / (_| | | | | | | |_) /\__/ / (_| | | | | | | |_) |
%\____/ \__,_|_| |_| |_| .__/\____/ \__,_|_| |_| |_| .__/ 
%                      | |                         | |    
%                      |_|                         |_|    
%|------------------------------------------------------|
%|   SampSamp 2.0 - Trigger-based recording software    |
%|                                                      |
%|    -Requires MatLab 2023 with DAQ toolbox            |
%|    -Requires Windows 10/11 with min. 8Gb of RAM      |
%|                                                      |
%|                                                      |
%| info@flyfly.se             (c) Someone 2009          |
%|------------------------------------------------------|
%
%               Why did the samp samp?
%              Because the samp... what '<'
%
%

disp(' ');
disp(' -SampSamp 2.0- ');

addpath(cd, [cd '/' genpath('Functions')]);
SampSampGUI;