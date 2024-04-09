function [daqDevice] = aiLoader(app)

% Inputs to this function:
% app = contains handles to all SampSamp properties
% daqDevice = Handle to the DAQ object, allowing us to change our recording
% settings
% ai = Array corresponding to analogue inputs 0-7 and which to turn on

% Obtain variables from app properties
ai = app.analogueInputChoice;
daqDevice = app.daqDevice;
useTrig = app.trigOrNot.Value;

sampleFrequency = app.freq.Value;
timeout = app.sec.Value;


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

if useTrig == 1    
    % Start trigger is set on software trigger
    set (daqDevice,'TriggerType','Software'); 
    % unit[V] The TriggerConditionValue is the criteria for when thrigger signal invokes the trigger.
    set (daqDevice,'TriggerConditionValue',samHandles.triggVal);
    % Specifies the amount of data that is to be saved pre trigger in time unit [s] 
    set (daqDevice,'TriggerDelay',-samHandles.delaySamples);
    % Directs the software trigger to the channel that are supose to act as a trigger signal
    set (daqDevice,'TriggerChannel',ch(1)); 
end

samplesPerTrig = sampleFrequency * timeout;

% Sets sample rate of ai will be rounded off to closes possible sampling rate 
%(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
set(daqDevice,'SampleRate',sampleFrequency);

% Determens longest possible sampling time before sampsamp considers the start 
% trigger to be a false one and shots itself off
set(daqDevice,'SamplesPerTrigger',samplesPerTrig);

if useTrig == 1        
    % Sets the intervalls at which daqrealtimeplot_Callback is to be run
    set(daqDevice,'TimerPeriod',0.1);
end

% Function to be run within the interwall set by TriggerDelay
set(daqDevice,'TimerFcn',@dRTPC)

% Sets the function that is to be run when data is missed.
set(daqDevice,'DataMissedFcn',@missedData);
