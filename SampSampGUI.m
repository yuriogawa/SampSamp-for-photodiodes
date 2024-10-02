function varargout = SampSampGUI(varargin)
% SAMPSAMP M-file for sampsamp.fig
%      SAMPSAMP, by itself, creates a new SAMPSAMP or raises the existing
%      singleton*.
%
%      H = SAMPSAMP returns the handle to a new SAMPSAMP or the handle to
%      the existing singleton*flyfly
%
%      SAMPSAMP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMPSAMP.M with the given input arguments.
%
%      SAMPSAMP('Property','Value',...) creates a new SAMPSAMP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sampsamp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sampsamp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sampsamp

% Last Modified by GUIDE v2.5 28-Mar-2012 10:49:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sampsampGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @sampsampGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%% --- Executes just before sampsamp is made visible.
function sampsampGUI_OpeningFcn(hObject, ~, handles, ~)
% hObject    handle to figure
% handles    structure with handles and user data (see GUIDATA)

%% Define our figure variables here
% Information about the connected DAQ device
handles.daqConnection = "Dev1"; % Refers to what NI device is being used
handles.daqType = "ni"; % Name of daqDevice
handles.DAQ = [];% Handle to connected DAQ hardware object
handles.analogueInputChoice = []; % What is the chosen input source (represents a0 - a7)

% Options relating to trigger values for DAQ
handles.useTrigger = true;
handles.startTrigVal = [];
handles.stopTrigVal = [];
handles.TrigActive = [];
handles.maxCaptureTime = 15; % Determines the largest possible recording time for a single data block

handles.trigEnd = []; % Index pointer to the end of a data block

handles.aboveUnder = []; % Change to something else, confusing

% State of the DAQ device during data acquisition
handles.currentState = 'Acquisition.ReadyForCapture';

% Path and name to the .mat file representing the current recording
handles.recordingName = [];
% Bounderies for the plotwindows
handles.axisXmin = 0; 
handles.axisXmax = 11;
handles.axisYmin = 0;
handles.axisYmax = 3;  

handles.countOnOff = 2;      % Counter that makes sure that start button is green when sampling end red when not(that it dosent flicker)        
handles.subPlot = '1:5:end'; % Plots every 5th sample

% Define properties regarding saving data
handles.files = [];                         % List of individual .mat files containing data
handles.fileNameData = 'data_block';        % Each data block gets a name data_block1,...,data_block20,....
handles.fileNameTime = 'ticktimes_block';   % To each block of data a corresponding time stamp is saved with the name ticktimes_block1,....tcktimes_block20,....
handles.dataBlock = 'data_block';           % Each data block gets a name data_block1,...,data_block20,....
handles.fileCounter = 1;                    % Name counter of data files ex. data_block1, data_block2        
handles.counter = [];                       % Counts data blocks for long recording sessions
handles.lastSaveTime = 0;                   % Contains timestamp for last autosave during no trigger

handles.FIFOBuffer = [];
handles.captureStartMoment = [];            % Index pointing to beginning of data block
handles.captureEndMoment = [];              % Index to end of data block

% Links to the folder created when saving data
handles.currentRecordingFolder = [];

%% --- Executes just before sampsamp is made visible.
uiWindow=gcf;

% Set access to figure window for easy editing
setappdata(0,'samsamWindow',uiWindow);

% Set the default path to SampSamp's main folder
defaultPath = which("SampSampGUI");
defaultPath = strsplit(defaultPath, 'SampSampGUI');

handles.saveDir.String = defaultPath{1};

handles.analogueInputChoice = [handles.a0.Value, handles.a1.Value, ...
                               handles.a2.Value, handles.a3.Value, ...
                               handles.a4.Value, handles.a5.Value, ...
                               handles.a6.Value, handles.a7.Value];     

handles.startTrigVal = str2double(handles.startTrigValue.Value);
handles.stopTrigVal  = str2double(handles.stopTrigValue.Value);
handles.useTrigger   = handles.trigOrNot.Value;
% Broken
handles.aboveUnder   = handles.stopTrigger.SelectedObject;

% Choose default command line output for sampsamp
handles.output = hObject;

% --- Executes on button press in startDAQ.
function startDAQ_Callback(~, ~, handles)
% hObject    handle to startDAQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in startDAQ.
daqreset;

% Reset FIFO buffer data
handles.FIFOBuffer = [];

% Reset Data and Timestamps
handles.lastSaveTime = 0;

