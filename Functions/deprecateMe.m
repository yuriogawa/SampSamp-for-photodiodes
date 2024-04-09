% Initialises default settings of the SampSamp application


        init.folderDir = 'E:\';
        init.saveDir = '';                      % Pointer to where data is Stored 
        init.folderName = '';                   % If user pick different folder, it will be stored here
        init.fileNameMat = '';                  % Har för mig att denna är om man väljer ett extra namn på filen ex Frank
        init.fileNameData = 'data_block';       % Each data block gets a name data_block1,...,data_block20,....
        init.fileNameTime = 'ticktimes_block';  % To each block of data a corresponding time stamp is saved with the name ticktimes_block1,....tcktimes_block20,....
        init.dataBlock = 'data_block';          % Each data block gets a name data_block1,...,data_block20,....
        init.fileCounter = 1;                   % Name counter of data files ex. data_block1, data_block2        
