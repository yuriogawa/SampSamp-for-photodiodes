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
%|   SampSamp 2.0 - Visual Stimulus user interface      |
%|                                                      |
%|    -Requires MatLab 2023 with Psychophysics toolbox  |
%|    -Documentation and user's manual available        |
%|                                                      |
%|                                                      |
%| info@flyfly.se             (c) Someone 2009          |
%|------------------------------------------------------|
%
%               Why did the fly fly?
%            Because the spider spied 'er!
%
%

disp(' ');
disp(' -SampSamp 2.0- ');

addpath(cd, [cd '/' genpath('Functions')]);
SampSampGUI;