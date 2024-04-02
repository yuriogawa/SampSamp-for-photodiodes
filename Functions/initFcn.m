% Initialises default settings of the SampSamp application
function init = initFcn(option)

switch option
    case 'initRecSettings'
        % Each Nidaq-card when installed gets its own name Dev1,...,Dev100,... 
        % and so on. so far we have 3 different cards
        init.device = 'Dev2';         
        % Manufacturer of the nidaq-card all difrent daq-cards prob. uses the same initiation structure
        init.deviceMan = 'nidaq';     

        init.stopTrigVal = 0;  % Condition value for stop sampling (supplied by GUI)
        init.triggVal = 0;     % Condition value for start sampling (supplied by GUI) 
        init.plotFigData = {}; % "Pointer" to figure in which the data from brain is diplayed 
        init.plotFigTrig = {}; % "Pointer" to figure in which the data from photo diod is diplayed
        init.sampFreq = 40000; % The freaquiensy at which the data is collected (supplied by GUI)
        init.stopSize = 1000;  % The amount of the latest data points that stop condition is checked against

        % Stop trigger can see either if max(the last 160 samples) < stop condition value
        % or min(the last 160 samples) < stop condition value
        init.aboveUnder = true;
        
        % Bounderies for the plotwindows
        init.axisXmin = 0; 
        init.axisXmax = 11;
        init.axisYmin = 0;
        init.axisYmax = 3;  

        init.delaySamples= 0;     % How many samples to store from before the start trigger
        init.countOnOff = 2;      % Counter that makes sure that start button is green when sampling end red when not(that it dosent flicker)        
        init.subPlot = '1:5:end'; % Plots every 5th sample

    case 'initDirSettings'
        init.folderDir = 'E:\';
        init.saveDir = '';                      % Pointer to where data is Stored 
        init.folderName = '';                   % If user pick different folder, it will be stored here
        init.fileNameMat = '';                  % Har för mig att denna är om man väljer ett extra namn på filen ex Frank
        init.fileNameData = 'data_block';       % Each data block gets a name data_block1,...,data_block20,....
        init.fileNameTime = 'ticktimes_block';  % To each block of data a corresponding time stamp is saved with the name ticktimes_block1,....tcktimes_block20,....
        init.dataBlock = 'data_block';          % Each data block gets a name data_block1,...,data_block20,....
        init.fileCounter = 1;                   % Name counter of data files ex. data_block1, data_block2        
end    