recordStart = string (datetime("now"));
recordStart = strrep(recordStart, ":", "_");
newFolder = append (string(handles.saveDir.Text), "\", recordStart);
handles.currentRecordingFolder = newFolder;
mkdir(newFolder);

handles.recordingName = append(newFolder, '\', recordStart, '.mat');

info = '---------Data from sampsamp--------------';
save(handles.recordingName,'info');

% Reset files variable
handles.files={''};

% Function to load selected channels and apply daq settings to a new daq object 
configureDAQ(handles);

% Set counter for datablock
handles.counter = 1;

% Start DAQ device, quit if errors occcur
try
    start(handles.DAQ,'continuous');
    tic
catch error
    disp('error starting DAQ device');
    disp(error)
    return
end

handles.currentState = 'Acquisition.Buffering';
handles.startDAQ.FontColor = 'green';

if handles.useTrigger == 0
    % Need to find replacement in modern DAQ toolbox, there was
    % code here to be able to istantly 'getdata' and save the
    % data, time, and 'abstime'
end

function scansAvailable_Callback(~, ~, handles)
% scansAvailable_Callback Executes on DAQ ScansAvailable event
% This callback function gets executed periodically as more data is acquired by the daqDevice.
% This callback is setup in the script 'configureDAQ.m' 
    tic
    
    % Continuous acquisition data and timestamps are stored in FIFO data buffers
    % Calculate required buffer size -- this should be large enough to accomodate the
    % the data required for the live view time window and the data for the requested
    % capture duration.
    
    [data,timestamps] = read(src, src.ScansAvailableFcnCount, 'OutputFormat','Matrix');
    
    bufferSize = str2double(handles.timeoutSecs.Value) * str2double(handles.sampleFrequency.Value);

    % FIFO Buffer setup:
    % (1) is timestamps
    % (2) is trigger data
    % (3) is participant data
    handles.FIFOBuffer = storeDataInFIFO(handles.FIFOBuffer, bufferSize, timestamps, data);
    % App state control logic 
    switch handles.currentState
        case 'Acquisition.Buffering'
            % Buffering pre-trigger data, this points to a script
            % in the 'Functions' folder
            if isEnoughDataBuffered(handles.FIFOBuffer(:, 1), handles.delaySamples.Value)
                % Depending if user wants to employ a software
                % trigger or not, change state
                handles.currentState = 'Capture.CapturingData';
                if handles.useTrigger
                    handles.currentState = 'Capture.LookingForTrigger';
                else
                    handles.captureStartMoment = handles.lastSaveTime;
                    handles.currentState = 'Capture.CapturingData';
                end
            end
        case 'Capture.LookingForTrigger'
            % Looking for trigger event in the latest data
            trigActive = detectStartTrigger(handles);
            if trigActive
                handles.currentState = 'Capture.CapturingData';
            end
        case 'Capture.CapturingData'
            % Get index for where data block starts
            dataBlockStartIndex = find(handles.FIFOBuffer(:, 1) >= handles.captureStartMoment, 1, 'first');
            dataBlockLength = size(handles.FIFOBuffer, 1) - dataBlockStartIndex;
            % Only show available data, up to the maximum window, and only show data from the current data block
            samplesToPlot = min([round(str2double(handles.viewWindowLength.Value) * src.Rate), size(handles.FIFOBuffer,1), dataBlockLength]);
            firstPoint = size(handles.FIFOBuffer, 1) - samplesToPlot + 1;

            % Plot the trigger data if the user has selected the relevant checkbox
            if handles.showTrigger.Value
                plot(handles.triggerPlot, handles.FIFOBuffer(firstPoint:end, 1), ...
                     handles.FIFOBuffer(firstPoint:end, 2));
            end
            % Always plot the recorded data when collecting data 
            plot(handles.dataPlot, handles.FIFOBuffer(firstPoint:end, 1), ...
                 handles.FIFOBuffer(firstPoint:end, 3));

            % Wrap axis limits around the data
            handles.triggerPlot.XLim = [handles.FIFOBuffer(firstPoint, 1), handles.FIFOBuffer(end, 1)];
            handles.dataPlot.XLim = [handles.FIFOBuffer(firstPoint, 1), handles.FIFOBuffer(end, 1)];
            drawnow
            % First case: when triggers are used, check to save
            % data by either a timeout 
            if handles.trigOrNot == 1
                timeoutResult = str2double((handles.FIFOBuffer(end,1)-handles.captureStartMoment)) > str2double(handles.timeoutSecs.Value);
                endTriggerResult = detectEndTrigger(handles);
                if any(timeoutResult) || any(endTriggerResult)
                    completeCapture(handles)
                end
            % Second case: no trigger is used, save the current
            % data as it is being recorded to prevent dropped data
            else
                timeoutResult = handles.FIFOBuffer(end,1) - handles.lastSaveTime > str2double(handles.timeoutSecs.Value) - 1;
                if any(timeoutResult)
                    completeCapture_noTrigg(handles)
                end
            end
    end
    toc

function trigActive = detectStartTrigger(~, ~, handles)
%detectTrigger Detects trigger condition and updates relevant app properties
% Updates TrigActive, TrigMoment, and CaptureStartMoment app properties
    freq       = str2double(handles.sampleFrequency.Value);
    updateFreq = str2double(handles.updateFrequency.Value);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(handles.FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents photo-diode channel
    trigConfig.Level = handles.startTrigValue.Value;
    trigConfig.Condition = 'Rising';
    [trigActive, handles.captureStartMoment] = ...
        trigDetect(handles.FIFOBuffer(index: end, 1), handles.FIFOBuffer(index: end, 2), trigConfig);

function result = detectEndTrigger(~, ~, handles)
% detectTrigger Detects trigger condition and updates relevant app properties
% Updates TrigActive, TrigMoment, and CaptureStartMoment app properties
    freq            = str2double(handles.sampleFrequency.Value);
    updateFreq      = str2double(handles.updateFrequency.Value);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(handles.FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents Stabby-stab channel
    trigConfig.Level = handles.stopTrigValue.Value;
    trigConfig.Condition = 'Falling';
    [result, handles.captureEndMoment] = ...
        trigDetect(handles.FIFOBuffer(index: end, 1), handles.FIFOBuffer(index: end, 2), trigConfig);

function completeCapture(~, ~, handles)
% completeCapture Saves captured data to user folder and resets DAQ
% device to wait for another trigger
    % Find index of first sample in data buffer to be captured
    firstSampleIndex = find(handles.FIFOBuffer(:, 1) >= handles.captureStartMoment, 1, 'first');
    
    % Find index of last sample in data buffer that complete the capture
    lastSampleIndex = find(handles.FIFOBuffer(:, 1) >= handles.captureEndMoment, 1, 'first');

    if isempty(firstSampleIndex) || isempty(lastSampleIndex) || lastSampleIndex > size(handles.FIFOBuffer(:, 1), 1)
        % If the index's either don't exist or go outside the
        % expected range of the captured data, abort.
        % Fill this with more sampsamp related warnings
        uialert(fig, 'Could not complete capture.', 'Capture error');
        return
    end

    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(handles.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(handles.counter));
    
    % Extract capture data and shift timestamps so that 0 corresponds to the trigger moment
    % Save these to Data_Block_n and Ticktime_Block_n, respectively 
    captureDataCmd = strcat(dataBlockName, "= [handles.dataFIFOBuffer(firstSampleIndex:lastSampleIndex), " + ...
        "handles.triggerPlotFIFOBuffer(firstSampleIndex:lastSampleIndex)];");
    ticktimeCmd = strcat(timeBlockName, "= convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');");
    % Run these commands
    eval(captureDataCmd)
    eval(ticktimeCmd)

    % Create and run a save script using our dynamic variables
    saveCmd = strcat("save(app.recordingName, '", dataBlockName, ...
        "', '", timeBlockName, "', '-append');");
    eval(saveCmd)

    %---Save the handle structure-----
    handles.counter = handles.counter + 1;
    %---------------------------------

    %---start the daq-object again-----
    try
        % start(app.DAQ, 'Continuous')
        handles.currentState = 'Capture.LookingForTrigger';
    catch
        disp 'Timed out';
    end

function completeCapture_noTrigg(~, ~, handles)
% completeCapture Saves captured data to user folder for when no
% trigger is used, ends recording session.
    
    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(handles.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(handles.counter));

    % Find the last time data was autosaved and grab its index
    saveConditionMet = handles.FIFOBuffer(:, 1) >= handles.lastSaveTime;
    saveIndex = 1 + find(saveConditionMet==1, 1, 'first'); %#ok<NASGU> This is fine as it is used in an eval() command
    handles.lastSaveTime = handles.FIFOBuffer(end, 1);
    
    % Extract capture data and shift timestamps so that 0 corresponds to the trigger moment
    % Save these to Data_Block_n and Ticktime_Block_n, respectively 
    captureDataCmd = strcat(dataBlockName, "= [app.FIFOBuffer(saveIndex:end, 3), " + ...
        "app.FIFOBuffer(saveIndex:end, 2)];");
    ticktimeCmd = strcat(timeBlockName, "= convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');");
    % Run these commands
    eval(captureDataCmd)
    eval(ticktimeCmd)

    % Create and run a save script using our dynamic variables
    saveCmd = strcat("save(app.recordingName, '", dataBlockName, ...
        "', '", timeBlockName, "', '-append');");
    eval(saveCmd)

    %---Save the handle structure-----
    handles.counter = handles.counter + 1;
    %--------------------------------- 

function configureDAQ(handles)
    % Obtain variables from app properties
    ai              = handles.analogueInputChoice;
    d               = daq(handles.daqType);
    freq            = str2double(handles.sampleFrequency.Value);
    updateFreq      = str2double(handles.updateFrequency.Value);
    
    % When you add channels you need the number of the
    % port to sample from to activate it, under this a vector is created
    % which elements represent 
    
    for i=0:7
        if ai(i+1) == 1
            % If selected, add a channel to be recorded to DAQ object
            addinput(d, handles.daqConnection, i, "Voltage");
        end
    end
    
    %-------------------Specific properties for trigger------------------------
    
    % Configure DAQ ScansAvailableFcn callback function
    d.ScansAvailableFcn = @(src,event) scansAvailable_Callback(handles, src, event);
    d.ScansAvailableFcnCount = freq * (updateFreq / 1000); % Update Freq is in milli seconds, put back into seconds
    
    % Sets sample rate of ai will be rounded off to closest possible sampling rate 
    %(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
    d.Rate = freq;
    
    handles.DAQ = d;

% --- Executes on button press in reset.
function stopDAQ_Callback(~, ~, handles)
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in reset.

if ~isempty(handles.DAQ)
    stop(handles.DAQ);
end
if handles.trigOrNot.Value == 0
    completeCapture_noTrigg(handles);
end
handles.startDAQ.FontColor = 'red';
handles.currentState = 'Acquisition.ReadyForCapture';

% --- Executes on button press in openFolder.
function openFolder_Callback(~, ~, handles)
% hObject    handle to openFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir=uigetdir;
if ~dir==0
    set(handles.saveDir,'String',dir);
end


% --- Executes on button press in fromAbove.
function fromAbove_Callback(~, ~, handles)
% hObject    handle to fromAbove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value = get(handles.fromAbove,'Value');
if value
    set(handles.fromUnder,'Value', false);
else
    set (handles.fromUnder,'Value',true);
end

% Hint: get(hObject,'Value') returns toggle state of fromAbove


% --- Executes on button press in fromUnder.
function fromUnder_Callback(~, ~, handles)
% hObject    handle to fromUnder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
value =get(handles.fromUnder,'Value');
if value
    set(handles.fromAbove,'Value',false);
else
    set(handles.fromAbove,'Value',true);
end

% --- Executes on selection change in trigOrNot.
function trigOrNot_Callback(~, ~, handles)
% hObject    handle to trigOrNot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = handles.trigOrNot.Value;
% This needs to be checked
handles.useTrigger = val;
switch val
    case 1
        % Enable trigger options
        handles.startTrigger.Enable = 'On';
        handles.startTrigValue.Enable = 'On';
        handles.triggerUnit_1.Enable = 'On';
        handles.triggerUnit_2.Enable = 'On';
        handles.stopTrigger.Enable = 'On';
        handles.stopTrigValue.Enable = 'On';
    case 0
        % Disable trigger options
        handles.startTrigger.Enable = 'Off';
        handles.startTrigValue.Enable = 'Off';
        handles.triggerUnit_1.Enable = 'Off';
        handles.triggerUnit_2.Enable = 'Off';
        handles.stopTrigger.Enable = 'Off';
        handles.stopTrigValue.Enable = 'Off';
end

function timeoutSecs_Callback(~, ~, handles)
    if str2double(handles.timeoutSecs.Value) < 5
        msgbox("Timeout cannot be less than 5 seconds","Warning","warn");
        handles.timeoutSecs.Value = '5';
    end
