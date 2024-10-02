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

% --- Executes just before sampsamp is made visible.
function sampsamp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sampsamp (see VARARGIN)

% Choose default command line output for sampsamp
handles.output = hObject;

% UIWAIT makes sampsamp wait for user response (see UIRESUME)
% uiwait(handles.figure1);

samHandles=samHandlesLoade()


if ~exist('samHandles.nameNull')
    samHandles.nameNull = get(handles.name,'String');
end

h=gcf;
setappdata(0,'samsam',h);
setappdata(0,'t',0);
setappdata(0,'samHandles',samHandles);

if ~isempty(timerfind)    
    stop(timerfind)
    delete(timerfind)
end
t = timer('TimerFcn', @(h, ev)posSampSamp(handles,2),'StartDelay',0.1);

% set(t,'timerFcn',@timerCallback);
start(t)
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in startDAQ.
function startDAQ_Callback(hObject, eventdata, handles)
% hObject    handle to startDAQ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
daqreset;

% setappdata(0,'stophand',hnadles
samHandles=getappdata(0,'samHandles');

%----------samHandlesRefresh updates the samHandles to user choices-------
%##############own funktion samHandlesRefresh###############
[handles,samHandles] = sampHandelsRefresh(handles,samHandles);
%-------------------------------------------------------------------------

%------------------Positioning of sampsamp-------------------------
%##################own function posSampSamp###################
%[handles] = posSampSamp(handles,2);
%------------------------------------------------------------------------


mkdir(samHandles.folderDir);

info = '---------Data from sampsamp--------------';
save([samHandles.folderDir '\' samHandles.fileNameMat '.mat'],'info');


% ------------------------------------------------------
scnsize = get(0,'screensize');

samsam = getappdata(0,'samsam');
posSamsam = get(samsam,'Position');
outpossamsam = get(samsam,'OuterPosition');
bordersamsam = outpossamsam - posSamsam;
samsamSize = outpossamsam([3 4]);

sizeAvFoFig = [(scnsize(3) - samsamSize(1)) (scnsize(4)*0.9)];

% global hfig.fig1
% samHandles.plotFigData=handles.dataPlot; %  pos outpos borders apsize newPos
% samHandles.plotFigDataAxis = handles.dataPlot;
% samHandles.plotFigTrig = handles.triggerPlot;
% samHandles.plotFigTrigAxis = handles.triggerPlot;
samHandles.plotFigData=handles.triggerPlot; %  pos outpos borders apsize newPos
samHandles.plotFigDataAxis = handles.triggerPlot;
samHandles.plotFigTrig = handles.dataPlot;
samHandles.plotFigTrigAxis = handles.dataPlot;
cla(samHandles.plotFigDataAxis);
cla(samHandles.plotFigTrigAxis);
files={''};
setappdata(0,'Files',files);
% %----------------------------Creates the ai----------------------------


ai = analoginput(samHandles.deviceMan,samHandles.device);
if get(handles.trigg,'Value')==1
    [handles,samHandles, ai]=aiLoader(handles,samHandles,ai);
else 
    [handles,samHandles,ai] = aiLoaderNoTrigg(handles, samHandles,ai);
end   
%------------------------SET PROPERTIES OF AI------------------------------
set(handles.freq,'String',get(ai,'SampleRate'))
setappdata(0,'samHandles',samHandles);

%-------------Timer funktion for running collor-----------

if ~isempty(timerfind) 
    stop(timerfind)
    delete(timerfind)
end




t = timer('TimerFcn', @(h, ev) timerCallback(h, ev, handles));
samHandles
t.executionMode = 'fixedRate';
% set(t,'timerFcn',@timerCallback);
t.Period = 0.25;

set(ai,'TimerFcn',{@scansAvailable_Callback,handles,samHandles})


counter = 1;
setappdata(0,'counter',counter);
try
    start(ai);
    start(t);
    tic
catch
    disp 'error';
end


    
if   get(handles.trigg,'Value')==0
    [data,time,abstime]=getdata(ai);
    stri = datestr(now,'HHMMSS');
    stri = ['C:\Documents and Settings\sampDev\Desktop\SAMPSAMP\' stri '.mat'];
    save([ samHandles.folderDir '\' samHandles.fileNameMat '.mat'], 'data','time','abstime', '-append')

end

home

function scansAvailable_Callback(hObject, eventdata, handles,samHandles)
% scansAvailable_Callback Executes on DAQ ScansAvailable event
% This callback function gets executed periodically as more data is acquired by the daqDevice.
% This callback is setup in the script 'configureDAQ.m' 
    tic
    if ~isvalid(app)
        return
    end
    
    % Continuous acquisition data and timestamps are stored in FIFO data buffers
    % Calculate required buffer size -- this should be large enough to accomodate the
    % the data required for the live view time window and the data for the requested
    % capture duration.
    
    [data,timestamps] = read(src, src.ScansAvailableFcnCount, 'OutputFormat','Matrix');
    
    bufferSize = str2double(app.timeoutSecs.Value) * str2double(app.sampleFrequency.Value);

    % FIFO Buffer setup:
    % (1) is timestamps
    % (2) is trigger data
    % (3) is participant data
    app.FIFOBuffer = storeDataInFIFO(app.FIFOBuffer, bufferSize, timestamps, data);
    % App state control logic 
    switch app.currentState
        case 'Acquisition.Buffering'
            % Buffering pre-trigger data, this points to a script
            % in the 'Functions' folder
            if isEnoughDataBuffered(app.FIFOBuffer(:, 1), app.delaySamples.Value)
                % Depending if user wants to employ a software
                % trigger or not, change state
                app.currentState = 'Capture.CapturingData';
                if app.useTrigger
                    app.currentState = 'Capture.LookingForTrigger';
                else
                    app.captureStartMoment = app.lastSaveTime;
                    app.currentState = 'Capture.CapturingData';
                end
            end
        case 'Capture.LookingForTrigger'
            % Looking for trigger event in the latest data
            trigActive = detectStartTrigger(app);
            if trigActive
                app.currentState = 'Capture.CapturingData';
            end
        case 'Capture.CapturingData'
            % Get index for where data block starts
            dataBlockStartIndex = find(app.FIFOBuffer(:, 1) >= app.captureStartMoment, 1, 'first');
            dataBlockLength = size(app.FIFOBuffer, 1) - dataBlockStartIndex;
            % Only show available data, up to the maximum window, and only show data from the current data block
            samplesToPlot = min([round(str2double(app.viewWindowLength.Value) * src.Rate), size(app.FIFOBuffer,1), dataBlockLength]);
            firstPoint = size(app.FIFOBuffer, 1) - samplesToPlot + 1;

            % Plot the trigger data if the user has selected the relevant checkbox
            if app.showTrigger.Value
                plot(app.triggerPlot, app.FIFOBuffer(firstPoint:end, 1), ...
                     app.FIFOBuffer(firstPoint:end, 2));
            end
            % Always plot the recorded data when collecting data 
            plot(app.dataPlot, app.FIFOBuffer(firstPoint:end, 1), ...
                 app.FIFOBuffer(firstPoint:end, 3));

            % Wrap axis limits around the data
            app.triggerPlot.XLim = [app.FIFOBuffer(firstPoint, 1), app.FIFOBuffer(end, 1)];
            app.dataPlot.XLim = [app.FIFOBuffer(firstPoint, 1), app.FIFOBuffer(end, 1)];
            drawnow
            % First case: when triggers are used, check to save
            % data by either a timeout 
            if app.trigOrNot == 1
                timeoutResult = str2double((app.FIFOBuffer(end,1)-app.captureStartMoment)) > str2double(app.timeoutSecs.Value);
                endTriggerResult = detectEndTrigger(app);
                if any(timeoutResult) || any(endTriggerResult)
                    completeCapture(app)
                end
            % Second case: no trigger is used, save the current
            % data as it is being recorded to prevent dropped data
            else
                timeoutResult = app.FIFOBuffer(end,1) - app.lastSaveTime > str2double(app.timeoutSecs.Value) - 1;
                if any(timeoutResult)
                    completeCapture_noTrigg(app)
                end
            end
    end
    toc

function trigActive = detectStartTrigger(app)
%detectTrigger Detects trigger condition and updates relevant app properties
% Updates TrigActive, TrigMoment, and CaptureStartMoment app properties
    freq       = str2double(app.sampleFrequency.Value);
    updateFreq = str2double(app.updateFrequency.Value);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(app.FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents photo-diode channel
    trigConfig.Level = app.startTrigValue.Value;
    trigConfig.Condition = 'Rising';
    [trigActive, app.captureStartMoment] = ...
        trigDetect(app.FIFOBuffer(index: end, 1), app.FIFOBuffer(index: end, 2), trigConfig);

function result = detectEndTrigger(app)
%detectTrigger Detects trigger condition and updates relevant app properties
% Updates TrigActive, TrigMoment, and CaptureStartMoment app properties
    freq            = str2double(app.sampleFrequency.Value);
    updateFreq      = str2double(app.updateFrequency.Value);
    scansAvailable = freq * (updateFreq / 1000);
    % Get index to check only new data for trigger
    index = size(app.FIFOBuffer, 1) - scansAvailable + 1;
    
    trigConfig.Channel = 1; % Represents Stabby-stab channel
    trigConfig.Level = app.stopTrigValue.Value;
    trigConfig.Condition = 'Falling';
    [result, app.captureEndMoment] = ...
        trigDetect(app.FIFOBuffer(index: end, 1), app.FIFOBuffer(index: end, 2), trigConfig);

function completeCapture(app)
% completeCapture Saves captured data to user folder and resets DAQ
% device to wait for another trigger
    % Find index of first sample in data buffer to be captured
    firstSampleIndex = find(app.FIFOBuffer(:, 1) >= app.captureStartMoment, 1, 'first');
    
    % Find index of last sample in data buffer that complete the capture
    lastSampleIndex = find(app.FIFOBuffer(:, 1) >= app.captureEndMoment, 1, 'first');

    if isempty(firstSampleIndex) || isempty(lastSampleIndex) || lastSampleIndex > size(app.FIFOBuffer(:, 1), 1)
        % If the index's either don't exist or go outside the
        % expected range of the captured data, abort.
        % Fill this with more sampsamp related warnings
        uialert(fig, 'Could not complete capture.', 'Capture error');
        return
    end

    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(app.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(app.counter));
    
    % Extract capture data and shift timestamps so that 0 corresponds to the trigger moment
    % Save these to Data_Block_n and Ticktime_Block_n, respectively 
    captureDataCmd = strcat(dataBlockName, "= [app.dataFIFOBuffer(firstSampleIndex:lastSampleIndex), " + ...
        "app.triggerPlotFIFOBuffer(firstSampleIndex:lastSampleIndex)];");
    ticktimeCmd = strcat(timeBlockName, "= convertTo(datetime('now'),'epochtime','Epoch','1970-01-01');");
    % Run these commands
    eval(captureDataCmd)
    eval(ticktimeCmd)

    % Create and run a save script using our dynamic variables
    saveCmd = strcat("save(app.recordingName, '", dataBlockName, ...
        "', '", timeBlockName, "', '-append');");
    eval(saveCmd)

    %---Save the handle structure-----
    app.counter = app.counter + 1;
    %---------------------------------

    %---start the daq-object again-----
    try
        % start(app.DAQ, 'Continuous')
        app.currentState = 'Capture.LookingForTrigger';
    catch
        disp 'Timed out';
    end

function completeCapture_noTrigg(app)
% completeCapture Saves captured data to user folder for when no
% trigger is used, ends recording session.
    
    % Set dynamic variable names based on current block
    dataBlockName = strcat("Data_Block_", num2str(app.counter));
    timeBlockName = strcat("Ticktime_Block_", num2str(app.counter));

    % Find the last time data was autosaved and grab its index
    saveConditionMet = app.FIFOBuffer(:, 1) >= app.lastSaveTime;
    saveIndex = 1 + find(saveConditionMet==1, 1, 'first'); %#ok<NASGU> This is fine as it is used in an eval() command
    app.lastSaveTime = app.FIFOBuffer(end, 1);
    
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
    app.counter = app.counter + 1;
    %--------------------------------- 

function configureDAQ(app)
    % Obtain variables from app properties
    ai              = app.analogueInputChoice;
    d               = daq(app.daqType);
    freq            = str2double(app.sampleFrequency.Value);
    updateFreq      = str2double(app.updateFrequency.Value);
    
    % When you add channels you need the number of the
    % port to sample from to activate it, under this a vector is created
    % which elements represent 
    
    for i=0:7
        if ai(i+1) == 1
            % If selected, add a channel to be recorded to DAQ object
            addinput(d, app.daqConnection, i, "Voltage");
        end
    end
    
    %-------------------Specific properties for trigger------------------------
    
    % Configure DAQ ScansAvailableFcn callback function
    d.ScansAvailableFcn = @(src,event) scansAvailable_Callback(app, src, event);
    d.ScansAvailableFcnCount = freq * (updateFreq / 1000); % Update Freq is in milli seconds, put back into seconds
    
    % Sets sample rate of ai will be rounded off to closest possible sampling rate 
    %(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
    d.Rate = freq;
    
    app.DAQ = d;

% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in reset.

if ~isempty(app.DAQ)
    stop(app.DAQ);
end
if app.trigOrNot.Value == 0
    completeCapture_noTrigg(app);
end
app.startDAQ.FontColor = 'red';
app.currentState = 'Acquisition.ReadyForCapture';

% --- Executes during object creation, after setting all properties.
function saveDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openFolder.
function openFolder_Callback(hObject, eventdata, handles)
% hObject    handle to openFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir=uigetdir;
if ~dir==0
    set(handles.saveDir,'String',dir);
end


% --- Executes on button press in fromAbove.
function fromAbove_Callback(hObject, eventdata, handles)
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
function fromUnder_Callback(hObject, eventdata, handles)
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
function trigOrNot_Callback(hObject, eventdata, handles)
% hObject    handle to trigOrNot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trigOrNot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trigOrNot
val = get(handles.trigOrNot,'Value');
switch val
    case 1
        set(handles.triggerValue,'Visible','On')
        set(handles.triggVal,'Visible','On')
        set(handles.text13,'Visible','On')
        set(handles.stopValue,'Visible','on')
        set(handles.fromAbove,'Visible','On')
        set(handles.fromUnder,'Visible','On')
        set(handles.stopTrig,'Visible','On')
        set(handles.text14,'Visible','On');
    case 2 
        set(handles.triggerValue,'Visible','Off')
        set(handles.triggVal,'Visible','Off')
        set(handles.text13,'Visible','off')
        set(handles.stopValue,'Visible','off')
        set(handles.fromAbove,'Visible','Off')
        set(handles.fromUnder,'Visible','Off')
        set(handles.stopTrig,'Visible','Off')
        set(handles.text14,'Visible','Off');
end
% --- Executes during object creation, after setting all properties.
function trigOrNot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trigOrNot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in openFile.
function openFile_Callback(hObject, eventdata, handles)
% hObject    handle to openFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file folder]= uigetfile('C:\-(sampsamp)-\q.mat');
[file folder]= uigetfile('E:\Yuri\q.mat');
if isequal(file,0) || isequal(folder,0)
    disp('Operation canceled')
else

    handles.matFile = [folder file];
    handles.files = whos ('-file', [folder file]);% [folder file]);
    storlek = size(handles.files);
    N = (storlek(1)-1)/2;

    set(handles.listbox,'String',{'load new file'});
    for i = 1:N-3
        oldString = get(handles.listbox,'String');
        set(handles.listbox,'String', {oldString{:} handles.files(i).name})
    end
end
guidata(hObject,handles)
