function [handles, samHandles, ai] = aiLoader(handles, samHandles,  ai, useTrigg)

%-------------Adds channals to ai from analogInputPanel-----------------
a(1) = 1; % Respresents get(handles.a0,'value'); as a0 is static
a(2) = get(handles.a1,'value'); 
a(3) = get(handles.a2,'value');
a(4) = get(handles.a3,'value');
a(5) = get(handles.a4,'value');
a(6) = get(handles.a5,'value');
a(7) = get(handles.a6,'value');
a(8) = get(handles.a7,'value');

% When you add channels you need the number of the
% port to sample from to activate it, under this a vector is created
% which elements represent 

y = zeros(1, 8);

for i=0:7
    if a(i+1) == 1
        y(i+1)=i;
    end
end

ch=addchannel(ai,y);

%-------------------Specific properties for trigger------------------------

if get(handles.trigOrNot,'Value')== 1    
    if useTrigg == 1
        % Start trigger is set on software trigger
        set (ai,'TriggerType','Software'); 
        % unit[V] The TriggerConditionValue is the criteria for when thrigger signal invokes the trigger.
        set (ai,'TriggerConditionValue',samHandles.triggVal);
        % Specifies the amount of data that is to be saved pre trigger in time unit [s] 
        set (ai,'TriggerDelay',-samHandles.delaySamples);
    end
    % Directs the software trigger to the channel that are supose to act as a trigger signal
    set (ai,'TriggerChannel',ch(1)); 
else
    set(handles.freq,'String','40000')
    set(handles.sec,'String','1800')
    samHandles.triggerBoolean = 0; 
end  

timeString = get(handles.sec,'String');
time = str2double(timeString);

sampPerTrig = samHandles.freq * time;

% Sets sample rate of ai will be rounded off to closes possible sampling rate 
%(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
set (ai,'SampleRate',samHandles.freq);

% Determens longest possible sampling time before sampsamp considers the start 
% trigger to be a false one and shots itself off
set(ai,'SamplesPerTrigger',sampPerTrig);

if useTrigg == 1        
    % Sets the intervalls at which daqrealtimeplot_Callback is to be run
    set(ai,'TimerPeriod',0.1);
end

% Function to be run within the interwall set by TriggerDelay
set(ai,'TimerFcn',@dRTPC)

% Sets the function that is to be run when data is missed.
set(ai,'DataMissedFcn',@missedData);
