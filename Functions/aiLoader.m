function [daqDevice] = aiLoader(app)

% Inputs to this function:
% app = contains handles to all SampSamp properties
% daqDevice = Handle to the DAQ object, allowing us to change our recording
% settings
% ai = Array corresponding to analogue inputs 0-7 and which to turn on

% Obtain variables from app properties
ai = app.analogueInputChoice;
daqDevice = app.daqDevice;


% When you add channels you need the number of the
% port to sample from to activate it, under this a vector is created
% which elements represent 

for i=0:7
    if ai(i+1) == 1
        % If selected, add a channel to be recorded to DAQ object
        addinput(daqDevice, DAQID, i, "Voltage");
    end
end

%-------------------Specific properties for trigger------------------------

if app.trigOrNot.Value == 1    
        % Start trigger is set on software trigger
        set (daqDevice,'TriggerType','Software'); 
        % unit[V] The TriggerConditionValue is the criteria for when thrigger signal invokes the trigger.
        set (daqDevice,'TriggerConditionValue',samHandles.triggVal);
        % Specifies the amount of data that is to be saved pre trigger in time unit [s] 
        set (daqDevice,'TriggerDelay',-samHandles.delaySamples);
    % Directs the software trigger to the channel that are supose to act as a trigger signal
    set (ai,'TriggerChannel',ch(1)); 
else
    set(app.freq,'String','40000')
    set(app.sec,'String','1800')
    samHandles.triggerBoolean = 0; 
end  

timeString = get(app.sec,'String');
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
