function varargout = sampsamp(varargin)
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
                   'gui_OpeningFcn', @sampsamp_OpeningFcn, ...
                   'gui_OutputFcn',  @sampsamp_OutputFcn, ...
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
%---------------------------------------------------------
if get(handles.trigOrNot,'Value')==1 && get(handles.trigg,'Value')==1
    set(ai,'TimerFcn',{@daqRealTimePlotCallback,handles,samHandles})%or some reason this doesent work when in aiLoader
else
    set(ai,'TimerFcn',{@basicDaqRealTimePlotCallback,handles,samHandles})
end


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

function daqRealTimePlotCallback(hObject, eventdata, handles,samHandles)
% hObject    handle to daqrealtimeplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% function daqrealtimeplot(hObject,eventdata)
size = hObject.SamplesAvailable;
if hObject.SamplesAvailable > 160
 

    lastSamps=peekdata(hObject, samHandles.stopSize);
    data=peekdata(hObject,size);
    
    if samHandles.aboveUnder
        test = max(lastSamps);
        test = test(1);
    else
        test = min(lastSamps);
        test = test(1);
        disp hejyo
    end
    if test<samHandles.stopTrig
        stop(hObject)
        counter = getappdata(0,'counter');
        samps = hObject.SamplesAvailable;
        [data,time,abstime]=getdata(hObject,samps);
