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

% Last Modified by MBS 31st March 2025. 

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
    % Information about the connected DAQ vendorid
    properties.daqConnection = "Dev1"; % Refers to what NI device is being used
    properties.daqType = "ni"; % Name of daqDevice
    properties.DAQ = [];% Handle to connected DAQ hardware object
    properties.analogueInputChoice = []; % What is the chosen input source (represents a0 - a7)
    
    % Options relating to trigger values for DAQ
    properties.useTrigger = true;
    properties.startTrigVal = [];
    properties.stopTrigVal = [];
    properties.TrigActive = [];
    properties.maxCaptureTime = 15; % Determines the largest possible recording time for a single data block
    
    properties.trigEnd = []; % Index pointer to the end of a data block
    
    properties.aboveUnder = []; % Change to something else, confusing
    
    % State of the DAQ vendorid during data acquisition
    properties.currentState = 'Acquisition.ReadyForCapture';
    
    % Path and name to the .mat file representing the current recording
    properties.recordingName = [];
    % Bounderies for the plotwindows
    properties.axisXmin = 0;
    properties.axisXmax = 11;
    properties.axisYmin = 0;
    properties.axisYmax = 3;
    
    properties.countOnOff = 2;      % Counter that makes sure that start button is green when sampling end red when not(that it dosent flicker)
    properties.subPlot = '1:5:end'; % Plots every 5th sample
    
    % Define properties regarding saving data
    properties.files = [];                         % List of individual .mat files containing data
    properties.fileNameData = 'data_block';        % Each data block gets a name data_block1,...,data_block20,....
    properties.fileNameTime = 'ticktimes_block';   % To each block of data a corresponding time stamp is saved with the name ticktimes_block1,....tcktimes_block20,....
    properties.dataBlock = 'data_block';           % Each data block gets a name data_block1,...,data_block20,....
    properties.fileCounter = 1;                    % Name counter of data files ex. data_block1, data_block2
    properties.counter = [];                       % Counts data blocks for long recording sessions
    properties.lastSaveTime = 0;                   % Contains timestamp for last autosave during no trigger
    
    % FIFO Buffer gets large, so set as a global variable to reduce load times
    global FIFOBuffer %#ok<*GVMIS>
    FIFOBuffer = [];
    properties.captureStartMoment = [];            % Index pointing to beginning of data block
    properties.captureEndMoment = [];              % Index to end of data block
    
    % Links to the folder created when saving data
    properties.currentRecordingFolder = [];
    
    %% --- Executes just before sampsamp is made visible.
    uiWindow=gcf;
    
    % Set access to figure window for easy editing
    setappdata(0,'samsamWindow',uiWindow);
    
    % Set the default path to SampSamp's main folder
    defaultPath = which("SampSampGUI");
    defaultPath = strsplit(defaultPath, 'SampSampGUI');
    
    handles.saveDir.String = defaultPath{1};
    
    % Find the currently connected DAQ vendor types
    vendors = daqvendorlist;
    vendors = {vendors.ID};
    handles.vendorID.String = vendors;
    
    device = daqlist(vendors{1});
    device = {device.DeviceID};
    handles.deviceID.String = device;
    
    properties.analogueInputChoice = [handles.a0.Value, handles.a1.Value, ...
                                      handles.a2.Value, handles.a3.Value, ...
                                      handles.a4.Value, handles.a5.Value, ...
                                      handles.a6.Value, handles.a7.Value];
    
    properties.startTrigVal = str2double(handles.startTrigValue.Value);
    properties.stopTrigVal  = str2double(handles.stopTrigValue.Value);
    properties.useTrigger   = handles.trigOrNot.Value;
    % Broken
    properties.aboveUnder   = handles.aboveOrUnder.Value;
    
    % Choose default command line output for sampsamp
    properties.output = hObject;
    
    setappdata(0, 'properties', properties)

