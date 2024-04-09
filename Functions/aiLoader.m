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

% Configure DAQ ScansAvailableFcn callback function
daqDevice.ScansAvailableFcn = @(src,event) scansAvailable_Callback(app, src, event);

% Sets sample rate of ai will be rounded off to closes possible sampling rate 
%(sample rate is limite by stepsize 1/250000 and has to be modulus 0 with it..)
daqDevice.Rate = sampleFrequency;

if useTrig == 1        
    % Sets the intervalls at which daqrealtimeplot_Callback is to be run
    set(daqDevice,'TimerPeriod',0.1);
end