%        data = [data; abstime'];

        samHandles.fileNameData = [samHandles.dataBlock num2str(counter)];
        %%%value to ticktimes
        
        ticktimes_block = etime(abstime,[1970 01 01 0 0 0 ]);
%        samHandles.fileNameMat =[ '' num2str(abstime(1)) '' num2str(abstime(2)) '' num2str(abstime(3)) 'T' num2str(abstime(4)) '' num2str(abstime(5)) '' num2str(abstime(6))];
        %folder = getappdata(0,'folder'); 
        
        fileNameData = [samHandles.dataBlock num2str(counter)];
        fileNameTime = [samHandles.fileNameTime num2str(counter)];

        eval([sprintf(fileNameData) '=data'';']);
        eval([sprintf(fileNameTime) '=ticktimes_block;']);
        
        save([ samHandles.folderDir '\' samHandles.fileNameMat '.mat']...
            ,fileNameData,fileNameTime,'-append');
        
%         try
%                save([ 'Z:\' samHandles.fileNameMat '.mat']...
%                ,fileNameData,fileNameTime,'-append');
%             catch
%                 disp 'did not manage to connect to network drive Z: make sure you are logged in on network drive!';
%             end
        
        %---Save the handle structure-----
        counter = counter + 1;
        setappdata(0,'counter',counter);
        setappdata(0,'samHandles',samHandles);
        %---------------------------------
        
        %---start the daq-object again-----
        try
            
            start(hObject)
        catch
            disp 'Timed out';
        end
        %----------------------------------
    end
%     figure(samHandles.plotFigTrig);



    N=length(data(:,1));
    T=N/samHandles.freq;
    x=linspace(0,T,N);
    
    if T<11
        cla(samHandles.plotFigTrigAxis)
        axis(samHandles.plotFigTrigAxis,[0 11 0 4])
        hold (samHandles.plotFigTrigAxis,'on')
    
        plot(samHandles.plotFigTrigAxis,x,data(sprintf(samHandles.subPlot),1));
        hold (samHandles.plotFigTrigAxis,'off')
    else
        x2=linspace(T-10,T,10*samHandles.freq+1);
        plot(samHandles.plotFigTrigAxis,x2,data(end-samHandles.freq*10:end,1));
    end
    
    try 
        
        if T<11
            cla(samHandles.plotFigDataAxis);
            axis(samHandles.plotFigDataAxis,[0 11 0 0.2])
%             axis (samHandles.plotFigDataAxis,manual)         
            hold (samHandles.plotFigDataAxis,'on')
            axis (samHandles.plotFigDataAxis,'auto y');                        
            plot(samHandles.plotFigDataAxis,x,data(sprintf(samHandles.subPlot),2));

            hold (samHandles.plotFigDataAxis,'off')
            
        else
            plot(samHandles.plotFigDataAxis,x2,data(end-samHandles.freq*10:end,2));
        end

       
    end

end

function basicDaqRealTimePlotCallback(hObject, eventdata, handles,samHandles)
if hObject.samplesAvailable>0
   
    
    %this callback for no trigger
    
    size = hObject.SamplesAvailable;
    data = peekdata(hObject,size);
    cla(samHandles.plotFigDataAxis);
    plot(samHandles.plotFigDataAxis,data(:,1))
    cla (samHandles.plotFigTrig);
    plot(samHandles.plotFigTrig,data(1:10:end,2));
   
end



function timerCallback(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% disp(rand)
if ~isempty(daqfind)
    ai = daqfind;
    samHandles = getappdata(0,'samHandles');
    if strcmp(ai.Running, 'On') && samHandles.countOnOff>1
        disp start
        set(handles.startDAQ,'ForegroundColor', [0 1 0]);
        samHandles.countOnOff = 0;
    end
    if strcmp(ai.Running, 'Off')&& samHandles.countOnOff<2
        samHandles.countOnOff = samHandles.countOnOff + 1;
        if samHandles.countOnOff>1
           [data,time,abstime]=getdata(ai, ai.SamplesAvailable);
        samHandles.fileNameData = [samHandles.dataBlock];
        ticktimes_block = etime(abstime,[1970 01 01 0 0 0 ]);
%        samHandles.fileNameMat =[ '' num2str(abstime(1)) '' num2str(abstime(2)) '' num2str(abstime(3)) 'T' num2str(abstime(4)) '' num2str(abstime(5)) '' num2str(abstime(6))];
        %folder = getappdata(0,'folder'); 
        
        fileNameData = [samHandles.dataBlock];
        fileNameTime = [samHandles.fileNameTime];

        eval([sprintf(fileNameData) '=data'';']);
        eval([sprintf(fileNameTime) '=ticktimes_block;']);
        
        save([ samHandles.folderDir '\' samHandles.fileNameMat '.mat']...
            ,fileNameData,fileNameTime,'-append');
           
           
           
            disp stop
            set(handles.startDAQ,'ForegroundColor',[1 0 0]);
%             set(handles.startDAQ,'ForegroundColor',[1 0 0]);
         end
    end
    
setappdata(0,'samHandles',samHandles);
end







% --- Outputs from this function are returned to the command line.
function varargout = sampsamp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in reset.
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(daqfind) 
    stop (daqfind);
end


% --- Executes on button press in home.
function home_Callback(hObject, eventdata, handles)
% hObject    handle to home (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
home;


% --- Executes on selection change in val1.
function val1_Callback(hObject, eventdata, handles)
% hObject    handle to val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns val1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val1


% --- Executes during object creation, after setting all properties.
function val1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in val2.
function val2_Callback(hObject, eventdata, handles)
% hObject    handle to val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns val2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from val2


% --- Executes during object creation, after setting all properties.
function val2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to val2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function freq_Callback(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freq as text
%        str2double(get(hObject,'String')) returns contents of freq as a double


% --- Executes during object creation, after setting all properties.
function freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sec_Callback(hObject, eventdata, handles)
% hObject    handle to sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sec as text
%        str2double(get(hObject,'String')) returns contents of sec as a double


% --- Executes during object creation, after setting all properties.
function sec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in a1.
function a1_Callback(hObject, eventdata, handles)
% hObject    handle to a1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a1


% --- Executes on button press in a2.
function a2_Callback(hObject, eventdata, handles)
% hObject    handle to a2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a2


% --- Executes on button press in a3.
function a3_Callback(hObject, eventdata, handles)
% hObject    handle to a3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a3


% --- Executes on button press in a4.
function a4_Callback(hObject, eventdata, handles)
% hObject    handle to a4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a4


% --- Executes on button press in a5.
function a5_Callback(hObject, eventdata, handles)
% hObject    handle to a5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a5


% --- Executes on button press in a6.
function a6_Callback(hObject, eventdata, handles)
% hObject    handle to a6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a6


% --- Executes on button press in a7.
function a7_Callback(hObject, eventdata, handles)
% hObject    handle to a7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a7


% --- Executes on button press in a0.
function a0_Callback(hObject, eventdata, handles)
% hObject    handle to a0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a0


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


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function freqTest_Callback(hObject, eventdata, handles)
% hObject    handle to freqTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqTest as text
%        str2double(get(hObject,'String')) returns contents of freqTest as a double


% --- Executes during object creation, after setting all properties.
function freqTest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function secTest_Callback(hObject, eventdata, handles)
% hObject    handle to secTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of secTest as text
%        str2double(get(hObject,'String')) returns contents of secTest as a double


% --- Executes during object creation, after setting all properties.
function secTest_CreateFcn(hObject, eventdata, handles)
% hObject    handle to secTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in a1.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to a1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a1


% --- Executes on button press in a2.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to a2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a2


% --- Executes on button press in a3.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to a3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a3


% --- Executes on button press in a4.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to a4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a4


% --- Executes on button press in a5.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to a5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a5


% --- Executes on button press in a6.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to a6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a6


% --- Executes on button press in a7.
function checkbox23_Callback(hObject, eventdata, handles)
% hObject    handle to a7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a7


% --- Executes on button press in a0.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to a0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a0


% --- Executes on button press in settings.
function settings_Callback(hObject, eventdata, handles)
% hObject    handle to settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
run sampsampTrouble


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

% Hint: get(hObject,'Value') returns toggle state of fromUnder



function stopTrig_Callback(hObject, eventdata, handles)
% hObject    handle to stopTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopTrig as text
%        str2double(get(hObject,'String')) returns contents of stopTrig as a double


% --- Executes during object creation, after setting all properties.
function stopTrig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopTrig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function missedData(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
disp oj



function triggVal_Callback(hObject, eventdata, handles)
% hObject    handle to triggVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triggVal as text
%        str2double(get(hObject,'String')) returns contents of triggVal as a double


% --- Executes during object creation, after setting all properties.
function triggVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function name_Callback(hObject, eventdata, handles)
% hObject    handle to name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of name as text
%        str2double(get(hObject,'String')) returns contents of name as a double


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function delSam_Callback(hObject, eventdata, handles)
% hObject    handle to delSam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of delSam as text
%        str2double(get(hObject,'String')) returns contents of delSam as a double


% --- Executes during object creation, after setting all properties.
function delSam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delSam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Device.
function Device_Callback(hObject, eventdata, handles)
% hObject    handle to Device (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Device contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Device


% --- Executes during object creation, after setting all properties.
function Device_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Device (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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


% --- Executes during object creation, after setting all properties.
function dataPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate dataPlot


% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close


% --- Executes on button press in fastPlot.
function fastPlot_Callback(hObject, eventdata, handles)
% hObject    handle to fastPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fastPlot


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles,samHandles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox
string = get(handles.listbox,'String');
val = get(handles.listbox,'Value');
samHandles = getappdata(0,'samHandles');
if val > 1
    load(handles.matFile,handles.files(val-1).name)

    plot(handles.allDataPlot,eval([handles.files(val-1).name '(1,:)']))
    %[handles]=drawLine_fcn(handles);
end
guidata(hObject,handles)


function drawLine_fcn(handles)

try
    handles.lineXData = get(handles.line1,'XData');
end

handles.line1 = line('XData',handles.lineXData);

 

% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
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


% --- Executes on button press in positionSampSamp.
function positionSampSamp_Callback(hObject, eventdata, handles)
% hObject    handle to positionSampSamp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles] = posSampSamp(handles,2);


% --- Executes on button press in trigg.
function trigg_Callback(hObject, eventdata, handles)
% hObject    handle to trigg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trigg