% --- Executes on button press in startDAQ.
% handles    structure with handles and user data (see GUIDATA)
function startDAQ_Callback(~, ~, handles)
    daqreset;
    
    properties = getappdata(0, 'properties');
    
    % Reset FIFO buffer data
    global FIFOBuffer
    FIFOBuffer = [];
    
    % Reset Data and Timestamps
    properties.lastSaveTime = 0;
    
    recordStart = string (datetime("now"));
    recordStart = strrep(recordStart, ":", "_");
    newFolder = append(string(handles.saveDir.String), "\", recordStart);
    properties.currentRecordingFolder = newFolder;
    mkdir(newFolder);
    
    properties.recordingName = append(newFolder, '\', recordStart, '.mat');
    
    info = '---------Data from sampsamp 2.1 --------------';
    save(properties.recordingName,'info');
    
    % Save the nominated sample rate into the .mat file
    SampleRate = str2double(handles.sampleFrequency.String);
    save(properties.recordingName, 'SampleRate', '-append');
    
    % Reset files variable
    properties.files={''};
    
    % Function to load selected channels and apply daq settings to a new daq object
    properties = configureDAQ(handles, properties);
    
    % Set counter for datablock
    properties.counter = 1;
    
    % Start DAQ vendorid, quit if errors occcur
    try
        start(properties.DAQ,'continuous');
        tic
    catch error
        disp('error starting DAQ device');
        disp(error)
        return
    end
    
    properties.currentState = 'Acquisition.Buffering';
    handles.startDAQ.ForegroundColor = 'green';
    
    if properties.useTrigger == 0
        % Need to find replacement in modern DAQ toolbox, there was
        % code here to be able to istantly 'getdata' and save the
        % data, time, and 'abstime'
    end
    setappdata(0, 'properties', properties)

% scansAvailable_Callback Executes on DAQ ScansAvailable event
% This callback function gets executed periodically as more data is acquired by the daqDevice.
% This callback is setup in the script 'configureDAQ.m'
function scansAvailable_Callback(handles, src, ~)
    global FIFOBuffer
    properties = getappdata(0, 'properties');
    
    % Continuous acquisition data and timestamps are stored in FIFO data buffers
    % Calculate required buffer size -- this should be large enough to accomodate the
    % the data required for the live view time window and the data for the requested
    % capture duration.
    
    [data,timestamps] = read(src, src.ScansAvailableFcnCount, 'OutputFormat','Matrix');
    
    bufferSize = str2double(handles.timeoutSecs.String) * str2double(handles.sampleFrequency.String);
    
    % FIFO Buffer setup:
    % (1) is timestamps
    % (2) is trigger data
    % (3) is participant data
    FIFOBuffer = storeDataInFIFO(FIFOBuffer, bufferSize, timestamps, data);
    % App state control logic
    switch properties.currentState
        case 'Acquisition.Buffering'
            % Buffering pre-trigger data, this points to a script
            % in the 'Functions' folder
            if isEnoughDataBuffered(FIFOBuffer(:, 1), str2double(handles.delaySamples.String))
                % Depending if user wants to employ a software
                % trigger or not, change state
                if properties.useTrigger
                    properties.currentState = 'Capture.LookingForTrigger';
                else
                    properties.captureStartMoment = properties.lastSaveTime;
                    properties.currentState = 'Capture.CapturingData';
                    properties.captureStart = convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');
                end
            end
        case 'Capture.LookingForTrigger'
            % Looking for trigger event in the latest data
            [trigActive, properties] = detectStartTrigger(handles, properties);
            if trigActive
                properties.currentState = 'Capture.CapturingData';
                properties.captureStart = convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');
            end
        case 'Capture.CapturingData'
            % Get index for where data block starts
            dataBlockStartIndex = find(FIFOBuffer(:, 1) >= properties.captureStartMoment, 1, 'first');
            dataBlockLength = size(FIFOBuffer, 1) - dataBlockStartIndex;
            % Only show available data, up to the maximum window, and only show data from the current data block
            samplesToPlot = min([round(str2double(handles.viewWindowLength.String) * src.Rate), size(FIFOBuffer,1), dataBlockLength]);
            firstPoint = size(FIFOBuffer, 1) - samplesToPlot + 1;
    
            % Get a value to downsample to a desired number for optimising plotting
            downsampleFrequency = 100;
            dsVal = floor(src.Rate / downsampleFrequency);
    
            % Plot the trigger data if the user has selected the relevant checkbox
            if handles.showTrigger.Value
                plot(handles.triggerPlot, downsample(FIFOBuffer(firstPoint:end, 1), dsVal), ...
                    downsample(FIFOBuffer(firstPoint:end, 2), dsVal));
            end
            % Always plot the recorded data when collecting data
            plot(handles.dataPlot, downsample(FIFOBuffer(firstPoint:end, 1), dsVal), ...
                downsample(FIFOBuffer(firstPoint:end, 3), dsVal));
    
            % Wrap axis limits around the data
            handles.triggerPlot.XLim = [FIFOBuffer(firstPoint, 1), FIFOBuffer(firstPoint, 1) + str2double(handles.viewWindowLength.String)];
            handles.dataPlot.XLim = [FIFOBuffer(firstPoint, 1), FIFOBuffer(firstPoint, 1) + str2double(handles.viewWindowLength.String)];
            %drawnow
            % First case: when triggers are used, check to save
            % data by either a timeout
            if properties.useTrigger
                timeoutResult = str2double((FIFOBuffer(end,1)-properties.captureStartMoment)) > str2double(handles.timeoutSecs.String);
                [endTriggerResult, properties] = detectEndTrigger(handles, properties);
                if any(timeoutResult) || any(endTriggerResult)
                    properties = completeCapture(handles, properties);
                end
                % Second case: no trigger is used, save the current
                % data as it is being recorded to prevent dropped data
            else
                timeoutResult = FIFOBuffer(end,1) - properties.lastSaveTime > str2double(handles.timeoutSecs.String) - 1;
                if any(timeoutResult)
                    properties = completeCapture_noTrigg(handles, properties);
                end
            end
    end
    setappdata(0, 'properties', properties);

% detectStartTrigger Detects trigger condition to start a data block.
% Updates TrigActive and CaptureStartMoment app properties
function [trigActive, properties] = detectStartTrigger(handles, properties)
    global FIFOBuffer
    freq       = str2double(handles.sampleFrequency.String);
    updateFreq = str2double(handles.updateFrequency.String);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents photo-diode channel
    trigConfig.Level = str2double(handles.startTrigValue.String);
    trigConfig.Condition = 'Rising';
    [trigActive, properties.captureStartMoment] = ...
        trigDetect(FIFOBuffer(index: end, 1), FIFOBuffer(index: end, 2), trigConfig);

% detectEndTrigger Detects trigger condition to stop current data block and updates relevant app properties
% (TrigActive and CaptureEndMoment)
function [result, properties] = detectEndTrigger(handles, properties)
    global FIFOBuffer
    freq            = str2double(handles.sampleFrequency.String);
    updateFreq      = str2double(handles.updateFrequency.String);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents Stabby-stab channel
    trigConfig.Level = str2double(handles.stopTrigValue.String);
    trigConfig.Condition = 'Falling';
    [result, properties.captureEndMoment] = ...
        trigDetect(FIFOBuffer(index: end, 1), FIFOBuffer(index: end, 2), trigConfig);

% completeCapture Saves captured data to user folder and resets DAQ
% vendorid to wait for another trigger
function properties = completeCapture(~, properties)
    % Find index of first sample in data buffer to be captured
    global FIFOBuffer
    firstSampleIndex = find(FIFOBuffer(:, 1) >= properties.captureStartMoment, 1, 'first');
    
    % Find index of last sample in data buffer that complete the capture
    lastSampleIndex = find(FIFOBuffer(:, 1) >= properties.captureEndMoment, 1, 'first');
    
    if isempty(firstSampleIndex) || isempty(lastSampleIndex) || lastSampleIndex > size(FIFOBuffer(:, 1), 1)
        % If the index's either don't exist or go outside the
        % expected range of the captured data, abort.
        % Fill this with more sampsamp related warnings
        uialert(fig, 'Could not complete capture.', 'Capture error');
        return
    end
    
    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(properties.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(properties.counter));
    
    % Extract capture data and shift timestamps so that 0 corresponds to the trigger moment
    % Save these to Data_Block_n and Ticktime_Block_n, respectively
    captureDataCmd = strcat(dataBlockName, "= [FIFOBuffer(firstSampleIndex:lastSampleIndex, 3), " + ...
        "FIFOBuffer(firstSampleIndex:lastSampleIndex, 2)];");
    % Update captureStart to the current time for this capture block
    properties.captureStart = convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');
    setappdata(0, 'properties', properties);  % Update the shared properties
    ticktimeCmd = strcat(timeBlockName, "= properties.captureStart;");
    
    % Run these commands
    eval(captureDataCmd)
    eval(ticktimeCmd)
    
    % Create and run a save script using our dynamic variables
    saveCmd = strcat("save(properties.recordingName, '", dataBlockName, ...
        "', '", timeBlockName, "', '-append');");
    eval(saveCmd)
    
    %---Save the handle structure-----
    properties.counter = properties.counter + 1;
    %---------------------------------
    
    %---start the daq-object again-----
    try
        % start(app.DAQ, 'Continuous')
        properties.currentState = 'Capture.LookingForTrigger';
    catch
        disp 'Timed out';
    end
    
% completeCapture Saves captured data to user folder for when no
% trigger is used, ends recording session.
function properties = completeCapture_noTrigg(~, properties)
    global FIFOBuffer
    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(properties.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(properties.counter));
    
    % Find the last time data was autosaved and grab its index
    saveConditionMet = FIFOBuffer(:, 1) >= properties.lastSaveTime;
    saveIndex = 1 + find(saveConditionMet==1, 1, 'first'); %#ok<NASGU> This is fine as it is used in an eval() command
    properties.lastSaveTime = FIFOBuffer(end, 1);
    
    % Update the capture start timestamp to the current time for this block
    properties.captureStart = convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');
    setappdata(0, 'properties', properties);  % Update the shared properties
    
    % Extract capture data and shift timestamps so that 0 corresponds to the trigger moment
    % Save these to Data_Block_n and Ticktime_Block_n, respectively
    captureDataCmd = strcat(dataBlockName, "= [FIFOBuffer(saveIndex:end, 3), " + ...
        "FIFOBuffer(saveIndex:end, 2), FIFOBuffer(saveIndex:end, 1)];");
    ticktimeCmd = strcat(timeBlockName, "= properties.captureStart;");
    % Run these commands
    eval(captureDataCmd)
    eval(ticktimeCmd)
    
    % Create and run a save script using our dynamic variables
    saveCmd = strcat("save(properties.recordingName, '", dataBlockName, ...
        "', '", timeBlockName, "', '-append');");
    eval(saveCmd)
    
    %---Save the handle structure-----
    properties.counter = properties.counter + 1;
    %---------------------------------

% Obtain variables from app properties
function properties = configureDAQ(handles, properties)
    properties.analogueInputChoice = [handles.a0.Value, handles.a1.Value, ...
                                      handles.a2.Value, handles.a3.Value, ...
                                      handles.a4.Value, handles.a5.Value, ...
                                      handles.a6.Value, handles.a7.Value];
    ai              = properties.analogueInputChoice;
    d               = daq(handles.vendorID.String{handles.vendorID.Value});
    freq            = str2double(handles.sampleFrequency.String);
    updateFreq      = str2double(handles.updateFrequency.String);
    
    % When you add channels you need the number of the
    % port to sample from to activate it, under this a vector is created
    % which elements represent
    
    for i=0:7
        if ai(i+1) == 1
            % If selected, add a channel to be recorded to DAQ object
            addinput(d, handles.deviceID.String{handles.deviceID.Value}, i, "Voltage");
        end
    end
    
    %-------------------Specific properties for trigger------------------------
    
    % Configure DAQ ScansAvailableFcn callback function
    d.ScansAvailableFcn = @(src,event) scansAvailable_Callback(handles, src, event);
    d.ScansAvailableFcnCount = freq * (updateFreq / 1000); % Update Freq is in milli seconds, put back into seconds
    
    % Sets sample rate of ai will be rounded off to closest possible sampling rate
    %(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
    d.Rate = freq;
    
    properties.DAQ = d;

% --- Executes on button press in reset.
% handles    structure with handles and user data (see GUIDATA)
function stopDAQ_Callback(~, ~, handles)
    properties = getappdata(0, 'properties');
    
    if ~isempty(properties.DAQ)
        stop(properties.DAQ);
    end
    if handles.trigOrNot.Value == 2
        completeCapture_noTrigg(handles, properties);
    end
    handles.startDAQ.ForegroundColor = 'red';
    properties.currentState = 'Acquisition.ReadyForCapture';
    setappdata(0, 'properties', properties)
    
% --- Executes on button press in openFolder.
% handles    structure with handles and user data (see GUIDATA)
function openFolder_Callback(~, ~, handles)
    saveDirectory=uigetdir;
    if ~saveDirectory==0
        set(handles.saveDir,'String',saveDirectory);
    end

% --- Executes on button press in fromAbove.
% handles    structure with handles and user data (see GUIDATA)
function aboveOrUnderTrig(~, ~, handles)
    properties = getappdata(0, 'properties');
    val = handles.trigOrNot.Value;
    switch val
        case 1
            properties.useTrigger = true;
        case 2
            properties.useTrigger = false;
    end
    setappdata(0, 'properties', properties)

% --- Executes on button press in fromUnder.
% handles    structure with handles and user data (see GUIDATA)
function fromUnder_Callback(~, ~, handles)
    value =get(handles.fromUnder,'Value');
    if value
        set(handles.fromAbove,'Value',false);
    else
        set(handles.fromAbove,'Value',true);
    end

% --- Executes on selection change in trigOrNot.
% handles    structure with handles and user data (see GUIDATA)
function trigOrNot_Callback(~, ~, handles)
    properties = getappdata(0, 'properties');
    val = handles.trigOrNot.Value;
    % This needs to be checked
    
    switch val
        case 1
            % Enable trigger options
            handles.startTrigger.Enable = 'On';
            handles.startTrigValue.Enable = 'On';
            handles.triggerUnit_1.Enable = 'On';
            handles.triggerUnit_2.Enable = 'On';
            handles.stopTrigger.Enable = 'On';
            handles.stopTrigValue.Enable = 'On';
            properties.useTrigger = true;
        case 2
            % Disable trigger options
            handles.startTrigger.Enable = 'Off';
            handles.startTrigValue.Enable = 'Off';
            handles.triggerUnit_1.Enable = 'Off';
            handles.triggerUnit_2.Enable = 'Off';
            handles.stopTrigger.Enable = 'Off';
            handles.stopTrigValue.Enable = 'Off';
            properties.useTrigger = false;
    end
    setappdata(0, 'properties', properties)

function timeoutSecs_Callback(~, ~, handles)
    if str2double(handles.timeoutSecs.String) < 5
        msgbox("Timeout cannot be less than 5 seconds","Warning","warn");
        handles.timeoutSecs.String = '5';
    end

% --- Outputs from this function are returned to the command line.
function sampsampGUI_OutputFcn(~, ~, ~)
% Get default command line output from handles structure
% varargout{1} = handles.output;


% --- Executes on selection change in vendorID.
function vendorChanged_Callback(~, ~, handles)

    currentVendor = handles.vendorID.String{handles.vendorID.Value};
    vendorDevices = daqlist(currentVendor);
    vendorDevices = {vendorDevices.DeviceID};
    handles.deviceID.String = vendorDevices;


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
